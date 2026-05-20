'use client'
export default function Page(){
  return <main style={{maxWidth:720,margin:'24px auto',padding:16}}>
    <h2>Ahla Drive — Resumable Uploads</h2>
    <p>استخدم عميل <code>tus</code> ووجّه إلى: <code>{process.env.NEXT_PUBLIC_TUSD}</code></p>
    <p>أو استخدم <code>/presign</code> للرفع المباشر إلى MinIO (PUT Presigned) من <code>{process.env.NEXT_PUBLIC_DRIVE_API}/presign</code>.</p>
    <p>لوحة MinIO: <a href={process.env.NEXT_PUBLIC_MINIO_CONSOLE!} target="_blank">{process.env.NEXT_PUBLIC_MINIO_CONSOLE}</a></p>
  </main>
}
