# Drive API — Switch to AWS S3 (Production)

This patch replaces MinIO endpoint overrides with a standard **S3Client** that uses the
**task role** for credentials. The service reads `S3_BUCKET` and `AWS_REGION` from env.

> Replace `services/drive-api/app.js` in your dev monorepo with this file when deploying to AWS.
