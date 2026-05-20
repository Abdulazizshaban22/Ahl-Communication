# Next.js SSO with Keycloak (NextAuth v5 — App Router)

Files here show how to wire NextAuth Keycloak provider (OIDC) on App Router.
- Reads roles from Keycloak (`realm_access.roles`) for RBAC on routes.
- Secures cookies, uses `NEXTAUTH_URL`, `NEXTAUTH_SECRET`.

Drop into your Next.js app and adjust paths accordingly.
