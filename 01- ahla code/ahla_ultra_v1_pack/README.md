# Ahla Ultra v1 Pack
Build: 2025-10-20T09:27:29.033728Z

يشمل أربع خدمات جاهزة:
- **ASR** (faster-whisper + Prometheus)
- **Translate** (NLLB-200 via CTranslate2 + Prometheus)
- **Diarization** (pyannote.audio + Prometheus)
- **Semantic Search** (pgvector on Postgres + Prometheus)

## تشغيل محلي
راجع `services/*/README.md` لكل خدمة.

## نشر على K8s
- حرّر صور الحاويات في `k8s/*.yaml` إلى سجلك (ECR/…)، ثم:
```bash
kubectl apply -f k8s/
```
- استورد لوحة Grafana من `monitoring/grafana/ahla-ultra-v1-dashboard.json`.

> ملاحظات:
> - الترجمة تحتاج نموذج CT2 جاهز في مجلد `models/` (غير مرفق).
> - diarization يحتاج `HF_TOKEN` صالح لتنزيل الوزنات.
