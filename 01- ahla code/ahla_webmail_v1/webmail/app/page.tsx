'use client'
import { signIn, signOut, useSession } from "next-auth/react"
import Link from "next/link"
export default function Page(){
  const {data:session,status} = useSession()
  if(status!=='authenticated'){
    return <div>
      <p>سجّل دخولك للبدء (@ahla.com عبر Keycloak)</p>
      <button onClick={()=>signIn('keycloak')}>تسجيل الدخول</button>
    </div>
  }
  return <div>
    <p>مرحبًا {session?.user?.name||'عضو أهلا'}</p>
    <div style={{display:'flex',gap:12,margin:'12px 0'}}>
      <Link href="/mail">📥 البريد الوارد</Link>
      <Link href="/compose">🖊️ إنشاء رسالة</Link>
      <Link href="/settings">⚙️ إعدادات</Link>
      <button onClick={()=>signOut()}>تسجيل الخروج</button>
    </div>
  </div>
}
