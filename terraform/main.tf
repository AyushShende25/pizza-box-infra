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
  source                 = "./modules/eks"
  cluster_name           = var.eks_cluster_name
  cluster_role_arn       = module.iam.cluster_role_arn
  k8s_version            = "1.35"
  subnet_ids             = values(module.vpc.app_subnet_ids)
  admin_principal_arn    = var.admin_principal_arn
  node_group_name        = "pizzabox-ng"
  node_role_arn          = module.iam.node_role_arn
  node_security_group_id = module.security_groups.eks_security_group_id
  worker_instance_types  = ["t3.medium"]
  desired_size           = 2
  max_size               = 4
  min_size               = 1
  tags                   = local.common_tags
}

data "aws_route53_zone" "main" {
  name         = var.r53_hosted_zone
  private_zone = false
}
module "irsa" {
  source = "./modules/irsa"

  oidc_provider_arn   = module.eks.oidc_provider_arn
  oidc_provider_url   = module.eks.oidc_provider_url
  r53_hosted_zone_id  = data.aws_route53_zone.main.zone_id
  secret_arn          = module.secrets_manager.secret_arn
  s3_media_bucket_arn = module.s3_media.bucket_arn
  cluster_name        = module.eks.cluster_name
  tags                = local.common_tags
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

  cluster_name                = module.eks.cluster_name
  r53_hosted_zone             = var.r53_hosted_zone
  external_dns_role_arn       = module.irsa.external_dns_role_arn
  eso_role_arn                = module.irsa.eso_role_arn
  lb_controller_role_arn      = module.irsa.lb_controller_role_arn
  vpc_id                      = module.vpc.vpc_id
  aws_region                  = var.aws_region
  cluster_autoscaler_role_arn = module.irsa.cluster_autoscaler_role_arn

  depends_on = [
    module.eks
  ]
}

module "acm" {
  source         = "./modules/acm"
  domain_name    = "*.${var.domain_name}"
  hosted_zone_id = data.aws_route53_zone.main.zone_id

  tags = merge(local.common_tags, {
    Purpose = "EKS Regional ALB"
  })
}

module "s3_media" {
  source = "./modules/s3"

  bucket_name = "${var.domain_name}-media-uploads"
  enable_cors = true

  cors_allowed_origins = [
    "https://admin.${var.domain_name}",
    "https://${var.domain_name}"
  ]

  tags = merge(local.common_tags,
    {
      Type = "media-uploads"
    }
  )
}

module "s3_react_client" {
  source = "./modules/s3"

  bucket_name = "${var.domain_name}-client"
  enable_cors = false

  tags = merge(local.common_tags,
    {
      Type = "frontend-client-static"
    }
  )
}
module "s3_react_admin" {
  source = "./modules/s3"

  bucket_name = "${var.domain_name}-admin"
  enable_cors = false

  tags = merge(local.common_tags,
    {
      Type = "frontend-admin-static"
    }
  )
}


module "cloudfront_react_client" {
  source = "./modules/cloudfront"

  name                           = "pizzabox-client-cdn"
  s3_bucket_id                   = module.s3_react_client.bucket_id
  s3_bucket_arn                  = module.s3_react_client.bucket_arn
  s3_bucket_regional_domain_name = module.s3_react_client.bucket_regional_domain_name
  domain_aliases                 = [var.domain_name]
  acm_certificate_arn            = module.acm_cloudfront.arn
  is_spa                         = true

  tags = local.common_tags
}
module "cloudfront_react_admin" {
  source = "./modules/cloudfront"

  name                           = "pizzabox-admin-cdn"
  s3_bucket_id                   = module.s3_react_admin.bucket_id
  s3_bucket_arn                  = module.s3_react_admin.bucket_arn
  s3_bucket_regional_domain_name = module.s3_react_admin.bucket_regional_domain_name
  domain_aliases                 = ["admin.${var.domain_name}"]
  acm_certificate_arn            = module.acm_cloudfront.arn
  is_spa                         = true

  tags = local.common_tags
}

module "cloudfront_media" {
  source = "./modules/cloudfront"

  name                           = "pizzabox-media-cdn"
  s3_bucket_id                   = module.s3_media.bucket_id
  s3_bucket_arn                  = module.s3_media.bucket_arn
  s3_bucket_regional_domain_name = module.s3_media.bucket_regional_domain_name
  domain_aliases                 = ["media.${var.domain_name}"]
  acm_certificate_arn            = module.acm_cloudfront.arn
  is_spa                         = false

  tags = local.common_tags
}


module "acm_cloudfront" {
  source = "./modules/acm"

  providers = {
    aws = aws.us_east_1
  }

  domain_name               = "*.${var.domain_name}"
  hosted_zone_id            = data.aws_route53_zone.main.zone_id
  subject_alternative_names = [var.domain_name]

  tags = merge(local.common_tags, {
    Purpose = "PizzaBox CloudFront"
  })
}


module "dns_react_client" {
  source = "./modules/route53"

  hosted_zone_id  = data.aws_route53_zone.main.zone_id
  domain_name     = var.domain_name
  target_dns_name = module.cloudfront_react_client.domain_name
  target_zone_id  = module.cloudfront_react_client.hosted_zone_id
}

module "dns_react_admin" {
  source = "./modules/route53"

  hosted_zone_id  = data.aws_route53_zone.main.zone_id
  domain_name     = "admin.${var.domain_name}"
  target_dns_name = module.cloudfront_react_admin.domain_name
  target_zone_id  = module.cloudfront_react_admin.hosted_zone_id
}


module "dns_media" {
  source = "./modules/route53"

  hosted_zone_id  = data.aws_route53_zone.main.zone_id
  domain_name     = "media.${var.domain_name}"
  target_dns_name = module.cloudfront_media.domain_name
  target_zone_id  = module.cloudfront_media.hosted_zone_id
}

module "github_actions_oidc" {
  source = "./modules/github-actions-oidc"
}

module "github_api_ci" {
  source = "./modules/github-actions-role"

  role_name         = "github-actions-api-ci"
  oidc_provider_arn = module.github_actions_oidc.arn
  github_repository = var.github_api_repo
  allowed_branch    = "main"

  policy_arns = {
    ecr_policy_arn = aws_iam_policy.api_ecr_push.arn
  }
}

module "github_client_ci" {
  source = "./modules/github-actions-role"

  role_name         = "github-actions-client-ci"
  oidc_provider_arn = module.github_actions_oidc.arn
  github_repository = var.github_client_repo
  allowed_branch    = "main"

  policy_arns = {
    s3_policy_arn = aws_iam_policy.client_s3_deploy.arn
  }
}

module "github_admin_ci" {
  source = "./modules/github-actions-role"

  role_name         = "github-actions-admin-ci"
  oidc_provider_arn = module.github_actions_oidc.arn
  github_repository = var.github_admin_repo
  allowed_branch    = "main"

  policy_arns = {
    s3_policy_arn = aws_iam_policy.admin_s3_deploy.arn
  }

}
