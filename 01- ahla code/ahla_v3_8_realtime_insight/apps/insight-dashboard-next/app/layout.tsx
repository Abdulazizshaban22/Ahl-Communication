export const metadata = { title: 'Ahla Intelligence Live', description: 'Realtime Insight' };
export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="ar" dir="rtl">
      <body style={{fontFamily:'system-ui', background:'#0b0d12', color:'#e7e9ee'}}>{children}</body>
    </html>
  );
}
