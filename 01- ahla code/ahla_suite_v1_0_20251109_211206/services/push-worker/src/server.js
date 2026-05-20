
import express from 'express'
import webpush from 'web-push'
import Redis from 'ioredis'

const app = express()
app.use(express.json())

const redis = new Redis(process.env.REDIS_URL || 'redis://redis:6379/0')
const publicKey  = process.env.VAPID_PUBLIC_KEY  || ''
const privateKey = process.env.VAPID_PRIVATE_KEY || ''

if(publicKey && privateKey){
  webpush.setVapidDetails('mailto:admin@example.com', publicKey, privateKey)
} else {
  console.warn('[push] VAPID not set — disabled')
}

app.post('/sendTo', async (req,res)=>{
  const user = req.body.user || 'me'
  const payload = JSON.stringify({ title: 'Ahla', body: req.body.body || 'New', url: '/chat/' })
  const subs = await redis.smembers(`subs:${user}`)
  let sent=0, failed=0
  for(const s of subs){
    try{ await webpush.sendNotification(JSON.parse(s), payload); sent++ }catch(e){ failed++ }
  }
  res.json({ ok:true, sent, failed })
})

app.listen(process.env.PUSH_PORT||8787, ()=> console.log('push on', process.env.PUSH_PORT||8787))
