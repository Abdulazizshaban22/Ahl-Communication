import express from 'express';
import nodemailer from 'nodemailer';

const app = express();
app.use(express.json());

function buildTransport(){
  const { SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASS } = process.env;
  if (SMTP_HOST && SMTP_USER) {
    return nodemailer.createTransport({
      host: SMTP_HOST, port: Number(SMTP_PORT||587), secure: false,
      auth: { user: SMTP_USER, pass: SMTP_PASS }
    });
  }
  // Ethereal test account (dev)
  return nodemailer.createTestAccount().then(acc => nodemailer.createTransport({
    host: acc.smtp.host, port: acc.smtp.port, secure: acc.smtp.secure,
    auth: { user: acc.user, pass: acc.pass }
  }));
}

app.get('/health', (_,res)=>res.json({ok:true, service:'mail-api'}));

app.post('/send', async (req,res)=>{
  const { to, subject, text, html } = req.body||{};
  if(!to) return res.status(400).json({error:'to required'});
  const transport = await buildTransport();
  const info = await transport.sendMail({
    from: 'Ahla <noreply@ahla.local>',
    to, subject: subject||'Hello from Ahla', text: text||'Hello', html
  });
  res.json({ messageId: info.messageId, preview: nodemailer.getTestMessageUrl(info) });
});

app.listen(3004, ()=>console.log('mail-api:3004'));
