
// Placeholder: consume SES S3 events via SQS/SNS and process inbound mail.
// In production, configure SES receipt rules -> S3 -> SNS -> (this worker via HTTPS/SQS).
console.log('mail-worker ready (SES inbound scaffold)')
