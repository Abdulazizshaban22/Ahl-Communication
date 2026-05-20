# Enable X-Ray on ECS Services
1) أضف الـSidecar المرفق `ecs/taskdef_xray_sidecar.json` في تعريف المهمة لنفس الخدمة.
2) أضف متغير البيئة في حاوياتك التطبيقية:
   - `AWS_XRAY_DAEMON_ADDRESS=127.0.0.1:2000`
3) اربط دور المهمة بـ AWSXRayDaemonWriteAccess (انظر Terraform).
4) راقب Trace Map في AWS X-Ray Console.
