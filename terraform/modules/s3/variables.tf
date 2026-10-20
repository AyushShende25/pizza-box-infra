variable "bucket_name" {
  type        = string
  description = "Unique S3 bucket name"
}

variable "client_url" {
  type        = string
  description = "Frontend origin allowed to make CORS requests (e.g. https://pizzabox.fullstackprojects.dev)"
  default     = "*"
}

variable "enable_cors" {
  type        = bool
  description = "Enable CORS rules on this bucket (Required for uploads/media bucket)"
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default     = {}
}
