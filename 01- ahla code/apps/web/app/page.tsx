import Link from 'next/link'
export default function Home(){
  return <div>
    <p>مرحبًا! هذه تجربة مبسطة لدمج واجهة الدردشة مع محرك المشاعر.</p>
    <ul>
      <li><Link href="/chat">افتح الدردشة الآن</Link></li>
    </ul>
  </div>
}