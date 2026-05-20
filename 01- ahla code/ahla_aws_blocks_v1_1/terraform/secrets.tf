# Secrets Manager for TURN and SMTP (examples)
resource "aws_secretsmanager_secret" "turn" {
  name = "${var.project}/turn"
}

# JSON example: { "user": "turnuser", "pass": "turnpass", "cert_pem": "<PEM>", "key_pem": "<PEM>" }
resource "aws_secretsmanager_secret_version" "turn_v" {
  secret_id     = aws_secretsmanager_secret.turn.id
  secret_string = jsonencode({ user = "turnuser", pass = "turnpass", cert_pem = "-----BEGIN CERTIFICATE-----\n...\n-----END CERTIFICATE-----", key_pem = "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----" })
}

resource "aws_secretsmanager_secret" "smtp" {
  name = "${var.project}/smtp"
}
resource "aws_secretsmanager_secret_version" "smtp_v" {
  secret_id     = aws_secretsmanager_secret.smtp.id
  secret_string = jsonencode({ host = "email-smtp.me-central-1.amazonaws.com", port = 587, user = "AKIA...", pass = "SECRET..." })
}

# Example SSM Parameter (non-sensitive config)
resource "aws_ssm_parameter" "turn_realm" {
  name  = "/${var.project}/turn/realm"
  type  = "String"
  value = var.turn_realm
}
