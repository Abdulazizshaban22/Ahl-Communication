
variable "lambda_geoip_layer_arn" { type = string }
# usage example:
# resource "aws_lambda_function" "alb_s3_to_firehose" {
#   filename = "${path.module}/lambda_alb_s3_to_firehose_geoip.zip"
#   layers   = [ var.lambda_geoip_layer_arn ]
# }
