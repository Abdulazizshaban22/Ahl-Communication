import asyncio
from common import consumer, producer

async def main():
    cons = await consumer("chat.events")
    prod = await producer()
    print("emotion_worker: listening chat.events")
    try:
        async for msg in cons:
            text = msg.value.get("text","")
            if not text: continue
            anger = min(1.0, text.count('!')/5.0)
            joy = max(0.0, 1.0-anger)
            await prod.send_and_wait("emotion.outputs", {"emotion":{"anger":anger,"joy":joy},"ref":msg.value.get("id")})
    finally:
        await cons.stop(); await prod.stop()

if __name__ == "__main__":
    asyncio.run(main())
