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
data "aws_route53_zone" "main" {
  name         = var.r53_hosted_zone
  private_zone = false
}
module "irsa" {
  source = "./modules/irsa"

  oidc_provider_arn  = module.eks.oidc_provider_arn
  oidc_provider_url  = module.eks.oidc_provider_url
  r53_hosted_zone_id = data.aws_route53_zone.main.zone_id
  secret_arn         = module.secrets_manager.secret_arn

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

module "redis" {
  source                  = "./modules/elasticache"
  replication_group_id    = var.redis_replication_group_name
  node_type               = var.redis_node_type
  redis_subnet_group_name = var.redis_subnet_group_name
  security_group_ids      = [module.security_groups.redis_security_group_id]
  subnet_ids              = values(module.vpc.db_subnet_ids)
  engine_version          = var.redis_engine_version
  password                = var.redis_password
  num_cache_clusters      = var.num_cache_clusters
  tags = merge(local.common_tags,
    {
      Name = "pizzabox-redis"

    }
  )
}

module "secrets_manager" {
  source = "./modules/secrets-manager"

  secret_name = "pizzabox/production/api"

  database_endpoint = module.rds.endpoint
  database_name     = module.rds.db_name
  database_password = var.db_password
  database_user     = var.db_username

  redis_endpoint = module.redis.primary_endpoint
  redis_password = var.redis_password

  env_var_jwt_secret_key = var.env_var_jwt_secret_key
  env_var_mail_username  = var.env_var_mail_username
  env_var_mail_password  = var.env_var_mail_password
  env_var_rzp_key_id     = var.env_var_rzp_key_id
  env_var_rzp_key_secret = var.env_var_rzp_key_secret

  tags = local.common_tags
}


module "helm" {
  source = "./modules/helm"

  cluster_name           = module.eks.cluster_name
  r53_hosted_zone        = var.r53_hosted_zone
  external_dns_role_arn  = module.irsa.external_dns_role_arn
  eso_role_arn           = module.irsa.eso_role_arn
  lb_controller_role_arn = module.irsa.lb_controller_role_arn
  vpc_id                 = module.vpc.vpc_id
}

module "acm" {
  source         = "./modules/acm"
  domain_name    = "*.${var.domain_name}"
  hosted_zone_id = data.aws_route53_zone.main.zone_id

  tags = merge(local.common_tags, {
    Purpose = "EKS Regional ALB"
  })
}
