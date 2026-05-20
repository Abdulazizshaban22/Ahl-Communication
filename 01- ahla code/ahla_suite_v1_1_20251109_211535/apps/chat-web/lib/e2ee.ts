
import nacl from 'tweetnacl'
import * as idb from 'idb-keyval'

type KeyBundle = { idPub: string, idPriv: Uint8Array, prePub: string, prePriv: Uint8Array }
const enc = new TextEncoder(); const dec = new TextDecoder()

function b64(b:Uint8Array){ return btoa(String.fromCharCode(...b)) }
function ub64(s:string){ return new Uint8Array([...atob(s)].map(c=>c.charCodeAt(0))) }

export async function ensureIdentity():Promise<KeyBundle>{
  let kp = await idb.get('e2ee:keypair')
  if(!kp){
    const id = nacl.box.keyPair()
    const pre = nacl.box.keyPair()
    kp = { idPub:b64(id.publicKey), idPriv:id.privateKey, prePub:b64(pre.publicKey), prePriv:pre.privateKey }
    await idb.set('e2ee:keypair', kp)
  }
  return kp
}

export function safetyNumber(peerPubB64:string, myPubB64:string){
  // simple SHA-256 fingerprint
  const txt = `ahla:${peerPubB64}:${myPubB64}`
  const buf = enc.encode(txt)
  return crypto.subtle.digest('SHA-256', buf).then(a=>Array.from(new Uint8Array(a)).map(x=>x.toString(16).padStart(2,'0')).join(''))
}

export function seal(remotePubB64:string, msg:string){
  const eph = nacl.box.keyPair()
  const nonce = nacl.randomBytes(24)
  const ct = nacl.box(enc.encode(msg), nonce, ub64(remotePubB64), eph.secretKey)
  return { ephPub:b64(eph.publicKey), nonce:b64(nonce), ct:b64(ct) }
}

export function open(myPriv:Uint8Array, ephPubB64:string, nonceB64:string, ctB64:string){
  const res = nacl.box.open(ub64(ctB64), ub64(nonceB64), ub64(ephPubB64), myPriv)
  if(!res) return null
  return dec.decode(res)
}
