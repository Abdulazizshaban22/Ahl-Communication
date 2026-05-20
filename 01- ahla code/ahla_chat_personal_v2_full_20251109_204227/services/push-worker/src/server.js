import express from 'express'
import webpush from 'web-push'
import Redis from 'ioredis'

const app = express()
app.use(express.json())

const redis = new Redis(process.env.REDIS_URL || 'redis://redis:6379/0')
const vapidPublic = process.env.VAPID_PUBLIC_KEY || ''
const vapidPrivate = process.env.VAPID_PRIVATE_KEY || ''
if(vapidPublic && vapidPrivate){
  webpush.setVapidDetails('mailto:admin@example.com', vapidPublic, vapidPrivate)
}

app.post('/sendTest', async (req,res)=>{
  const user = req.body.user || 'me'
  const subs = await redis.smembers(`subs:${user}`)
  let sent=0, failed=0
  for(const s of subs){
    try{
      const sub = JSON.parse(s)
      await webpush.sendNotification(sub, JSON.stringify({ title:'Ahla', body:'Test push' }))
      sent++
    }catch(e){ failed++ }
  }
  res.json({ ok:true, sent, failed })
})

app.listen(process.env.PUSH_PORT||8787, ()=> console.log('push-worker on', process.env.PUSH_PORT||8787))