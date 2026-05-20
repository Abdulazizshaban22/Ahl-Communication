# Notes
- أنشئ دور IAM لـ external-dns و aws-load-balancer-controller عبر IRSA.
- خزّن شهادات CoTURN في Secret اسمه `coturn-tls` (fullchain.pem/privkey.pem).
- استخدم NLB مع بروتوكول TCP/TLS لTURN على 5349. UDP اختياري.
- اضبط سياسات Retention في NATS JetStream حسب الحمل المتوقع.
