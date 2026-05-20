/* Lightweight worker that tries whisper.cpp WASM first; falls back to Web Speech API is not possible here (workers don't have it).
   The main thread will load this worker and post { type:'transcribe', blob }.
   Expected optional global 'Module' from whisper.js if loaded via importScripts('/chat/whisper/whisper.js').
*/
self.onmessage = async (ev)=>{
  const { type, blob } = ev.data || {}
  if(type!=='transcribe') return
  try{
    try{ importScripts('/chat/whisper/whisper.js') }catch(e){}
    if(typeof Module !== 'undefined' && Module.transcribe){
      const arr = new Uint8Array(await blob.arrayBuffer())
      const text = await Module.transcribe(arr) // pseudo API — depends on your build
      self.postMessage({ ok:true, text })
      return
    }
  }catch(e){}
  // Fallback: not possible in worker; send notice
  self.postMessage({ ok:false, error:'No whisper wasm. Use main-thread webkitSpeechRecognition fallback.' })
}