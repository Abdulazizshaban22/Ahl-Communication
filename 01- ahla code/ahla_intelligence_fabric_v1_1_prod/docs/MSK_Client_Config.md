# MSK SASL/IAM Client
Use bootstrap from Terraform output `msk_bootstrap_sasl_iam`.
In containers, set:
```
KAFKA_BROKERS=<value>
# For IAM auth, use MSK IAM auth library (java/python) or MSK IAM via env in aiokafka (if available).
```
