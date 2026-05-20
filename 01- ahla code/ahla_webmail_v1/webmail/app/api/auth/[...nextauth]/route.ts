import NextAuth from "next-auth"
import Keycloak from "next-auth/providers/keycloak"
const handler = NextAuth({
  providers: [
    Keycloak({
      clientId: process.env.NEXT_PUBLIC_KEYCLOAK_CLIENT_ID!,
      clientSecret: process.env.KEYCLOAK_CLIENT_SECRET!,
      issuer: process.env.NEXT_PUBLIC_KEYCLOAK_ISSUER
    }),
  ],
  session: { strategy: "jwt" },
  callbacks: {
    async jwt({ token, account }) {
      if (account) token.kc_access_token = (account as any).access_token
      return token
    },
    async session({ session, token }) {
      (session as any).kc_access_token = token.kc_access_token
      return session
    }
  }
})
export { handler as GET, handler as POST }
