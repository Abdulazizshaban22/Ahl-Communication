import NextAuth from "next-auth"
import Keycloak from "next-auth/providers/keycloak"

export const { auth, handlers, signIn, signOut } = NextAuth({
  providers: [
    Keycloak({
      issuer: process.env.KEYCLOAK_ISSUER,
      clientId: process.env.KEYCLOAK_CLIENT_ID,
      clientSecret: process.env.KEYCLOAK_CLIENT_SECRET
    })
  ],
  callbacks: {
    async jwt({ token, account, profile }) {
      // Map Keycloak roles
      const any = profile as any
      const roles = any?.realm_access?.roles || []
      token.roles = roles
      return token
    },
    async session({ session, token }) {
      (session as any).roles = (token as any).roles || []
      return session
    }
  },
  session: { strategy: "jwt" }
})
