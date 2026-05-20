
import nacl from 'tweetnacl'
import * as idb from 'idb-keyval'
const enc = new TextEncoder(); const dec = new TextDecoder()
function b64(b:Uint8Array){ return btoa(String.fromCharCode(...b)) }
function ub64(s:string){ return new Uint8Array([...atob(s)].map(c=>c.charCodeAt(0))) }
export async function ensureIdentity(){
  let kp = await idb.get('e2ee:keypair')
  if(!kp){ const id = nacl.box.keyPair(); kp={ pub:b64(id.publicKey), priv:id.secretKey }; await idb.set('e2ee:keypair',kp) }
  return kp
}
export function seal(remotePubB64:string, msg:string){
  const eph = nacl.box.keyPair(); const nonce = nacl.randomBytes(24)
  const ct = nacl.box(enc.encode(msg), nonce, ub64(remotePubB64), eph.secretKey)
  return { eph:b64(eph.publicKey), n:b64(nonce), c:b64(ct) }
}
export function open(priv:Uint8Array, ephB64:string, nB64:string, cB64:string){
  const res = nacl.box.open(new Uint8Array([...atob(cB64)].map(c=>c.charCodeAt(0))),
    new Uint8Array([...atob(nB64)].map(c=>c.charCodeAt(0))),
    new Uint8Array([...atob(ephB64)].map(c=>c.charCodeAt(0))), priv)
  return res? dec.decode(res): null
}
