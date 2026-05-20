# Ahla WhatsApp Importer v1
Build: 2025-10-20T04:38:46.741983Z

يحّول ملفات **Export Chat** من واتساب (Zip أو مجلد نص + وسائط) إلى:
- `schema.sql` (جداول Ahla Chat)
- `import.sql` (أوامر INSERT)
- `messages.jsonl` (صيغة تبادل)
- مجلد `media/` (ينسخ المرفقات جاهزة للرفع إلى MinIO/S3)

## الاستخدام (CLI)
```bash
python whatsapp_import.py --input /path/to/whatsapp_export.zip --out out_dir   --self "+9665XXXXXXX" --org "ahla" --owner "your-user@ahla.com"
```
