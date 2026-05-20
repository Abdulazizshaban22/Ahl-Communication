# MFA Enablement
1. Rebuild/push Keycloak image with `keycloak-mfa/realm-mfa-patch.json`.
2. Redeploy ECS service for Keycloak.
3. Verify: `/auth/realms/ahla/account/` shows OTP setup required.
