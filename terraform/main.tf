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
module "app_ecr" {
  source = "./modules/ecr"

  name                 = var.ecr_repository_name
  image_tag_mutability = var.image_tag_mutability
  scan_on_push         = true
  force_delete         = true

  tags = local.common_tags
}

module "security_groups" {
  source   = "./modules/security-groups"
  vpc_id   = module.vpc.vpc_id
  api_port = 8000

  tags = local.common_tags
}

module "rds" {
  source                  = "./modules/rds"
  db_identifier           = var.db_identifier
  engine_version          = var.psql_version
  db_subnet_group_name    = var.db_subnet_group_name
  subnet_ids              = values(module.vpc.db_subnet_ids)
  db_name                 = var.db_name
  allocated_storage       = var.db_allocated_storage
  instance_class          = var.db_instance_class
  username                = var.db_username
  password                = var.db_password
  backup_retention_period = 1
  skip_final_snapshot     = true
  vpc_security_group_ids  = [module.security_groups.database_security_group_id]
  tags = merge(local.common_tags,
    {
      Name = "pizzabox-database"
    }
  )
}
