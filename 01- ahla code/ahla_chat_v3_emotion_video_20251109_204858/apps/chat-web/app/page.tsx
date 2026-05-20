'use client'
import Link from 'next/link'
export default function Home(){
  return (<main style={{fontFamily:'system-ui',padding:24}}>
    <h1>Ahla Chat — v3</h1>
    <ul>
      <li><Link href="/chat/moments">Ahla Moments (فيديو قصير)</Link></li>
      <li><Link href="/chat/verify">تحقق الأمان (Safety Number)</Link></li>
      <li><Link href="/chat/settings">إعدادات الغرفة/الاختفاء</Link></li>
    </ul>
    <p>هذه واجهة تجريبية للميزات الجديدة (v3). يمكن دمجها مع واجهة v2 التي سلّمناها.</p>
  </main>)
}