export default function RootLayout({ children }:{children:React.ReactNode}){
  return (
    <html dir="rtl" lang="ar">
      <body style={{fontFamily:'system-ui, sans-serif', background:'#f7f7f7'}}>
        <div style={{maxWidth:900, margin:'40px auto', background:'#fff', borderRadius:16, padding:20, boxShadow:'0 2px 14px rgba(0,0,0,.06)'}}>
          <h2>Ahla — الدردشة الذكية</h2>
          {children}
        </div>
      </body>
    </html>
  )
}