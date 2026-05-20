/**
 * Instrument login/register to help ATP/ACFP accuracy.
 * - Ensures aws-waf-token is present (cookie).
 * - Adds contextual headers for server-side logging (not required by WAF, but useful).
 */
export async function register(payload: {email: string; password: string}) {
  const res = await fetch('/auth/register', {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      'x-aha-action': 'register'
    },
    body: JSON.stringify(payload),
    credentials: 'include' // send cookies including aws-waf-token
  });
  return res;
}

export async function login(payload: {email: string; password: string}) {
  const res = await fetch('/auth/login', {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      'x-aha-action': 'login'
    },
    body: JSON.stringify(payload),
    credentials: 'include'
  });
  return res;
}
