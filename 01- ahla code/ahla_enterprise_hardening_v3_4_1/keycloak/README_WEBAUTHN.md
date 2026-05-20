# Keycloak — Enable WebAuthn / Passkeys (alongside TOTP)
1) Bake `realm-webauthn-fragment.json` into your Keycloak image or apply via `kcadm`:
```
/opt/keycloak/bin/kcadm.sh config credentials --server http://localhost:8080 --realm master --user $KEYCLOAK_ADMIN --password $KEYCLOAK_ADMIN_PASSWORD
/opt/keycloak/bin/kcadm.sh update realms/ahla -f /opt/keycloak/data/import/realm-webauthn-fragment.json
```
2) In Admin Console → Authentication → Required Actions, enable **WebAuthn Register** and **Configure OTP**.
3) In Browser flow, insert **WebAuthn Passwordless** or Step‑Up subflow as needed.
4) Test on modern browsers with platform authenticators (Passkeys).
