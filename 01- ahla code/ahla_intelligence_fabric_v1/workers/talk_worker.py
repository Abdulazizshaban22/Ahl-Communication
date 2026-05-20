import asyncio
from common import consumer, producer

async def main():
    cons = await consumer("ai.suggestions")
    prod = await producer()
    print("talk_worker: listening ai.suggestions")
    try:
        async for msg in cons:
            await prod.send_and_wait("talk.commands", {"say":"اقتراح جديد من الذكاء—تم"})
    finally:
        await cons.stop(); await prod.stop()

if __name__ == "__main__":
    asyncio.run(main())
