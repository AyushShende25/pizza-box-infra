variable "oidc_provider_arn" {
  type = string
}

variable "oidc_provider_url" {
  type = string
}

variable "r53_hosted_zone_id" {
  type = string
}

variable "secret_arn" {
  type = string
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resource."
  default     = {}
}

variable "s3_media_bucket_arn" {
  type        = string
  description = "ARN of the media-uploads S3 Bucket"
}
