
resource "aws_security_group" "redis" {
  name   = "${var.name}-sg"
  vpc_id = var.vpc_id
  ingress { from_port=6379, to_port=6379, protocol="tcp", security_groups=[var.allowed_sg_id] }
  egress  { from_port=0, to_port=0, protocol="-1", cidr_blocks=["0.0.0.0/0"] }
}

resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.name}-subnets"
  subnet_ids = var.private_subnets
}

resource "aws_elasticache_cluster" "this" {
  cluster_id           = var.name
  engine               = "redis"
  engine_version       = var.engine_version
  node_type            = var.node_type
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.this.name
  security_group_ids   = [aws_security_group.redis.id]
}

output "redis_endpoint" { value = aws_elasticache_cluster.this.cache_nodes[0].address }
