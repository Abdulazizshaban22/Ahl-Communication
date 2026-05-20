
export async function pbkdf2Key(pass:string,salt:Uint8Array,iterations=200000){
  const enc = new TextEncoder()
  const baseKey = await crypto.subtle.importKey('raw',enc.encode(pass),'PBKDF2',false,['deriveKey'])
  return await crypto.subtle.deriveKey({name:'PBKDF2',hash:'SHA-256',salt,iterations},{name:'AES-GCM',length:256},false,['encrypt','decrypt'])
}
