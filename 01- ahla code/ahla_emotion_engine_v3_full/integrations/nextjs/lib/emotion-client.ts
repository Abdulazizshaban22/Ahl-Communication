export async function analyzeMessage(payload:any){
  const url = process.env.NEXT_PUBLIC_EMOTION_ENGINE_URL + '/analyze'
  const res = await fetch(url,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(payload)})
  if(!res.ok) throw new Error('engine error')
  return res.json()
}