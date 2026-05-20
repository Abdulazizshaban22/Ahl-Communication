import express from 'express';
import { FirehoseClient, PutRecordCommand } from "@aws-sdk/client-firehose";

const app = express();
app.use(express.json());

const STREAM = process.env.FIREHOSE_STREAM || "ahla-audit-firehose";
const REGION = process.env.AWS_REGION || "me-central-1";
const firehose = new FirehoseClient({ region: REGION });

app.get("/health", (_,res)=> res.json({ ok:true, service:"audit-api" }));

// Example event categories: consent, dsr, access, incident, breach, processing
app.post("/audit", async (req,res)=>{
  const evt = req.body || {};
  evt.ts = evt.ts || new Date().toISOString();
  try {
    const cmd = new PutRecordCommand({
      DeliveryStreamName: STREAM,
      Record: { Data: Buffer.from(JSON.stringify(evt) + "\n") }
    });
    await firehose.send(cmd);
    res.status(202).json({ ok: true });
  } catch (e) {
    console.error(e);
    res.status(500).json({ ok:false, error: e.message });
  }
});

app.listen(3010, ()=> console.log("audit-api:3010"));
