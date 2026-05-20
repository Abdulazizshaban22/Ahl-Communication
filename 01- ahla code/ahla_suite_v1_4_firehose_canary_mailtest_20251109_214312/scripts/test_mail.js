
// Test SES SMTP send + WorkMail IMAP receive
// Usage: node scripts/test_mail.js
import nodemailer from 'nodemailer'
import { ImapFlow } from 'imapflow'

const {
  SMTP_HOST, SMTP_PORT='587', SMTP_USER, SMTP_PASS,
  IMAP_HOST, IMAP_PORT='993', IMAP_USER, IMAP_PASS, TO
} = process.env

async function main(){
  const tx = nodemailer.createTransport({
    host: SMTP_HOST, port: Number(SMTP_PORT), secure: false,
    auth: { user: SMTP_USER, pass: SMTP_PASS }
  })

  const to = TO || IMAP_USER
  const subject = 'Ahla Mail — SES test ' + new Date().toISOString()
  const text = 'Hello from Ahla via SES SMTP.'

  console.log('Sending email to', to)
  await tx.sendMail({ from: SMTP_USER, to, subject, text })
  console.log('Sent. Waiting 10s…'); await new Promise(r=>setTimeout(r,10000))

  const imap = new ImapFlow({
    host: IMAP_HOST, port: Number(IMAP_PORT), secure: true,
    auth: { user: IMAP_USER, pass: IMAP_PASS }
  })
  await imap.connect(); await imap.mailboxOpen('INBOX')
  let found = false
  for await (let msg of imap.fetch({ seen:false, changedSince:0 }, { envelope:true })){
    if((msg.envelope.subject||'').includes('Ahla Mail — SES test')){ found = true; break }
  }
  await imap.logout()
  console.log(found ? '✅ Delivery ok (IMAP received)' : '⚠️ Not found yet — check routing/DNS/allowlists.')
}
main().catch(e=>{ console.error(e); process.exit(1) })
