import time, os, pytesseract
from pathlib import Path

QUEUE = Path("/shared/ocr_queue")
OUT   = Path("/shared/ocr_out")
QUEUE.mkdir(parents=True, exist_ok=True)
OUT.mkdir(parents=True, exist_ok=True)

def process(path: Path):
    try:
        text = pytesseract.image_to_string(str(path))
        (OUT/(path.name+".txt")).write_text(text, encoding="utf-8")
        path.unlink()
        print("OCR ok", path.name)
    except Exception as e:
        print("OCR err", path.name, e)

if __name__=="__main__":
    while True:
        for f in list(QUEUE.glob("*")):
            process(f)
        time.sleep(2)
