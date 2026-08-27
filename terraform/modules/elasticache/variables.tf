variable "redis_subnet_group_name" {
  type        = string
  description = "Name for the ElastiCache subnet group"
}

variable "node_type" {
  type        = string
  description = "Instance type for Redis nodes"
}

variable "replication_group_id" {
  type        = string
  description = "Unique identifier for the replication group"
}

variable "engine_version" {
  type        = string
  description = "Redis engine version"
  default     = "7.0"
}

variable "parameter_group_name" {
  type        = string
  description = "Redis parameter group name"
  default     = "default.redis7"
}

variable "password" {
  type        = string
  description = "Password (AUTH token) for Redis client authentication"
  sensitive   = true
}

variable "port" {
  type    = number
  default = 6379
}

variable "num_cache_clusters" {
  type    = number
  default = 2
}

variable "security_group_ids" {
  type        = list(string)
  description = "List of security group IDs to attach to Redis"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs where Redis nodes will live"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resource."
  default     = {}
}
