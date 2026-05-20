import fetch from 'node-fetch';
import { parse } from 'yaml';

const GRAFANA_URL = process.env.GRAFANA_URL;
const GRAFANA_TOKEN = process.env.GRAFANA_TOKEN;
const GIT_SILENCE_URL = process.env.GIT_SILENCE_URL || ""; // raw Git URL to YAML (array of silences)
const S3_BUCKET = process.env.S3_BUCKET || "";
const S3_KEY = process.env.S3_KEY || "";

async function fetchYaml() {
  if (GIT_SILENCE_URL) {
    const res = await fetch(GIT_SILENCE_URL);
    return await res.text();
  }
  if (S3_BUCKET && S3_KEY) {
    const AWS = await import('aws-sdk');
    const s3 = new AWS.S3();
    const obj = await s3.getObject({ Bucket: S3_BUCKET, Key: S3_KEY }).promise();
    return obj.Body.toString('utf-8');
  }
  throw new Error("No source configured (GIT_SILENCE_URL or S3_BUCKET/S3_KEY)");
}

async function createSilence(s) {
  const payload = {
    matchers: s.matchers || [{"name":"service","value":"chat|meet|drive|mail","isRegex":true}],
    startsAt: s.startsAt,
    endsAt: s.endsAt,
    createdBy: s.createdBy || "ahla-gitops",
    comment: s.comment || "GitOps silence"
  };
  const res = await fetch(`${GRAFANA_URL}/api/alertmanager/grafana/api/v2/silences`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${GRAFANA_TOKEN}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(payload)
  });
  if (!res.ok) {
    const txt = await res.text();
    throw new Error(`Grafana silence failed: ${res.status} ${txt}`);
  }
  return res.json();
}

export const handler = async () => {
  const yml = await fetchYaml();
  const arr = parse(yml);
  const out = [];
  for (const s of arr) {
    out.push(await createSilence(s));
  }
  return { ok: true, created: out.length };
};
