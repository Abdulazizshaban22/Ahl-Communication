import express from 'express'
import { createProxyMiddleware } from 'http-proxy-middleware'
const app = express()

app.use('/api/chat', createProxyMiddleware({ target:'http://chat-api:8000', changeOrigin:true, pathRewrite:{'^/api/chat':''} }))
app.use('/api/meet', createProxyMiddleware({ target:'http://meet-api:8020', changeOrigin:true, pathRewrite:{'^/api/meet':''} }))
app.use('/api/drive', createProxyMiddleware({ target:'http://drive-api:8030', changeOrigin:true, pathRewrite:{'^/api/drive':''} }))
app.use('/api/biz', createProxyMiddleware({ target:'http://business-api:8040', changeOrigin:true, pathRewrite:{'^/api/biz':''} }))
app.use('/api/mail', createProxyMiddleware({ target:'http://mail-api:8050', changeOrigin:true, pathRewrite:{'^/api/mail':''} }))

app.get('/health', (_req,res)=> res.json({ok:true}))
app.listen(8060, ()=> console.log('omni-gateway on 8060'))
