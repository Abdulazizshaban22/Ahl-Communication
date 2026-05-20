import "./globals.css"
import type { Metadata } from "next"

export const metadata: Metadata = {
  title: "Ahla — Minimal Luxury Chat",
  description: "WhatsApp-style simplicity with sovereign tech luxury",
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="ar" dir="rtl">
      <body className="bg-ahla-beige text-gray-900 antialiased">{children}</body>
    </html>
  )
}
