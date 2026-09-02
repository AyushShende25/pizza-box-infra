variable "domain_name" {
  type        = string
  description = "Primary domain for the certificate"
}

variable "subject_alternative_names" {
  type        = list(string)
  description = "Additional domains/subdomains (e.g. ['api.inkspire.fullstackprojects.dev'])"
  default     = []
}

variable "hosted_zone_id" {
  type        = string
  description = "Route 53 Hosted Zone ID for creating DNS validation records"
}

variable "tags" {
  type    = map(string)
  default = {}
}
