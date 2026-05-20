import policy from '../config/policy.json'

export type ChatContext = 'personal'|'family'|'work'
export function getPolicyForContext(ctx: ChatContext){
  const p = (policy as any).contexts[ctx] || (policy as any).contexts['personal']
  return p
}
export function shouldUseOnDevice(ctx: ChatContext): boolean {
  return !!getPolicyForContext(ctx).on_device
}
