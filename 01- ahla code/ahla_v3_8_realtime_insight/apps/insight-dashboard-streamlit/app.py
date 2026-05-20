import os, time, requests, streamlit as st

GATEWAY = os.getenv("GATEWAY_URL","http://localhost:8085")

st.set_page_config(page_title="Ahla Intelligence Live", layout="wide")
st.title("لوحة الذكاء اللحظي — Ahla Intelligence Live")

placeholder = st.empty()
start = st.button("ابدأ البث")
stop = st.button("أوقف")

running = start and not stop
if 'running' not in st.session_state:
    st.session_state.running = False
if start:
    st.session_state.running = True
if stop:
    st.session_state.running = False

while st.session_state.running:
    snap = requests.get(f"{GATEWAY}/snapshot", timeout=10).json()
    asr = [x.get('text','') for x in snap.get('asr',[])][-20:]
    emo = [(x.get('label','?'), float(x.get('score',0))) for x in snap.get('emotion',[])][-10:]
    sug = [x.get('text','') for x in snap.get('suggestions',[])][-10:]
    kpi = snap.get('kpi',{})

    with placeholder.container():
        col1, col2 = st.columns([2,1])
        with col1:
            st.subheader("🗣️ النصوص الحيّة (ASR)")
            st.write("\n".join(reversed(asr)))
        with col2:
            st.subheader("❤️ المزاج اللحظي (Emotion)")
            st.table({"label":[e[0] for e in emo], "score":[e[1] for e in emo]})
        st.subheader("💡 الاقتراحات الأخيرة")
        st.write("\n".join(reversed(sug)))
        st.subheader("📈 مؤشرات فورية")
        c1,c2,c3 = st.columns(3)
        c1.metric("ASR msgs", int(kpi.get("cnt_asr",0)))
        c2.metric("Emotion msgs", int(kpi.get("cnt_emotion",0)))
        c3.metric("Suggestions msgs", int(kpi.get("cnt_suggestions",0)))
    time.sleep(1.0)
st.info("انتهى البث. اضغط 'ابدأ البث' لاستئناف.")
