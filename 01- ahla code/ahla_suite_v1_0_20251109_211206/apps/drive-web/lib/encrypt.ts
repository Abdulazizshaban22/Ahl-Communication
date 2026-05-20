
export async function encryptFile(file:File, pass='ahla'){
  const keyMaterial=await crypto.subtle.importKey('raw', new TextEncoder().encode(pass), 'PBKDF2', false, ['deriveKey'])
  const salt=crypto.getRandomValues(new Uint8Array(16))
  const key=await crypto.subtle.deriveKey({name:'PBKDF2',salt,iterations:100000,hash:'SHA-256'}, keyMaterial, {name:'AES-GCM',length:256}, false, ['encrypt'])
  const iv=crypto.getRandomValues(new Uint8Array(12))
  const buf=new Uint8Array(await file.arrayBuffer())
  const ct=await crypto.subtle.encrypt({name:'AES-GCM',iv},key,buf)
  return { blob:new Blob([new Uint8Array(ct)]), iv, salt }
}
