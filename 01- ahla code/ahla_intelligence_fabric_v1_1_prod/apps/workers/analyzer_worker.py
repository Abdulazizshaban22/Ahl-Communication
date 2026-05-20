import asyncio, time
from common import consumer, producer

async def main():
    cons = await consumer("emotion.outputs")
    prod = await producer()
    print("analyzer_worker: listening emotion.outputs")
    window=[]
    try:
        async for msg in cons:
            e = msg.value.get("emotion",{})
            window.append(e.get("anger",0.0))
            if len(window)>=20:
                avg=sum(window)/len(window)
                level="HIGH" if avg>0.6 else ("MED" if avg>0.3 else "LOW")
                await prod.send_and_wait("analyze.alerts", {"metric":"anger_avg","value":avg,"level":level,"ts":time.time()})
                window.clear()
    finally:
        await cons.stop(); await prod.stop()

if __name__ == "__main__":
    asyncio.run(main())
