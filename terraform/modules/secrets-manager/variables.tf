variable "secret_name" {
  type = string
}

variable "database_user" {
  type        = string
  description = "Master username for PostgreSQL database"
}

variable "database_password" {
  type        = string
  description = "Master password for PostgreSQL database"
  sensitive   = true
}

variable "database_endpoint" {
  type        = string
  description = "PostgreSQL endpoint from RDS module (e.g. host:port or hostname)"
}

variable "database_name" {
  type        = string
  description = "Database name"
}

variable "redis_endpoint" {
  type        = string
  description = "Redis primary endpoint hostname or IP"
}

variable "redis_password" {
  type        = string
  description = "Redis auth password (if AUTH enabled)"
  default     = ""
  sensitive   = true
}

variable "env_var_jwt_secret_key" {
  type = string
}
variable "env_var_mail_username" {
  type = string
}
variable "env_var_mail_password" {
  type = string
}
variable "env_var_rzp_key_id" {
  type = string
}
variable "env_var_rzp_key_secret" {
  type = string
}


variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resource."
  default     = {}
}
