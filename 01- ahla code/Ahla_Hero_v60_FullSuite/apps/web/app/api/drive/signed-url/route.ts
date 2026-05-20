import { NextResponse } from "next/server";
import crypto from "crypto";

export async function POST(req: Request) {
  const { name, type } = await req.json();
  const key = `${crypto.randomUUID()}-${name}`;
  const url = new URL(`${process.env.S3_ENDPOINT}/${process.env.S3_BUCKET}/${key}`);
  return NextResponse.json({ uploadUrl: url.toString(), key, headers: {
    "x-amz-acl": "private", "Content-Type": type
  }});
}
