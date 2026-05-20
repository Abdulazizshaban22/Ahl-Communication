
import express from 'express'
import webpush from 'web-push'
const app = express(); app.use(express.json())
const pub=process.env.VAPID_PUBLIC_KEY||'', priv=process.env.VAPID_PRIVATE_KEY||''
if(pub && priv){ webpush.setVapidDetails('mailto:admin@example.com', pub, priv) }
app.post('/sendTo', async (req,res)=>{ res.json({ok:true}) })
app.listen(process.env.PUSH_PORT||8787, ()=> console.log('push on', process.env.PUSH_PORT||8787))
