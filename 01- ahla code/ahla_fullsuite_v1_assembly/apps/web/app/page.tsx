export default function Home() {
  return (
    <main style={{padding:24,fontFamily:'system-ui'}}>
      <h1>Ahla — FullSuite v1</h1>
      <p>منصة موحّدة: Auth + Files (MinIO) + Mail + Meetings + WS Chat + ONLYOFFICE + SFU</p>
      <ul>
        <li>API: /api/auth/[...nextauth]</li>
        <li>API: /api/drive/signed-url</li>
        <li>API: /api/mail/send</li>
        <li>API: /api/meetings/create</li>
        <li>WS: /ws/chat (عبر Nginx)</li>
      </ul>
    </main>
  );
}
