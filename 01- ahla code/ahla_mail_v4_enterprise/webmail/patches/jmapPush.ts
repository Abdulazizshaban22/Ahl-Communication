// apps/webmail/lib/jmapPush.ts
export function connectEventSource(baseUrl: string, token: string, onMsg: (evt:any)=>void) {
  const url = new URL('/jmap/eventsource/', baseUrl);
  url.searchParams.set('types','*');      // all types
  url.searchParams.set('closeafter','no'); 
  url.searchParams.set('ping','30');      // heartbeat
  const es = new EventSource(url.toString(), { withCredentials: true });
  es.onmessage = (e)=> { try { onMsg(JSON.parse(e.data)); } catch { /* ignore */ } };
  es.onerror = ()=> { es.close(); setTimeout(()=>connectEventSource(baseUrl, token, onMsg), 3000); };
  return es;
}
