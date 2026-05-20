# Ahla Emotion Engine v4 — Omni Features
Build date: 2025-10-19

**هذه النسخة توسّع كل الأنماط والخصائص**:
- مزايا Feast موسّعة (15m response rate, tone volatility, burstiness…).
- جدولة **materialize-incremental** يوميًا، وتقارير **Evidently** يومية، وإعادة تدريب أسبوعية.
- قواعد سلوكية تستغل الميزات الجديدة (كود جاهز في الـengine.yaml).

## التشغيل السريع
1) حساب الميزات وFeast apply:
```
python feast_repo/jobs/compute_chat_metrics.py
cd feast_repo && feast apply
feast materialize-incremental $(date -u -d "25 hours ago" +"%Y-%m-%dT%H:%M:%SZ")
```
2) تقرير الانجراف:
```
python monitoring/evidently/drift_report.py
```
3) تفعيل GitHub Actions: ارفع `infra/github-actions/omni-pipeline.yml` للمستودع.

## أين أعدّل؟
- القواعد/السياسات: `services/emotion-engine/config/engine.yaml`
- ميزات Feast: `feast_repo/features.py` + وظيفة الحساب: `feast_repo/jobs/compute_chat_metrics.py`
- جداول cron: `infra/github-actions/omni-pipeline.yml` + `infra/k8s-cron/cronjobs.yaml`
