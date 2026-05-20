'use client'
import * as nacl from 'tweetnacl'
import { useEffect, useState } from 'react'
import { bufToB64, b64ToBuf, sha256, bytesToHex } from '../../lib/crypto'
import { get, set } from 'idb-keyval'

export default function Verify(){
  const [pub,setPub]=useState(''); const [priv,setPriv]=useState(''); const [safety,setSafety]=useState('')
  useEffect(()=>{
    (async ()=>{
      let sk = await get('ahla_sk'); let pk = await get('ahla_pk')
      if(!sk || !pk){
        const kp = nacl.box.keyPair()
        sk = bufToB64(kp.secretKey); pk = bufToB64(kp.publicKey)
        await set('ahla_sk', sk); await set('ahla_pk', pk)
      }
      setPriv(sk as string); setPub(pk as string)
      const hash = await sha256(b64ToBuf(pk as string))
      setSafety(bytesToHex(hash).slice(0, 40))
    })()
  },[])
  return (<main style={{fontFamily:'system-ui',padding:24}}>
    <h1>التحقق من الأمان</h1>
    <p>هذا هو <b>مفتاح جهازك العام</b> (ملخّص):</p>
    <pre style={{background:'#f7f7f7',padding:12,borderRadius:8}}>{safety}</pre>
    <p>قارن هذا الملخص مع صديقك وجهًا لوجه (أو عبر مكالمة) للتحقق من الهوية (Safety Number).</p>
  </main>)
}