
# Ahla Mail (v1.2)
يوفر بريدًا شخصيًا للمستخدمين ضمن منظومة أهلا مع واجهة ويب (Next.js) وواجهة API تربط IMAP/SMTP.
- Dev: يستخدم GreenMail (SMTP/IMAP)
- Prod: يوصى باستخدام **Amazon WorkMail (IMAP)** و **Amazon SES (SMTP)**

## DNS المطلوب للبريد
- سجلات MX توجه لمزوّد البريد (WorkMail أو خادمك)
- SPF (TXT) لتفويض مُرسِلي البريد
- DKIM لتوقيع الرسائل (يوفّره SES/WorkMail)
- DMARC لضبط سياسة التحقق والتقارير

انظر `docs/MAIL_DNS.md`.
