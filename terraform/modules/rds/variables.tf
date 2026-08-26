variable "db_subnet_group_name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resource."
  default     = {}
}

variable "db_name" {
  type = string
}

variable "username" {
  type = string
}

variable "password" {
  type      = string
  sensitive = true
}

variable "instance_class" {
  type = string
}

variable "allocated_storage" {
  type = number
}

variable "db_identifier" {
  type = string
}

variable "engine_version" {
  type = string
}

variable "skip_final_snapshot" {
  type = bool
}

variable "backup_retention_period" {
  type = number
}

variable "vpc_security_group_ids" {
  type = list(string)
}
