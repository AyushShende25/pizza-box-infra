output "eso_role_arn" {
  value = aws_iam_role.eso_role.arn
}

output "lb_controller_role_arn" {
  value = aws_iam_role.lb_role.arn
}

output "external_dns_role_arn" {
  value = aws_iam_role.external_dns_role.arn
}
