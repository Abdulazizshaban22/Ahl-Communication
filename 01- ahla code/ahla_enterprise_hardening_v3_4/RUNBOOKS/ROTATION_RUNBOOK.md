# Secrets Rotation (RDS)
- Create (or map) your RDS secret JSON: {"username":"dbuser","password":"...","engine":"postgres","host":"...","port":5432,"dbname":"..."}
- Apply Terraform to deploy rotation Lambda + schedule.
- Validate rotation in Secrets Manager → Rotation status.
- For production, replace the stub Lambda with an **AWS rotation template** specific to your engine.
