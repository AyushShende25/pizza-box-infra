variable "cidr_block" {
  type        = string
  description = "The IPv4 CIDR block for the VPC."
}

variable "instance_tenancy" {
  type        = string
  description = "The tenancy option for instances launched into the VPC."
  default     = "default"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resource."
  default     = {}
}

variable "subnets" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
    type              = string
  }))
  description = "Map of subnets to create, key = subnet name"
}
