from fastapi import FastAPI
app = FastAPI(title="Ahla Business API")
@app.get('/api/insights') def insights(): return {'harmony_index':0.82,'stress_index':0.21,'gratitude_index':0.33}
