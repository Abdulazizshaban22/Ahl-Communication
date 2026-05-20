
# WorkMail + SES تكامل
- الإرسال: استخدم **SES SMTP** (`email-smtp.<region>.amazonaws.com`, TLS 587).
- الاستلام: خزّن صناديق البريد على **Amazon WorkMail** واسمح بالوصول عبر IMAP.
- يمكنك أيضًا استخدام **SES Inbound -> S3 -> SNS/SQS** ثم `mail-worker` لمعالجة البريد الوارد برمجيًا.

راجع وثائق AWS للمزيد.
