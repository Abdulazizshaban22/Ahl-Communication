# Ahla Webmail (JMAP + Keycloak SSO)
- Next.js App Router with NextAuth Keycloak Provider.
- JMAP client for inbox listing & sending (RFC 8621).
- Self sign-up page calls Stalwart Management API to create a mailbox.

> Notes:
> - In production, prefer OAuth/OIDC tokens between Keycloak and Stalwart (SASL OAUTHBEARER) or provision app passwords per user.
> - Demo stores mail credentials in httpOnly cookies. Replace with server-side token vault.
