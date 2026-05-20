
# Blue/Green & Canary via ALB — Pattern
- For each *web* service, create a duplicate ECS Service (green) and a second Target Group.
- Add a `listener_rule` with `forward` block and weights (e.g., 90/10).
- Promote by adjusting weights to 100/0 then remove the old one.
See `terraform/envs/prod/bluegreen_examples.tf` for `chat-web` example; replicate for meet/drive/business/mail.
