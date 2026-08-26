variable "aws_region" {
  description = "The AWS region to create resources in"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  type    = string
  default = "production"
}

variable "domain_name" {
  type = string
}

variable "vpc_cidr" {
  type        = string
  description = "The IPv4 CIDR block for the VPC."
}

variable "subnets" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
    type              = string
  }))
  description = "Map of subnets to create, key = subnet name"
}

# EKS
variable "eks_cluster_name" {
  type = string
}

variable "admin_principal_arn" {
  type = string
}

# ECR

variable "ecr_repository_name" {
  type        = string
  description = "Name of the ECR repository"
}

variable "image_tag_mutability" {
  type        = string
  description = "The tag mutability setting for the repository. Must be MUTABLE or IMMUTABLE"
  default     = "IMMUTABLE"
}

# DATABASE - RDS

variable "db_subnet_group_name" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_identifier" {
  type = string
}
variable "psql_version" {
  type = string
}
variable "db_instance_class" {
  type = string
}

variable "db_allocated_storage" {
  type = number
}
