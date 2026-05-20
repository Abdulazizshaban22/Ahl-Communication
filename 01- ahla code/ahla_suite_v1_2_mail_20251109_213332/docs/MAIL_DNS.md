
# إعدادات DNS للبريد
## MX
- يحدد خوادم استلام البريد لنطاقك (مثلاً WorkMail).

## SPF (RFC 7208)
- TXT record مثال:
```
v=spf1 include:amazonses.com -all
```

## DKIM (RFC 6376)
- مفاتيح DKIM ينشئها مزوّدك (SES/WorkMail) كـ CNAME/TXT.

## DMARC (RFC 7489)
- TXT record مثال:
```
_dmarc.example.com  IN TXT  "v=DMARC1; p=quarantine; rua=mailto:dmarc-agg@example.com"
```
