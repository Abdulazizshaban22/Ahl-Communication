import NextAuth from "next-auth"
import Keycloak from "next-auth/providers/keycloak"
const handler = NextAuth({
  providers: [
    Keycloak({
      clientId: process.env.KEYCLOAK_ID!,
      clientSecret: process.env.KEYCLOAK_SECRET!,
      issuer: process.env.KEYCLOAK_ISSUER!,
    }),
  ],
  secret: process.env.NEXTAUTH_SECRET,
})
export { handler as GET, handler as POST }