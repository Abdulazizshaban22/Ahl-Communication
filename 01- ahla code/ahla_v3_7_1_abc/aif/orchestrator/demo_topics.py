# Simple demo: produce/consume a message on aif.suggestions (dev only)
import time, threading, json
import producer
import consumer

def consumer_thread():
    for rec in consumer.run("aif.suggestions"):
        print("[consumer]", rec)

t = threading.Thread(target=consumer_thread, daemon=True)
t.start()
time.sleep(2)
producer.send("aif.suggestions", {"hello":"world"})
time.sleep(5)
