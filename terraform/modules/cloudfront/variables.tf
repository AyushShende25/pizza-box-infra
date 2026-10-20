variable "name" {
  type        = string
  description = "Name identifier for the distribution"
}

variable "s3_bucket_id" {
  type        = string
  description = "S3 bucket ID/Name"
}

variable "s3_bucket_arn" {
  type        = string
  description = "S3 bucket ARN"
}

variable "s3_bucket_regional_domain_name" {
  type        = string
  description = "Regional domain name of the S3 bucket"
}

variable "domain_aliases" {
  type        = list(string)
  description = "Custom domain aliases (e.g. ['pizzabox.fullstackprojects.dev'])"
  default     = []
}

variable "acm_certificate_arn" {
  type        = string
  description = "ARN of ACM Certificate in us-east-1 (Required if using custom domains)"
  default     = null
}

variable "is_spa" {
  type        = bool
  description = "If true, routes 403/404 errors to /index.html (Required for React Single Page Applications)"
  default     = false
}

variable "tags" {
  type    = map(string)
  default = {}
}
