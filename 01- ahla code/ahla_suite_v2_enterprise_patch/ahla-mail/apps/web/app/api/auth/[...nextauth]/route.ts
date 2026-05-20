import NextAuth from "next-auth";
import KeycloakProvider from "next-auth/providers/keycloak";

const handler = NextAuth({
  providers: [
    KeycloakProvider({
      clientId: process.env.NEXT_PUBLIC_KEYCLOAK_CLIENT_ID!,
      clientSecret: process.env.KEYCLOAK_CLIENT_SECRET!,
      issuer: process.env.NEXT_PUBLIC_KEYCLOAK_ISSUER, // e.g. https://auth.ahla.com/realms/ahla
    }),
  ],
  session: { strategy: "jwt" },
  callbacks: {
    async jwt({ token, account, profile }) {
      if (account) {
        token.access_token = account.access_token;
      }
      return token;
    },
    async session({ session, token }) {
      (session as any).access_token = token.access_token;
      return session;
    },
  },
});
export { handler as GET, handler as POST };
