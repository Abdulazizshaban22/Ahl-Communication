import { prisma } from "@/lib/prisma";
import { auth } from "@/lib/auth";

export async function POST(req: Request) {
  const session = await auth();
  if (!session?.user?.email) return new Response("Unauthorized", { status: 401 });
  const user = await prisma.user.findUnique({ where: { email: session.user.email! }});
  const { title, startsAt, endsAt } = await req.json();
  const meeting = await prisma.meeting.create({
    data: { title, startsAt: new Date(startsAt), endsAt: new Date(endsAt), hostId: user!.id }
  });
  return Response.json(meeting);
}
