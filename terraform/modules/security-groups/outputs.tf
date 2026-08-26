output "load_balancer_security_group_id" {
  description = "Security group ID for the PizzaBox ALB"
  value       = aws_security_group.lb.id
}

output "eks_security_group_id" {
  description = "Security group ID for EKS workloads"
  value       = aws_security_group.eks.id
}

output "database_security_group_id" {
  description = "Security group ID for PostgreSQL"
  value       = aws_security_group.db.id
}

output "redis_security_group_id" {
  description = "Security group ID for Redis"
  value       = aws_security_group.redis.id
}
