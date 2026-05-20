# Ahla v3.9.7 — SLO Command Center

## 1) لوحة Grafana — Burn Rate
- لوحة `grafana/dashboards/slo_command_center.json` تعرض Burn Rate لكل خدمة وفق معادلة Google SRE (multi‑window تستند إلى CloudWatch إنذارات).

## 2) Silences تلقائية
- **Mute Timings**: `grafana/provisioning/alerting/mute-timings.yaml` يعرّف نافذة صيانة أسبوعية (الجمعة 02:00–03:00 آسيا/الرياض).
- **Notification Policies**: تربط `ahla-maintenance-window` بكل التنبيهات افتراضيًا. يمكنك تخصيص route لكل خدمة.
- **Silence API Script**: `scripts/create_silence.sh` ينشئ Silence فوري لمدى زمني مخصص.

## 3) Suppression على مستوى AWS
- وحدة Terraform `infra/terraform/maintenance_suppression/`:
  - منبّه `MaintenanceMode` يعتمد مقياسًا مخصصًا (1/0).
  - جداول EventBridge لتشغيل/إيقاف الصيانة تلقائيًا (cron).
  - Lambda يكتب المقياس.
  - استخدم **Action Suppression** في Composite alarms لوقف أفعالها أثناء الصيانة.

## تشغيل سريع
- استورد لوحة Grafana أو ضعها ضمن provisioning.
- فعّل ملفات provisioning (contact points / policies / mute timings).
- انشر وحدة suppression واستخدم CRON لجدولة الصيانة.

> نصيحة: استخدم **Fast/Med/Slow** burn‑rates وComposite AND لتقليل الضجيج، و"Suppression" أثناء الصيانة بدل إيقاف التقييم.
