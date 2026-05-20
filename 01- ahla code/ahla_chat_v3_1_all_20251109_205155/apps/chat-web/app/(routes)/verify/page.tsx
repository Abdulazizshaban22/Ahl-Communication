'use client'
import * as nacl from 'tweetnacl'
import { useEffect, useState } from 'react'
import { b64ToBuf } from '../../lib/crypto'
import { get, set } from 'idb-keyval'

function bufToB64(buf:Uint8Array){ return btoa(String.fromCharCode(...buf)) }
async function sha256(buf:Uint8Array){ const h = await crypto.subtle.digest('SHA-256', buf); return new Uint8Array(h) }
function bytesToHex(arr:Uint8Array){ return Array.from(arr).map(b=>b.toString(16).padStart(2,'0')).join('') }

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
    <h1>التحقق من الأمان — Safety Number</h1>
    <p>هذا هو <b>ملخّص المفتاح العام</b> لجهازك:</p>
    <pre style={{background:'#f7f7f7',padding:12,borderRadius:8}}>{safety}</pre>
    <p>قارن الرقم مع الطرف الآخر.</p>
  </main>)
}