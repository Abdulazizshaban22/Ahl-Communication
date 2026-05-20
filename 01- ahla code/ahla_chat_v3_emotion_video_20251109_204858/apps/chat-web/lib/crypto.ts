export function bufToB64(buf:Uint8Array){ return btoa(String.fromCharCode(...buf)) }
export function b64ToBuf(b64:string){ return new Uint8Array(atob(b64).split('').map(c=>c.charCodeAt(0))) }
export async function sha256(buf:Uint8Array){
  const h = await crypto.subtle.digest('SHA-256', buf); return new Uint8Array(h);
}
export function bytesToHex(arr:Uint8Array){
  return Array.from(arr).map(b=>b.toString(16).padStart(2,'0')).join('')
}