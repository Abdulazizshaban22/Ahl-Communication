export async function jmap<T>(ops:any[], auth:{username:string,password:string}) : Promise<T>{
  const url = process.env.JMAP_BASE_URL || 'http://localhost:8080/jmap'
  const res = await fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json; jmapVersion=rfc-8621', // per RFC-8621
      'Authorization': 'Basic ' + Buffer.from(`${auth.username}:${auth.password}`).toString('base64')
    },
    body: JSON.stringify(ops)
  })
  if(!res.ok) throw new Error(`JMAP error ${res.status}`)
  return res.json()
}
