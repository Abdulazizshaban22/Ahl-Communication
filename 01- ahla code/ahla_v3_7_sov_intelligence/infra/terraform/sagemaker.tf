# Minimal SageMaker endpoint wiring (adjust IAM/roles/bucket names)
resource "aws_sagemaker_model" "ahla_aif_model" {
  name               = var.sm_model_name
  execution_role_arn = var.sm_exec_role_arn
  primary_container {
    image          = var.sm_image_uri
    mode           = "SingleModel"
    model_data_url = var.sm_model_s3
    environment = {
      SAGEMAKER_REGION = var.region
    }
  }
}

resource "aws_sagemaker_endpoint_configuration" "ahla_aif_cfg" {
  name = var.sm_endpoint_cfg
  production_variants {
    variant_name           = "AllTraffic"
    model_name             = aws_sagemaker_model.ahla_aif_model.name
    initial_instance_count = 1
    instance_type          = "ml.m5.large"
    initial_variant_weight = 1
  }
  data_capture_config {
    enable_capture = true
    initial_sampling_percentage = 100
    destination_s3_uri = "s3://${var.capture_bucket}/aif/capture/"
    capture_options { capture_mode = "Input" }
    capture_options { capture_mode = "Output" }
  }
}

resource "aws_sagemaker_endpoint" "ahla_aif" {
  name = var.sm_endpoint_name
  endpoint_config_name = aws_sagemaker_endpoint_configuration.ahla_aif_cfg.name
}
