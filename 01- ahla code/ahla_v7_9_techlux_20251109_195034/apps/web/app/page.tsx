import Link from "next/link"

export default function Home() {
  return (
    <div className="min-h-screen flex items-center justify-center">
      <div className="p-8 rounded-3xl bg-white/60 backdrop-blur-md shadow-glass border border-white/40">
        <h1 className="text-2xl font-semibold mb-2 text-ahla-green">أهلا — الدردشة الفاخرة البسيطة</h1>
        <p className="text-gray-600 mb-6">واجهة شبيهة بواتساب، لكن بذكاء سيادي.</p>
        <Link className="px-5 py-2.5 rounded-xl bg-ahla-green text-white" href="/chat">ابدأ الدردشة</Link>
      </div>
    </div>
  )
}
