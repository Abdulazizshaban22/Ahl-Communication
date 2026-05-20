
import * as openpgp from 'openpgp'
export async function ensureKeys(){
  let kp = localStorage.getItem('ahla:mail:pgp')
  if(kp) return JSON.parse(kp)
  const { privateKey, publicKey } = await openpgp.generateKey({
    type:'rsa', rsaBits:2048, userIDs:[{name:'Ahla User'}], passphrase:''
  })
  const bundle = { publicKey, privateKey }
  localStorage.setItem('ahla:mail:pgp', JSON.stringify(bundle))
  return bundle
}
export async function encryptFor(pubArmored:string, text:string){
  const pub = await openpgp.readKey({ armoredKey: pubArmored })
  const msg = await openpgp.createMessage({ text })
  return await openpgp.encrypt({ message: msg, encryptionKeys: pub })
}
export async function decryptWith(privArmored:string, data:string){
  const priv = await openpgp.readPrivateKey({ armoredKey: privArmored })
  const msg = await openpgp.readMessage({ armoredMessage: data })
  const { data: text } = await openpgp.decrypt({ message: msg, decryptionKeys: priv })
  return text as string
}
