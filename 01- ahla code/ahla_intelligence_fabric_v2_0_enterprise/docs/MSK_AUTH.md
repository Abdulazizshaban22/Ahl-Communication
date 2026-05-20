# MSK Authentication Modes
- **serverless-iam**: Uses SASL/OAUTHBEARER with AWS IAM. Python clients load `aws-msk-iam-sasl-signer-python` and pass `sasl_oauth_token_provider` to aiokafka.
- **provisioned-scram**: Uses SASL/SCRAM-SHA-512 with username/password.

Toggle with `var.msk_mode`. For IAM, no MSK username/password are needed; IAM role permissions govern access.
