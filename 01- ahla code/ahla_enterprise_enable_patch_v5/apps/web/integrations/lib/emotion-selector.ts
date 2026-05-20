import { shouldUseOnDevice, getPolicyForContext, ChatContext } from './privacy-policy'

export async function analyzeSmart(payload: {
  chat_id: string; message_id: string; author_id: string;
  text: string; context: ChatContext;
}){
  const policy = getPolicyForContext(payload.context)
  if (policy.on_device) {
    // On-device path: caller does local inference, send only analysis to server
    throw new Error('on-device: call your on-device helper, then send results to /api/emotion/ingest without raw text.')
  } else {
    const res = await fetch(process.env.NEXT_PUBLIC_EMOTION_ENGINE_URL + '/analyze', {
      method: 'POST', headers: {'Content-Type':'application/json'},
      body: JSON.stringify(payload)
    })
    if(!res.ok) throw new Error('engine error')
    return res.json()
  }
}