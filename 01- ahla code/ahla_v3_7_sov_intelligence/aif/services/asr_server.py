from fastapi import FastAPI, Request
import uvicorn
app = FastAPI()

@app.post("/v1/asr")
async def asr(req: Request):
    pcm = await req.body()
    # TODO: forward to whisper.cpp/faster-whisper server; return transcript
    return {"text": "(stub)", "lang": "ar"}

@app.post("/v1/emotion")
async def emotion(text: str):
    # TODO: call SageMaker endpoint or local model for emotion
    return {"sentiment": "neutral", "score": 0.5}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8081)
