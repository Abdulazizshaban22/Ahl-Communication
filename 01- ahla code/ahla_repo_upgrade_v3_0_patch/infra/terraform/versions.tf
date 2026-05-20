terraform {
  required_version = ">= 1.6.0"
  required_providers { aws = { source = "hashicorp/aws", version = ">= 5.43.0" } }
}
provider "aws" { region = var.region }
provider "aws" { alias = "use1"; region = "us-east-1" }
