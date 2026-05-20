
# WorkMail Provisioning
- ضع `organization_id` الصحيح داخل `scripts/workmail_users.json` (من لوحة WorkMail).
- عدّل قائمة المستخدمين كما تريد.
- شغّل:
```bash
bash scripts/workmail_provision.sh scripts/workmail_users.json
```
- سيتم إنشاء المستخدمين وتسجيلهم في WorkMail تلقائيًا بكلمة مرور مؤقتة.
