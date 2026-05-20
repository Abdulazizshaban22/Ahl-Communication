/**
 * Seed an admin user using ADMIN_EMAIL and ADMIN_PASSWORD from .env
 * Run with: node apps/web/scripts/seed-admin.js
 */
const bcrypt = require("bcrypt");
const { PrismaClient } = require("@prisma/client");
require("dotenv").config({ path: ".env" });

const prisma = new PrismaClient();

(async () => {
  const email = process.env.ADMIN_EMAIL || "admin@ahla.local";
  const password = process.env.ADMIN_PASSWORD || "changeme123";
  const hash = await bcrypt.hash(password, 10);
  const existing = await prisma.user.findUnique({ where: { email } });
  if (existing) {
    console.log("Admin already exists:", email);
  } else {
    await prisma.user.create({ data: { email, password: hash, name: "Admin" } });
    console.log("Admin created:", email);
  }
  await prisma.$disconnect();
})().catch(async (e) => {
  console.error(e);
  process.exit(1);
});
