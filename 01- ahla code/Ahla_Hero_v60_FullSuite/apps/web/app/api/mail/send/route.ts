import { NextResponse } from "next/server";
import { mailer } from "@/lib/mail";

export async function POST(req: Request) {
  const { to, subject, html } = await req.json();
  await mailer.sendMail({ from: process.env.SMTP_FROM!, to, subject, html });
  return NextResponse.json({ ok: true });
}
