# PDPL — سياسة السجلات
- الاحتفاظ 12 شهرًا للّوائح التشغيلية، 24 شهرًا لسجلات الموافقات والسحوبات.
- إشعار خروقات خلال 72 ساعة عبر تدفق Incident→DPO→Regulator.
- DSR API:
  - POST /pdpl/consents (منح/سحب).
  - GET /pdpl/consents/:userId.
  - POST /pdpl/dsr (طلبات الوصول/المحو/التصحيح).
  - GET /pdpl/dsr/:id (حالة الطلب).
