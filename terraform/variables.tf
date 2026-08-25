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


variable "eks_cluster_name" {
  type = string
}

variable "admin_principal_arn" {
  type = string
}
