import express from 'express';
import { S3Client, PutObjectCommand, GetObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';

const app = express();
app.use(express.json());

const {
  MINIO_ENDPOINT='minio',
  MINIO_PORT='9000',
  MINIO_ACCESS_KEY='ahla',
  MINIO_SECRET_KEY='ahla12345',
  MINIO_BUCKET='ahla-drive',
  AWS_REGION='me-central-1'
} = process.env;

const s3 = new S3Client({
  region: AWS_REGION,
  endpoint: `http://${MINIO_ENDPOINT}:${MINIO_PORT}`,
  forcePathStyle: true,
  credentials: { accessKeyId: MINIO_ACCESS_KEY, secretAccessKey: MINIO_SECRET_KEY }
});

app.get('/health', (_,res)=>res.json({ok:true, service:'drive-api'}));

app.post('/presign/put', async (req,res)=>{
  const { key, contentType } = req.body || {};
  if(!key) return res.status(400).json({error:'key required'});
  const cmd = new PutObjectCommand({ Bucket: MINIO_BUCKET, Key: key, ContentType: contentType || 'application/octet-stream' });
  const url = await getSignedUrl(s3, cmd, { expiresIn: 900 });
  res.json({ url, key });
});

app.post('/presign/get', async (req,res)=>{
  const { key } = req.body || {};
  if(!key) return res.status(400).json({error:'key required'});
  const cmd = new GetObjectCommand({ Bucket: MINIO_BUCKET, Key: key });
  const url = await getSignedUrl(s3, cmd, { expiresIn: 900 });
  res.json({ url, key });
});

app.listen(3002, ()=>console.log('drive-api:3002'));
