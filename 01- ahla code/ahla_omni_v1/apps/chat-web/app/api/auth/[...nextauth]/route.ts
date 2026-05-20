import NextAuth from "next-auth"
import Keycloak from "next-auth/providers/keycloak"
const handler = NextAuth({
  providers:[Keycloak({clientId:process.env.NEXT_PUBLIC_KEYCLOAK_CLIENT_ID!,clientSecret:process.env.KEYCLOAK_CLIENT_SECRET!,issuer:process.env.NEXT_PUBLIC_KEYCLOAK_ISSUER})],
  session:{strategy:"jwt"}
})
export {handler as GET, handler as POST}
