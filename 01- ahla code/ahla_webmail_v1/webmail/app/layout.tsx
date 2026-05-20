import './globals.css'
export const metadata = { title: 'Ahla Webmail', description: 'JMAP Webmail for @ahla.com' }
export default function RootLayout({children}:{children:React.ReactNode}){
  return (<html dir="rtl" lang="ar"><body><div style={{maxWidth:960,margin:'24px auto',padding:16}}>
    <h2>📬 Ahla Webmail</h2>{children}</div></body></html>)
}
