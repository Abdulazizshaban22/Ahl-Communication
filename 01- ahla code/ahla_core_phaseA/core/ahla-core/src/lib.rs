use std::ffi::{CStr, CString};
use std::os::raw::{c_char, c_uchar};

#[no_mangle]
pub extern "C" fn ahla_init() {}

#[no_mangle]
pub extern "C" fn ahla_echo(input: *const c_char) -> *mut c_char {
    if input.is_null() { return std::ptr::null_mut(); }
    let s = unsafe { CStr::from_ptr(input) }.to_string_lossy().into_owned();
    CString::new(format!("Ahla says: {}", s)).unwrap().into_raw()
}

#[no_mangle]
pub extern "C" fn ahla_string_free(ptr: *mut c_char) {
    if ptr.is_null() { return; }
    unsafe { let _ = CString::from_raw(ptr); }
}

#[repr(C)]
pub struct AhlaBuf {
    pub ptr: *mut c_uchar,
    pub len: usize,
    pub cap: usize,
}

#[no_mangle]
pub extern "C" fn ahla_encrypt_xor(data: *const c_uchar, len: usize, key: u8) -> AhlaBuf {
    if data.is_null() || len == 0 {
        return AhlaBuf { ptr: std::ptr::null_mut(), len: 0, cap: 0 };
    }
    let slice = unsafe { std::slice::from_raw_parts(data, len) };
    let mut out = slice.to_vec();
    for b in &mut out { *b ^= key; }
    let mut v = out.into_boxed_slice();
    let ptr = v.as_mut_ptr();
    let len = v.len();
    let cap = len;
    std::mem::forget(v);
    AhlaBuf { ptr, len, cap }
}

#[no_mangle]
pub extern "C" fn ahla_buf_free(buf: AhlaBuf) {
    if buf.ptr.is_null() { return; }
    unsafe { let _ = Vec::from_raw_parts(buf.ptr, buf.len, buf.cap); }
}

// -------- JNI for Android --------
use jni::objects::{JClass, JString};
use jni::sys::{jbyte, jbyteArray, jstring};
use jni::JNIEnv;

#[no_mangle]
pub extern "system" fn Java_com_ahla_core_AhlaCore_echo(env: JNIEnv, _class: JClass, input: JString) -> jstring {
    let s: String = env.get_string(&input).map(|v| v.into()).unwrap_or_default();
    let out = env.new_string(format!("Ahla says: {}", s)).unwrap();
    out.into_raw()
}

#[no_mangle]
pub extern "system" fn Java_com_ahla_core_AhlaCore_encryptXor(env: JNIEnv, _class: JClass, input: jbyteArray, key: jbyte) -> jbyteArray {
    let bytes = env.convert_byte_array(input).unwrap_or_default();
    let out: Vec<u8> = bytes.into_iter().map(|b| (b as u8) ^ (key as u8)).collect();
    env.byte_array_from_slice(&out).unwrap()
}
