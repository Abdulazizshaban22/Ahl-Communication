// apps/webmail/app/api/jmap/search/route.ts
import { NextRequest, NextResponse } from 'next/server';

export async function POST(req: NextRequest) {
  const { baseUrl, accountId, token, text } = await req.json();
  const body = {
    using: ["urn:ietf:params:jmap:core", "urn:ietf:params:jmap:mail"],
    methodCalls: [
      ["Email/query", { accountId, filter: { text }, sort: [{ property: "receivedAt", isAscending: false }], limit: 50 }, "a"],
      ["Email/get",   { accountId, "#ids": { resultOf: "a", name: "Email/query", path: "/ids" }, properties: ["id","subject","from","receivedAt","preview"]}, "b"]
    ]
  };
  const res = await fetch(`${baseUrl}/jmap`, {
    method: "POST",
    headers: { "Content-Type":"application/json", "Authorization": `Bearer ${token}`},
    body: JSON.stringify(body)
  });
  const json = await res.json();
  return NextResponse.json(json);
}
