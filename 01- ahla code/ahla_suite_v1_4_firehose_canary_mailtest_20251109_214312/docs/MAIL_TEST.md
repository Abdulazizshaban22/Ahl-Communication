
# MAIL TEST — SES → WorkMail
## المتطلبات
- قيم بيئة SMTP (SES) و IMAP (WorkMail) جاهزة.
- سجلات DNS مكتملة (MX/SPF/DKIM/DMARC).

## تشغيل الاختبار
```bash
export SMTP_HOST=email-smtp.<region>.amazonaws.com
export SMTP_PORT=587
export SMTP_USER=AKIA...      # أو بيانات اعتماد SMTP التي ولّدتها SES
export SMTP_PASS=********
export IMAP_HOST=imap.mail.<region>.awsapps.com
export IMAP_PORT=993
export IMAP_USER=you@ahla.com
export IMAP_PASS=********
node scripts/test_mail.js
```
**النتيجة المتوقعة:** `✅ Delivery ok (IMAP received)` خلال ~10–30 ثانية حسب المنطقة.
