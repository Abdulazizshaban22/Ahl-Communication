'use client'
import { useState } from 'react'
import { pbkdf2Key, aesGcmEncrypt, aesGcmDecrypt, bufToB64, b64ToBuf } from '../../lib/crypto'

export default function Backup(){
  const [log,setLog]=useState<string>('')

  async function exportEnc(){
    const sample = { hello:'ahla', ts: Date.now() }
    const pass = prompt('كلمة مرور النسخة:') || ''
    const salt = crypto.getRandomValues(new Uint8Array(16))
    const key  = await pbkdf2Key(pass, salt)
    const { iv, ct } = await aesGcmEncrypt(key, new TextEncoder().encode(JSON.stringify(sample)))
    const pack = { salt: bufToB64(salt), iv: bufToB64(iv), data: bufToB64(ct) }
    const blob = new Blob([JSON.stringify(pack)], { type:'application/json' })
    const a = document.createElement('a'); a.href = URL.createObjectURL(blob); a.download = `ahla_enc_backup_${Date.now()}.json`; a.click()
  }
  async function importEnc(e:any){
    const file = e.target.files?.[0]; if(!file) return
    const text = await file.text()
    const pack = JSON.parse(text)
    const pass = prompt('أدخل كلمة المرور:') || ''
    const key  = await pbkdf2Key(pass, b64ToBuf(pack.salt))
    const pt   = await aesGcmDecrypt(key, b64ToBuf(pack.iv), b64ToBuf(pack.data))
    setLog(new TextDecoder().decode(pt))
  }

  return (<main style={{fontFamily:'system-ui',padding:24}}>
    <h1>نسخ احتياطي مشفّر (تجريبي)</h1>
    <p>يجري التشفير بالكامل داخل المتصفح (AES‑GCM + PBKDF2/SHA‑256).</p>
    <div style={{display:'flex',gap:8}}>
      <button onClick={exportEnc}>تصدير نسخة</button>
      <label style={{border:'1px solid #ccc',padding:'6px 8px',borderRadius:8,cursor:'pointer'}}>استيراد
        <input type="file" accept="application/json" style={{display:'none'}} onChange={importEnc}/>
      </label>
    </div>
    <pre style={{background:'#f7f7f7',padding:12,marginTop:12,borderRadius:8}}>{log}</pre>
  </main>)
}