# Keycloak MFA (TOTP) — Ahla Realm

## Option A — Import on startup
Bake `realm-mfa-patch.json` into your Keycloak image and start with `--import-realm`.

## Option B — kcadm (at runtime)
```
/opt/keycloak/bin/kcadm.sh config credentials --server http://localhost:8080 --realm master --user $KEYCLOAK_ADMIN --password $KEYCLOAK_ADMIN_PASSWORD
/opt/keycloak/bin/kcadm.sh update realms/ahla -s otpPolicyType=totp -s otpPolicyDigits=6 -s otpPolicyPeriod=30
/opt/keycloak/bin/kcadm.sh update realms/ahla -s 'requiredActions=["CONFIGURE_TOTP"]'
```
Then mark **"Configure OTP"** as a required action for all users or enforce via the Browser flow (Conditional OTP → required).
