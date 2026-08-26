variable "vpc_id" {
  type        = string
  description = "The VPC ID where security groups will be created."
}

variable "api_port" {
  type        = number
  description = "App API port"
  default     = 80
}

variable "postgres_port" {
  type        = number
  description = "Database port"
  default     = 5432
}

variable "redis_port" {
  type        = number
  description = "Redis port"
  default     = 6379
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resource."
  default     = {}
}
