/** Seed admin user */const bcrypt=require('bcrypt');const {PrismaClient}=require('@prisma/client');require('dotenv').config({path:'.env'});
const prisma=new PrismaClient();(async()=>{const email=process.env.ADMIN_EMAIL||'admin@ahla.local';const password=process.env.ADMIN_PASSWORD||'changeme123';
const hash=await bcrypt.hash(password,10);const exists=await prisma.user.findUnique({where:{email}});if(!exists){await prisma.user.create({data:{email,password:hash,name:'Admin'}});
console.log('Admin created:',email);}else{console.log('Admin exists:',email);}await prisma.$disconnect();})().catch(e=>{console.error(e);process.exit(1);});
