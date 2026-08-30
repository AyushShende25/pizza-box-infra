output "secret_arn" {
  type  = string
  value = aws_secretsmanager_secret.sm.arn
}
