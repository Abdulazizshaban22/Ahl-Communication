// Simple client to Emotion Engine
export async function analyzeMessage(payload: {
  chat_id: string; message_id: string; author_id: string;
  text: string; ts?: string; context?: 'work'|'personal'|null;
}) {
  const res = await fetch(process.env.NEXT_PUBLIC_EMOTION_ENGINE_URL + '/analyze', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload),
    // keep alive to avoid cold starts
  });
  if (!res.ok) throw new Error('Emotion Engine error');
  return res.json();
}
