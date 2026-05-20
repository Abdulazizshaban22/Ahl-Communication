# CloudFront + WAF over ALB
- ALB is public but locked to **CloudFront origin-facing prefix list** only, plus custom header `X-From-CloudFront: true`.
- Attach WAF (Common, Bot Control, ATP) at CloudFront **(scope=CLOUDFRONT, us-east-1)**.
- Viewer policy: redirect to HTTPS; caching disabled for API.
