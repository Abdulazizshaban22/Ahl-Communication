export function b64ToBuf(b64:string){ return new Uint8Array(atob(b64).split('').map(c=>c.charCodeAt(0))) }
export function bufToB64(buf:Uint8Array){ return btoa(String.fromCharCode(...buf)) }
export async function pbkdf2Key(pass:string, salt:Uint8Array, iterations=200000){
  const enc = new TextEncoder()
  const baseKey = await crypto.subtle.importKey('raw', enc.encode(pass), 'PBKDF2', false, ['deriveKey'])
  return await crypto.subtle.deriveKey(
    { name:'PBKDF2', hash:'SHA-256', salt, iterations },
    baseKey,
    { name:'AES-GCM', length:256 },
    false, ['encrypt','decrypt']
  )
}
export async function aesGcmEncrypt(key:CryptoKey, data:Uint8Array){
  const iv = crypto.getRandomValues(new Uint8Array(12))
  const ct = await crypto.subtle.encrypt({ name:'AES-GCM', iv }, key, data)
  return { iv, ct: new Uint8Array(ct) }
}
export async function aesGcmDecrypt(key:CryptoKey, iv:Uint8Array, ct:Uint8Array){
  const pt = await crypto.subtle.decrypt({ name:'AES-GCM', iv }, key, ct)
  return new Uint8Array(pt)
}