
# WorkMail setup (manual steps)
1) Create organization in AWS WorkMail (Console) and add domain `ahla.com`.
2) Verify domain and set MX to WorkMail inbound endpoint (region-specific).
3) Create users (ahmed@ahla.com, support@ahla.com, ...) and set passwords.
4) Enable IMAP access.
5) Use org-specific IMAP hostname in `prod.tfvars` for `mail_imap_host` (e.g., imap.mail.<region>.awsapps.com).
