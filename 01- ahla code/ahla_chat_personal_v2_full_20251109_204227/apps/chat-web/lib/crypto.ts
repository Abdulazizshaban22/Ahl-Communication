export function b64uToBuf(b64u:string){
  const pad = '='.repeat((4 - b64u.length % 4) % 4);
  const b64 = (b64u + pad).replace(/-/g, '+').replace(/_/g, '/');
  const raw = atob(b64);
  return new Uint8Array([...raw].map(c=>c.charCodeAt(0)));
}
export function bufToB64u(buf:Uint8Array){
  const b64 = btoa(String.fromCharCode(...buf));
  return b64.replace(/\+/g,'-').replace(/\//g,'_').replace(/=+$/,'');
}
export async function importAesKeyFromRaw(raw:Uint8Array){
  return await crypto.subtle.importKey('raw', raw, 'AES-GCM', false, ['encrypt','decrypt']);
}
export async function sha256(buf:Uint8Array){
  const h = await crypto.subtle.digest('SHA-256', buf);
  return new Uint8Array(h);
}
export async function aesEncrypt(key:CryptoKey, data:ArrayBuffer){
  const iv = crypto.getRandomValues(new Uint8Array(12));
  const ct = await crypto.subtle.encrypt({name:'AES-GCM', iv}, key, data);
  return { iv, ct:new Uint8Array(ct) };
}
export async function aesDecrypt(key:CryptoKey, iv:Uint8Array, ct:Uint8Array){
  const pt = await crypto.subtle.decrypt({name:'AES-GCM', iv}, key, ct);
  return new Uint8Array(pt);
}