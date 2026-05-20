# Frontend integration notes

- **AWS WAF token**: Use the AWS WAF JS integration `getToken()` to set cookie `aws-waf-token` before calling protected endpoints (login/register).
- **ATP Response inspection**: Make sure successful login returns **200/204/302** and failures **400/401/403** as configured in `waf/examples/atp_response_inspection.json`.
- **ACFP**: The rule group watches `/auth/register`. Keep this path stable; if you change it, update the WAF config.
