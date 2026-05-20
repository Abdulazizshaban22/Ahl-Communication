// apps/webmail/app/api/jmap/upload/route.ts
import { NextRequest, NextResponse } from 'next/server';

export const runtime = 'edge';

export async function POST(req: NextRequest) {
  const form = await req.formData();
  const file = form.get('file') as File;
  const baseUrl = form.get('baseUrl') as string;
  const accountId = form.get('accountId') as string;
  const token = form.get('token') as string;

  const uploadUrl = `${baseUrl}/upload/${accountId}`;
  const upRes = await fetch(uploadUrl, { method: "POST", headers: { "Authorization": `Bearer ${token}` }, body: file });
  const upJson = await upRes.json(); // conforms to RFC8620 upload response; Blob/upload (RFC9404) also supported if enabled

  return NextResponse.json(upJson);
}
