variable "cluster_name" {
  type = string
}

variable "cluster_role_arn" {
  type = string
}

variable "k8s_version" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "node_group_name" {
  type = string
}

variable "node_role_arn" {
  type = string
}

variable "desired_size" {
  type = number
}

variable "max_size" {
  type = number
}

variable "min_size" {
  type = number
}

variable "worker_instance_types" {
  type = list(string)
}

variable "admin_principal_arn" {
  type = string
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resource."
  default     = {}
}
