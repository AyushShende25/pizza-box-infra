resource "aws_elasticache_subnet_group" "redis" {
  name       = var.redis_subnet_group_name
  subnet_ids = var.subnet_ids

  tags = merge(
    var.tags,
    { Name = var.redis_subnet_group_name }
  )
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id       = var.replication_group_id
  description                = "Redis replication group for ${var.replication_group_id}"
  engine                     = "redis"
  engine_version             = var.engine_version
  node_type                  = var.node_type
  port                       = var.port
  automatic_failover_enabled = true
  multi_az_enabled           = true
  num_cache_clusters         = var.num_cache_clusters
  cluster_mode               = "disabled"

  transit_encryption_enabled = true
  at_rest_encryption_enabled = true
  auth_token                 = var.password
  subnet_group_name          = aws_elasticache_subnet_group.redis.name
  security_group_ids         = var.security_group_ids
  parameter_group_name       = var.parameter_group_name

  tags = var.tags
}
