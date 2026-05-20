
import express from 'express'
import cors from 'cors'
import bodyParser from 'body-parser'
import { ImapFlow } from 'imapflow'
import nodemailer from 'nodemailer'

const app = express()
app.use(cors()); app.use(bodyParser.json({limit:'5mb'}))

const IMAP_HOST = process.env.IMAP_HOST || 'localhost'
const IMAP_PORT = Number(process.env.IMAP_PORT || 3143)
const IMAP_SECURE = (process.env.IMAP_SECURE || 'false') === 'true'
const SMTP_HOST = process.env.SMTP_HOST || 'localhost'
const SMTP_PORT = Number(process.env.SMTP_PORT || 3025)
const SMTP_SECURE = (process.env.SMTP_SECURE || 'false') === 'true'
const MAIL_USER = process.env.MAIL_USER || 'user@ahla.local'
const MAIL_PASS = process.env.MAIL_PASS || 'secret'

function imapClient(){
  return new ImapFlow({
    host: IMAP_HOST, port: IMAP_PORT, secure: IMAP_SECURE,
    auth: { user: MAIL_USER, pass: MAIL_PASS }
  })
}

function smtpClient(){
  return nodemailer.createTransport({
    host: SMTP_HOST, port: SMTP_PORT, secure: SMTP_SECURE,
    auth: { user: MAIL_USER, pass: MAIL_PASS }
  })
}

app.get('/health', (req,res)=> res.json({ok:true}))
app.get('/messages', async (req,res)=>{
  const mailbox = req.query.mailbox || 'INBOX'
  const limit = Number(req.query.limit || 50)
  const client = imapClient()
  try{
    await client.connect(); await client.mailboxOpen(mailbox)
    const list = []
    for await (let msg of client.fetch({ seen:false, changedSince:0 }, { uid:true, envelope:true, bodyStructure:true, source:true })){
      list.push({
        id: String(msg.uid),
        from: (msg.envelope.from && msg.envelope.from[0] && (msg.envelope.from[0].address||msg.envelope.from[0].name)) || 'unknown',
        subject: msg.envelope.subject || '',
        date: msg.envelope.date ? new Date(msg.envelope.date).toISOString() : '',
        bodyPreview: (msg.source||'').toString().slice(0,240),
        raw: (msg.source||'').toString()
      })
      if(list.length>=limit) break
    }
    res.json(list)
  }catch(e){ res.status(500).json({error:String(e)}) } finally { client.close() }
})

app.post('/send', async (req,res)=>{
  const { to, subject, text } = req.body
  try{
    const tx = smtpClient()
    await tx.sendMail({ from: MAIL_USER, to, subject, text })
    res.json({ ok:true })
  }catch(e){ res.status(500).json({error:String(e)}) }
})

const PORT = process.env.PORT || 8300
app.listen(PORT, ()=> console.log('mail-api on', PORT))
