//! Ahla Core Phase C: E2EE + SQLite + NATS (FFI/JNI)
use std::ffi::{CStr, CString};
use std::os::raw::{c_char, c_int, c_uchar};
use once_cell::sync::Lazy;
use parking_lot::Mutex;

use base64::{engine::general_purpose::STANDARD as B64, Engine as _};
use chacha20poly1305::{ChaCha20Poly1305, Key, KeyInit, aead::{Aead, OsRng}, XNonce};
use rand_core::RngCore;
use x25519_dalek::{PublicKey, StaticSecret};

use serde::{Serialize, Deserialize};

// DB
use rusqlite::{Connection, params};

// NATS
use futures_util::StreamExt;
static RUNTIME: Lazy<tokio::runtime::Runtime> = Lazy::new(|| {
    tokio::runtime::Builder::new_multi_thread().enable_all().build().unwrap()
});

// ---------------- Global State ----------------
#[derive(Default)]
struct State {
    my_sk: Option<StaticSecret>,
    my_pk: Option<PublicKey>,
    peer_pk: Option<PublicKey>,
    db: Option<Connection>,
    // inbound messages buffer
    inbox: Vec<String>, // JSON lines
}
static STATE: Lazy<Mutex<State>> = Lazy::new(|| Mutex::new(State::default()));

// ---------------- Helpers ----------------
fn derive_key() -> Option<Key> {
    let st = STATE.lock();
    match (&st.my_sk, &st.peer_pk) {
        (Some(sk), Some(peer)) => {
            let shared = sk.diffie_hellman(peer);
            let mut key = [0u8; 32];
            // simple KDF: hash-like expansion (not HKDF for brevity)
            // In production: use HKDF with salt/info.
            blake3::derive_key("ahla-e2ee-v1", shared.as_bytes(), &mut key);
            Some(Key::from_slice(&key).to_owned())
        }
        _ => None
    }
}

fn enc_text(plain: &str) -> Option<String> {
    let key = derive_key()?;
    let cipher = ChaCha20Poly1305::new(&key);
    let mut nonce = [0u8; 24];
    OsRng.fill_bytes(&mut nonce);
    let nonce = XNonce::from_slice(&nonce);
    let ct = cipher.encrypt(nonce, plain.as_bytes()).ok()?;
    let mut out = Vec::with_capacity(24 + ct.len());
    out.extend_from_slice(nonce);
    out.extend_from_slice(&ct);
    Some(B64.encode(&out))
}

fn dec_text(b64: &str) -> Option<String> {
    let key = derive_key()?;
    let data = B64.decode(b64).ok()?;
    if data.len() < 25 { return None; }
    let (nonce, ct) = data.split_at(24);
    let cipher = ChaCha20Poly1305::new(&key);
    let pt = cipher.decrypt(XNonce::from_slice(nonce), ct).ok()?;
    String::from_utf8(pt).ok()
}

// ---------------- FFI C API ----------------
#[no_mangle] pub extern "C" fn ahla_init() { let _ = &*RUNTIME; }

#[no_mangle] pub extern "C" fn ahla_kp_generate() {
    let sk = StaticSecret::new(OsRng);
    let pk = PublicKey::from(&sk);
    let mut st = STATE.lock();
    st.my_sk = Some(sk);
    st.my_pk = Some(pk);
}

#[no_mangle] pub extern "C" fn ahla_pubkey_hex() -> *mut c_char {
    let st = STATE.lock();
    if let Some(pk) = &st.my_pk {
        let hex = hex::encode(pk.to_bytes());
        CString::new(hex).unwrap().into_raw()
    } else {
        std::ptr::null_mut()
    }
}

#[no_mangle] pub extern "C" fn ahla_set_peer_pubkey_hex(hex_str: *const c_char) -> c_int {
    if hex_str.is_null() { return -1; }
    let s = unsafe { CStr::from_ptr(hex_str) }.to_string_lossy().into_owned();
    match hex::decode(s) {
        Ok(bytes) if bytes.len() == 32 => {
            let pk = PublicKey::from(bytes.as_slice().try_into().unwrap());
            let mut st = STATE.lock();
            st.peer_pk = Some(pk);
            0
        }
        _ => -2
    }
}

#[no_mangle] pub extern "C" fn ahla_encrypt_text(plain: *const c_char) -> *mut c_char {
    if plain.is_null() { return std::ptr::null_mut(); }
    let s = unsafe { CStr::from_ptr(plain) }.to_string_lossy().into_owned();
    match enc_text(&s) {
        Some(b64) => CString::new(b64).unwrap().into_raw(),
        None => std::ptr::null_mut()
    }
}

#[no_mangle] pub extern "C" fn ahla_decrypt_text(b64: *const c_char) -> *mut c_char {
    if b64.is_null() { return std::ptr::null_mut(); }
    let s = unsafe { CStr::from_ptr(b64) }.to_string_lossy().into_owned();
    match dec_text(&s) {
        Some(pt) => CString::new(pt).unwrap().into_raw(),
        None => std::ptr::null_mut()
    }
}

#[no_mangle] pub extern "C" fn ahla_string_free(ptr: *mut c_char) {
    if ptr.is_null() { return; }
    unsafe { let _ = CString::from_raw(ptr); }
}

// ---------------- SQLite (envelope encrypted) ----------------
#[no_mangle] pub extern "C" fn ahla_db_open(path: *const c_char) -> c_int {
    if path.is_null() { return -1; }
    let p = unsafe { CStr::from_ptr(path) }.to_string_lossy().into_owned();
    match Connection::open(p) {
        Ok(conn) => {
            conn.execute_batch(r#"
                CREATE TABLE IF NOT EXISTS messages(
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    room TEXT NOT NULL,
                    mine INTEGER NOT NULL,
                    b64 TEXT NOT NULL,
                    ts INTEGER NOT NULL
                );
            "#).ok();
            STATE.lock().db = Some(conn);
            0
        }
        Err(_) => -2
    }
}

#[no_mangle] pub extern "C" fn ahla_store_message(room: *const c_char, mine: c_int, plain: *const c_char) -> c_int {
    if room.is_null() || plain.is_null() { return -1; }
    let room = unsafe { CStr::from_ptr(room) }.to_string_lossy().into_owned();
    let plain = unsafe { CStr::from_ptr(plain) }.to_string_lossy().into_owned();
    let b64 = match enc_text(&plain) { Some(v) => v, None => return -3 };
    let ts = chrono::Utc::now().timestamp_millis();
    let mut st = STATE.lock();
    if let Some(db) = st.db.as_ref() {
        db.execute("INSERT INTO messages(room,mine,b64,ts) VALUES(?,?,?,?)",
            params![room, mine as i32, b64, ts]).ok();
        0
    } else { -2 }
}

#[no_mangle] pub extern "C" fn ahla_export_room_json(room: *const c_char) -> *mut c_char {
    if room.is_null() { return std::ptr::null_mut(); }
    let room = unsafe { CStr::from_ptr(room) }.to_string_lossy().into_owned();
    let mut st = STATE.lock();
    let db = match st.db.as_ref() { Some(d) => d, None => return std::ptr::null_mut() };
    let mut stmt = db.prepare("SELECT mine,b64,ts FROM messages WHERE room=? ORDER BY ts ASC").ok()?;
    #[derive(Serialize)] struct Msg { mine: bool, text: String, ts: i64 }
    let rows = stmt
        .query_map(params![room], |r| Ok((r.get::<_, i32>(0)?, r.get::<_, String>(1)?, r.get::<_, i64>(2)?)))
        .ok()?;
    let mut out: Vec<Msg> = Vec::new();
    for row in rows {
        if let Ok((mine, b64, ts)) = row {
            if let Some(pt) = dec_text(&b64) {
                out.push(Msg { mine: mine != 0, text: pt, ts });
            }
        }
    }
    let json = serde_json::to_string(&out).unwrap_or_else(|_| "[]".into());
    CString::new(json).unwrap().into_raw()
}

// ---------------- NATS (TCP) ----------------
static mut NATS_CLIENT: Option<async_nats::Client> = None;

#[no_mangle] pub extern "C" fn ahla_nats_connect(url: *const c_char, token: *const c_char) -> c_int {
    if url.is_null() { return -1; }
    let url = unsafe { CStr::from_ptr(url) }.to_string_lossy().into_owned();
    let token = if token.is_null() { String::new() } else { unsafe { CStr::from_ptr(token) }.to_string_lossy().into_owned() };
    let fut = async move {
        let opts = if token.is_empty() {
            async_nats::ConnectOptions::default()
        } else {
            async_nats::ConnectOptions::with_token(token)
        };
        match opts.connect(url).await {
            Ok(client) => {
                unsafe { NATS_CLIENT = Some(client); }
                0
            },
            Err(_) => -2
        }
    };
    RUNTIME.block_on(fut)
}

#[no_mangle] pub extern "C" fn ahla_nats_subscribe_room(room: *const c_char) -> c_int {
    if room.is_null() { return -1; }
    let room = unsafe { CStr::from_ptr(room) }.to_string_lossy().into_owned();
    let fut = async move {
        let client = unsafe { NATS_CLIENT.clone().ok_or(()) }.map_err(|_| -2)?;
        let subject = format!("chat.room.{room}");
        let mut sub = client.subscribe(subject).await.map_err(|_| -3)?;
        // Receiver loop
        tokio::spawn(async move {
            while let Some(msg) = sub.next().await {
                if let Ok(text) = String::from_utf8(msg.payload.to_vec()) {
                    // decrypt if possible
                    let plain = dec_text(&text).unwrap_or(text);
                    let j = serde_json::json!({
                        "room": room,
                        "mine": false,
                        "text": plain,
                        "ts": chrono::Utc::now().timestamp_millis()
                    }).to_string();
                    STATE.lock().inbox.push(j);
                }
            }
        });
        Ok::<i32, i32>(0)
    };
    RUNTIME.block_on(fut).unwrap_or_else(|e| e)
}

#[no_mangle] pub extern "C" fn ahla_nats_publish_room(room: *const c_char, plain: *const c_char) -> c_int {
    if room.is_null() || plain.is_null() { return -1; }
    let room = unsafe { CStr::from_ptr(room) }.to_string_lossy().into_owned();
    let plain = unsafe { CStr::from_ptr(plain) }.to_string_lossy().into_owned();
    let to_send = enc_text(&plain).unwrap_or(plain);
    let fut = async move {
        let client = unsafe { NATS_CLIENT.clone().ok_or(()) }.map_err(|_| -2)?;
        let subject = format!("chat.room.{room}");
        client.publish(subject, to_send.into()).await.map_err(|_| -3)?;
        Ok::<i32, i32>(0)
    };
    RUNTIME.block_on(fut).unwrap_or_else(|e| e)
}

#[no_mangle] pub extern "C" fn ahla_nats_poll_json() -> *mut c_char {
    let mut st = STATE.lock();
    if let Some(line) = st.inbox.pop() {
        CString::new(line).unwrap().into_raw()
    } else {
        std::ptr::null_mut()
    }
}

// ---------------- JNI minimal (Android) ----------------
use jni::objects::{JClass, JString};
use jni::sys::{jstring, jint};
use jni::JNIEnv;

#[no_mangle]
pub extern "system" fn Java_com_ahla_core_AhlaCore_pubkeyHex(env: JNIEnv, _cls: JClass) -> jstring {
    ahla_kp_generate();
    let c = ahla_pubkey_hex();
    if c.is_null() { return std::ptr::null_mut(); }
    let s = unsafe { CStr::from_ptr(c) }.to_string_lossy().into_owned();
    ahla_string_free(c);
    env.new_string(s).unwrap().into_raw()
}

#[no_mangle]
pub extern "system" fn Java_com_ahla_core_AhlaCore_setPeerPubkey(env: JNIEnv, _cls: JClass, hex: JString) -> jint {
    let s: String = env.get_string(&hex).map(|v| v.into()).unwrap_or_default();
    ahla_set_peer_pubkey_hex(CString::new(s).unwrap().into_raw())
}
