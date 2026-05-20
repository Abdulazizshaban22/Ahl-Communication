// Minimal storage interface example for libsignal (pseudo-TS)
export class SignalStore {
  storage: Map<string, any> = new Map();
  get(k:string){ return this.storage.get(k); }
  put(k:string, v:any){ this.storage.set(k, v); }
  remove(k:string){ this.storage.delete(k); }
}
