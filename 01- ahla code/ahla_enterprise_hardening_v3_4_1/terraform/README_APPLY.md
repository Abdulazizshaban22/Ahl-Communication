# Apply notes (v3.4.1)
- **WebAuthn**: Rebuild Keycloak with the realm fragment and redeploy ECS.
- **Object Lock**: Create a **new bucket** with object_lock_enabled=true. Migrate objects, then switch endpoints.
- **Backup copy**: Set `secondary_region`. Terraform will create a vault in that region and add `copy_action` to your plan.
- **Canaries**: Terraform uploads `canaries/ahla-canary.zip` to an S3 code bucket and creates an `aws_synthetics_canary` scheduled every 5 minutes.
