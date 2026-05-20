import NextAuth from "next-auth";
import Credentials from "next-auth/providers/credentials";
import { PrismaAdapter } from "@auth/prisma-adapter";
import { prisma } from "./prisma";
import bcrypt from "bcrypt";

export const { handlers, auth, signIn, signOut } = NextAuth({
  adapter: PrismaAdapter(prisma),
  session: { strategy: "database" },
  secret: process.env.AUTH_SECRET,
  providers: [
    Credentials({
      name: "Credentials",
      credentials: { email: {}, password: {} },
      authorize: async (creds) => {
        const email = String(creds?.email || "");
        const password = String(creds?.password || "");
        const user = await prisma.user.findUnique({ where: { email } });
        if (!user?.password) return null;
        const ok = await bcrypt.compare(password, user.password);
        return ok ? { id: user.id, email: user.email ?? undefined, name: user.name ?? undefined } : null;
      },
    }),
  ],
});
