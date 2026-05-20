export default function Home() {
  return (
    <main style={{padding:24,fontFamily:'system-ui'}}>
      <h1>Ahla — FullSuite v2 (Go-Live)</h1>
      <p>منصة موحّدة: Auth + Files (MinIO) + Mail + Meetings + WS Chat + ONLYOFFICE + SFU</p>
      <ul>
        <li>API: /api/auth/[...nextauth]</li>
        <li>API: /api/drive/signed-url</li>
        <li>API: /api/mail/send</li>
        <li>API: /api/meetings/create</li>
        <li>WS: /ws/chat (عن طريق Nginx/Caddy)</li>
        <li>WS: /ws/sfu (Ion-SFU JSON-RPC)</li>
      </ul>
    </main>
  );
}
