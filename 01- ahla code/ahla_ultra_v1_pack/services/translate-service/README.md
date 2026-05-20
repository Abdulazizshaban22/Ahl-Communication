# Ahla Translate Service (Ultra v1)
Build: 2025-10-20T09:27:29.033728Z

- Engine: NLLB-200 (CTranslate2 format) + SentencePiece
- Variables:
  - `CT2_MODEL_PATH` directory of converted model
  - `SRC_LANG` (default arb_Arab), `TGT_LANG` (default eng_Latn)

Run:
```bash
pip install -r requirements.txt
CT2_MODEL_PATH=./models uvicorn main:app --host 0.0.0.0 --port 8089
```
