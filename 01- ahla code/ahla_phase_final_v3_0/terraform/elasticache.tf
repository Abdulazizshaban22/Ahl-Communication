resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.project}-cache-subnets"
  subnet_ids = var.elasticache_subnet_ids
}

resource "random_password" "redis_auth" {
  length  = 32
  special = false
}

resource "aws_secretsmanager_secret" "redis_auth" {
  name = "${var.project}/redis/auth"
}
resource "aws_secretsmanager_secret_version" "redis_auth_v" {
  secret_id     = aws_secretsmanager_secret.redis_auth.id
  secret_string = random_password.redis_auth.result
}

resource "aws_security_group" "redis" {
  name   = "${var.project}-redis-sg"
  vpc_id = aws_vpc.this.id
  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = concat([aws_security_group.tasks.id], var.elasticache_allowed_sgs)
  }
  egress  { from_port = 0 to_port = 0 protocol = "-1" cidr_blocks = ["0.0.0.0/0"] }
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id          = "${var.project}-redis"
  description                   = "Ahla Redis (TLS + AUTH)"
  engine                        = "redis"
  engine_version                = var.elasticache_engine_ver
  node_type                     = var.elasticache_node_type
  number_cache_clusters         = 2
  automatic_failover_enabled    = true
  multi_az_enabled              = true
  at_rest_encryption_enabled    = true
  transit_encryption_enabled    = true
  auth_token                    = aws_secretsmanager_secret_version.redis_auth_v.secret_string
  subnet_group_name             = aws_elasticache_subnet_group.this.name
  security_group_ids            = [aws_security_group.redis.id]
  port                          = 6379
  replicas_per_node_group       = var.elasticache_num_replicas

  lifecycle { ignore_changes = [auth_token] }
}
output "redis_primary_endpoint" { value = aws_elasticache_replication_group.redis.primary_endpoint_address }
output "redis_reader_endpoint"  { value = aws_elasticache_replication_group.redis.reader_endpoint_address }
