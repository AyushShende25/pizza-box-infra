locals {
  common_tags = {
    Env     = var.environment
    Project = var.domain_name
  }
}

module "vpc" {
  source           = "./modules/vpc"
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  subnets = var.subnets
  tags = merge(
    local.common_tags,
    {
      Name = "pizzabox_vpc"
    }
  )
}
