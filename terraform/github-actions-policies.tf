data "aws_iam_policy_document" "api_ecr_push" {
  statement {
    sid       = "GetECRAuthorizationToken"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid    = "PushBackendImages"
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
      "ecr:BatchGetImage",
    ]

    resources = [module.app_ecr.repository_arn]
  }
}

resource "aws_iam_policy" "api_ecr_push" {
  name        = "github-pizzabox-api-ecr-push"
  description = "Allow GitHub Actions to push images to the PizzaBox backend ECR repository"
  policy      = data.aws_iam_policy_document.api_ecr_push.json
}

data "aws_iam_policy_document" "client_s3_deploy" {
  statement {
    sid    = "ListClientBucket"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]

    resources = [
      module.s3_react_client.bucket_arn
    ]
  }

  statement {
    sid    = "ManageClientAssets"
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
    ]

    resources = [
      "${module.s3_react_client.bucket_arn}/*"
    ]
  }

  statement {
    sid    = "CreateInvalidation"
    effect = "Allow"
    actions = [
      "cloudfront:CreateInvalidation"
    ]
    resources = [module.cloudfront_react_client.arn]
  }
}

resource "aws_iam_policy" "client_s3_deploy" {
  name        = "github-pizzabox-client-s3-deploy"
  description = "Allow GitHub Actions to deploy client frontend assets to S3"
  policy      = data.aws_iam_policy_document.client_s3_deploy.json
}



data "aws_iam_policy_document" "admin_s3_deploy" {
  statement {
    sid    = "ListAdminBucket"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]

    resources = [module.s3_react_admin.bucket_arn]
  }

  statement {
    sid    = "ManageAdminAssets"
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
    ]

    resources = [
      "${module.s3_react_admin.bucket_arn}/*"
    ]
  }

  statement {
    sid    = "CreateInvalidation"
    effect = "Allow"
    actions = [
      "cloudfront:CreateInvalidation"
    ]
    resources = [module.cloudfront_react_admin.arn]
  }
}

resource "aws_iam_policy" "admin_s3_deploy" {
  name        = "github-pizzabox-admin-s3-deploy"
  description = "Allow GitHub Actions to deploy admin frontend assets to S3"
  policy      = data.aws_iam_policy_document.admin_s3_deploy.json
}
