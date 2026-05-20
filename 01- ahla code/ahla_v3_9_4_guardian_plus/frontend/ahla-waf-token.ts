// Minimal client helper for AWS WAF token (stores cookie 'aws-waf-token')
// See: AWS WAF getToken — stores token in cookie `aws-waf-token`
export async function ensureWafToken(getTokenFn: () => Promise<void>) {
  // If cookie is already set, skip; else call provided getToken()
  const hasCookie = document.cookie.split('; ').find(x => x.startsWith('aws-waf-token='));
  if (!hasCookie) {
    await getTokenFn(); // from AWS WAF JS integration
  }
}
