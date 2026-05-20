import asyncio
from common import kafka_consumer, kafka_producer

async def main():
    cons = kafka_consumer("ai.suggestions")
    await cons.start()
    prod = kafka_producer()
    await prod.start()
    print("talk_worker: listening ai.suggestions")
    try:
        async for msg in cons:
            await prod.send_and_wait("talk.commands", {"say":"اقتراح جديد من الذكاء—تم"})
    finally:
        await cons.stop(); await prod.stop()

if __name__ == "__main__":
    asyncio.run(main())
