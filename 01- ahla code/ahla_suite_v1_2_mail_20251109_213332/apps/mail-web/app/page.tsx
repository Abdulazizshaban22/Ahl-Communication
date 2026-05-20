
'use client'
import { useEffect, useState } from 'react'
import { ensureKeys, encryptFor, decryptWith } from '../lib/pgp'

type Mail = { id:string, from:string, subject:string, date:string, bodyPreview?:string, raw?:string }

export default function Mail(){
  const [mails,setMails]=useState<Mail[]>([])
  const [sel,setSel]=useState<Mail|null>(null)
  const [to,setTo]=useState('')
  const [subject,setSubject]=useState('')
  const [body,setBody]=useState('')
  const [usePGP,setUsePGP]=useState(false)
  const [myPub,setMyPub]=useState(''); const [myPriv,setMyPriv]=useState('')

  useEffect(()=>{
    (async()=>{
      const kp = await ensureKeys()
      setMyPub(kp.publicKey); setMyPriv(kp.privateKey)
      refresh()
    })()
  },[])

  const refresh = async ()=>{
    const res = await fetch('/api/mail/messages?mailbox=INBOX&limit=50').then(r=>r.json()).catch(()=>[])
    setMails(res)
  }

  const openMail = async (m:Mail)=>{
    setSel(m)
    if(m.raw && m.raw.startsWith('-----BEGIN PGP MESSAGE-----')){
      try{
        const text = await decryptWith(myPriv, m.raw)
        setSel({...m, bodyPreview: text })
      }catch(e){ console.warn('PGP decrypt failed', e) }
    }
  }

  const send = async ()=>{
    let content = body
    if(usePGP){
      // demo: encrypt to self (replace with recipient pub key later)
      content = await encryptFor(myPub, body)
    }
    await fetch('/api/mail/send',{method:'POST',headers:{'Content-Type':'application/json'},
      body:JSON.stringify({ to, subject, text: content }) })
    setTo(''); setSubject(''); setBody('')
  }

  return <main style={{fontFamily:'system-ui',display:'grid',gridTemplateColumns:'280px 1fr',height:'100vh'}}>
    <aside style={{borderRight:'1px solid #eee',padding:12}}>
      <h3>Inbox</h3>
      <button onClick={refresh} style={{marginBottom:8}}>تحديث</button>
      <div style={{overflow:'auto',height:'calc(100vh - 120px)'}}>
        {mails.map(m=><div key={m.id} onClick={()=>openMail(m)}
          style={{padding:'8px 6px',borderBottom:'1px solid #f0f0f0',cursor:'pointer',background: sel?.id===m.id?'#f7fffa':''}}>
          <div style={{fontWeight:600}}>{m.subject||'(بدون عنوان)'}</div>
          <div style={{fontSize:12,opacity:.7}}>{m.from}</div>
          <div style={{fontSize:12,opacity:.6}}>{m.bodyPreview||''}</div>
        </div>)}
      </div>
      <div style={{marginTop:8,fontSize:12,opacity:.7}}>
        <div><b>PGP Public:</b></div>
        <textarea readOnly value={myPub} style={{width:'100%',height:80}}/>
      </div>
    </aside>
    <section style={{padding:12,display:'grid',gridTemplateRows:'auto 1fr auto',gap:8}}>
      <div>
        <h2>قراءة</h2>
        {sel ? <div><div><b>From:</b> {sel.from}</div><div><b>Subject:</b> {sel.subject}</div><pre style={{whiteSpace:'pre-wrap',background:'#fafafa',padding:12,borderRadius:8}}>{sel.bodyPreview||'(PGP/نص)'}</pre></div> : <i>اختر رسالة من اليسار…</i>}
      </div>
      <div style={{borderTop:'1px solid #eee',paddingTop:8}}>
        <h2>إرسال</h2>
        <div style={{display:'grid',gridTemplateColumns:'1fr 1fr',gap:8,marginBottom:8}}>
          <input placeholder="to@example.com" value={to} onChange={e=>setTo(e.target.value)} style={{padding:8}}/>
          <input placeholder="الموضوع" value={subject} onChange={e=>setSubject(e.target.value)} style={{padding:8}}/>
        </div>
        <textarea placeholder="اكتب رسالتك…" value={body} onChange={e=>setBody(e.target.value)} style={{width:'100%',height:120,padding:8}}/>
        <div style={{display:'flex',alignItems:'center',gap:8,marginTop:6}}>
          <label><input type="checkbox" checked={usePGP} onChange={e=>setUsePGP(e.target.checked)}/> تشفير PGP</label>
          <button onClick={send} style={{padding:'10px 16px'}}>إرسال</button>
        </div>
      </div>
    </section>
  </main>
}
