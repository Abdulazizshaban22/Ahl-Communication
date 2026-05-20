
# Ahla Mail images & secrets
variable "img_mail_web" {}
variable "img_mail_api" {}

variable "mail_imap_host" {}
variable "mail_imap_port" { default = 993 }
variable "mail_imap_secure" { default = true }
variable "mail_smtp_host" {}
variable "mail_smtp_port" { default = 587 }
variable "mail_smtp_secure" { default = true }
variable "ssm_mail_user" {}
variable "ssm_mail_pass" {}
