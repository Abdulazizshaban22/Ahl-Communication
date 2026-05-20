import { shouldUseOnDevice, getPolicyForContext, ChatContext } from './privacy-policy'

export async function analyzeSmart(payload: {
  chat_id: string; message_id: string; author_id: string;
  text: string; context: ChatContext;
}){
  const policy = getPolicyForContext(payload.context)
  if (policy.on_device) {
    // Use ONNX Web (client-side) — caller should pass `onDevice=true` and results
    throw new Error('on-device analysis should be executed on client using ONNX Runtime Web; send results to /api/emotion/ingest without raw text.')
  } else {
    const res = await fetch(process.env.NEXT_PUBLIC_EMOTION_ENGINE_URL + '/analyze', {
      method: 'POST', headers: {'Content-Type':'application/json'},
      body: JSON.stringify(payload)
    })
    if(!res.ok) throw new Error('engine error')
    return res.json()
  }
}
