variable "project" {}
variable "vpc_cidr" {}
variable "public_subnets" { type=list(string) }
variable "private_subnets" { type=list(string) }

resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  tags = { Name = "${var.project}-vpc" }
}
resource "aws_internet_gateway" "igw" { vpc_id = aws_vpc.this.id }
resource "aws_subnet" "public" {
  for_each = toset(var.public_subnets)
  vpc_id = aws_vpc.this.id
  cidr_block = each.value
  map_public_ip_on_launch = true
}
resource "aws_subnet" "private" {
  for_each = toset(var.private_subnets)
  vpc_id = aws_vpc.this.id
  cidr_block = each.value
}
output "vpc_id" { value = aws_vpc.this.id }
output "public_subnet_ids" { value = [for s in aws_subnet.public: s.id] }
output "private_subnet_ids" { value = [for s in aws_subnet.private: s.id] }