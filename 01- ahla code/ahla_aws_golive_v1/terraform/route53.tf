# OPTION: If hosting zone is managed in Route53, create records:
# resource "aws_route53_record" "alb" {
#   zone_id = "Z123456"
#   name    = var.domain_root
#   type    = "A"
#   alias {
#     name                   = aws_lb.alb.dns_name
#     zone_id                = aws_lb.alb.zone_id
#     evaluate_target_health = false
#   }
# }
# resource "aws_route53_record" "turn" {
#   zone_id = "Z123456"
#   name    = "turn.${var.domain_root}"
#   type    = "A"
#   alias {
#     name                   = aws_lb.nlb_turn.dns_name
#     zone_id                = aws_lb.nlb_turn.zone_id
#     evaluate_target_health = false
#   }
# }
