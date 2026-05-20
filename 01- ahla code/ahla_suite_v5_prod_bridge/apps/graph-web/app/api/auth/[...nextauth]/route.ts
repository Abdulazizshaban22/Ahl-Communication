import NextAuth from "next-auth"
import Keycloak from "next-auth/providers/keycloak"

const handler = NextAuth({
  providers: [
    Keycloak({
      issuer: process.env.AUTH_KEYCLOAK_ISSUER,
      clientId: process.env.AUTH_KEYCLOAK_CLIENT_ID!,
      clientSecret: process.env.AUTH_KEYCLOAK_CLIENT_SECRET!,
    })
  ],
  session: { strategy: "jwt" },
  callbacks: {
    async jwt({ token, account }){
      if (account){ token.access_token = account.access_token }
      return token
    },
    async session({ session, token }){
      (session as any).access_token = token.access_token
      return session
    }
  }
})

export { handler as GET, handler as POST }
