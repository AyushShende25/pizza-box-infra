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
  subnets          = var.subnets
  eks_cluster_name = var.eks_cluster_name
  env              = var.environment

  tags = merge(
    local.common_tags,
    {
      Name = "pizzabox_vpc"
    }
  )
}

module "iam" {
  source = "./modules/iam"
  tags   = local.common_tags
}

module "eks" {
  source                = "./modules/eks"
  cluster_name          = var.eks_cluster_name
  cluster_role_arn      = module.iam.cluster_role_arn
  k8s_version           = "1.35"
  subnet_ids            = values(module.vpc.app_subnet_ids)
  admin_principal_arn   = var.admin_principal_arn
  node_group_name       = "pizzabox-ng"
  node_role_arn         = module.iam.node_role_arn
  desired_size          = 2
  max_size              = 4
  min_size              = 1
  worker_instance_types = ["t3.small"]

  tags = local.common_tags
}
