variable "hosted_zone_id" {
  type        = string
  description = "Route 53 Hosted Zone ID"
}

variable "domain_name" {
  type        = string
  description = "Subdomain name (e.g. api.pizzabox.fullstackprojects.dev)"
}

variable "target_dns_name" {
  type        = string
  description = "Target DNS name (ALB DNS name or CloudFront domain)"
}

variable "target_zone_id" {
  type        = string
  description = "Target Hosted Zone ID (ALB zone ID or CloudFront zone ID)"
}
