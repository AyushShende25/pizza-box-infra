output "fqdn" {
  description = "Fully Qualified Domain Name of the DNS record"
  value       = aws_route53_record.alias.fqdn
}
