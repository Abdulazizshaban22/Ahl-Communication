import express from 'express';
import { S3Client, PutObjectCommand, GetObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';

const app = express();
app.use(express.json());

const BUCKET = process.env.S3_BUCKET;
const REGION = process.env.AWS_REGION || 'me-central-1';

if (!BUCKET) {
  console.error('Missing env S3_BUCKET'); process.exit(1);
}

const s3 = new S3Client({ region: REGION }); // Credentials from task role

app.get('/health', (_,res)=>res.json({ok:true, service:'drive-api', bucket: BUCKET }));

app.post('/presign/put', async (req,res)=>{
  const { key, contentType } = req.body || {};
  if(!key) return res.status(400).json({error:'key required'});
  const cmd = new PutObjectCommand({ Bucket: BUCKET, Key: key, ContentType: contentType || 'application/octet-stream' });
  const url = await getSignedUrl(s3, cmd, { expiresIn: 900 });
  res.json({ url, key });
});

app.post('/presign/get', async (req,res)=>{
  const { key } = req.body || {};
  if(!key) return res.status(400).json({error:'key required'});
  const cmd = new GetObjectCommand({ Bucket: BUCKET, Key: key });
  const url = await getSignedUrl(s3, cmd, { expiresIn: 900 });
  res.json({ url, key });
});

app.listen(3002, ()=>console.log('drive-api:3002 (S3)'));
