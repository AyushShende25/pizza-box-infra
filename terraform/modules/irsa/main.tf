# Trust policy for ESO IRSA
data "aws_iam_policy_document" "eks_eso_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_url}:sub"
      values   = ["system:serviceaccount:external-secrets:external-secrets"]
    }
    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_url}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "eso_role" {
  name               = "eks-eso-role"
  assume_role_policy = data.aws_iam_policy_document.eks_eso_assume_role.json
  tags               = var.tags
}

data "aws_iam_policy_document" "secrets_manager_reader_policy" {
  statement {
    sid    = "SecretsManagerGetAndDescribeSecret"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = [var.secret_arn]
  }
}

resource "aws_iam_policy" "secrets_manager_reader_policy" {
  name   = "SecretsManagerReaderIAMPolicy"
  path   = "/"
  policy = data.aws_iam_policy_document.secrets_manager_reader_policy.json
}
resource "aws_iam_role_policy_attachment" "secrets_manager_reader_policy" {
  role       = aws_iam_role.eso_role.name
  policy_arn = aws_iam_policy.secrets_manager_reader_policy.arn
}



# Trust policy for aws-load-balancer-controller

data "aws_iam_policy_document" "eks_lb_controller_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_url}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_url}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "lb_role" {
  name               = "eks-lb-controller-role"
  assume_role_policy = data.aws_iam_policy_document.eks_lb_controller_assume_role.json
  tags               = var.tags
}

resource "aws_iam_policy" "lb_controller_policy" {
  name   = "AWSLoadBalancerControllerIAMPolicy"
  path   = "/"
  policy = file("${path.module}/load-balancer-controller-policy.json")
}

resource "aws_iam_role_policy_attachment" "lb_controller_policy" {
  role       = aws_iam_role.lb_role.name
  policy_arn = aws_iam_policy.lb_controller_policy.arn
}



# Trust policy for external-dns IRSA

data "aws_iam_policy_document" "external_dns_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_url}:sub"
      values   = ["system:serviceaccount:external-dns:external-dns"]
    }
    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_url}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "external_dns_role" {
  name               = "external-dns-role"
  assume_role_policy = data.aws_iam_policy_document.external_dns_assume_role.json
  tags               = var.tags
}


data "aws_iam_policy_document" "external_dns_policy" {
  statement {
    sid    = "ManageRoute53Records"
    effect = "Allow"

    actions = [
      "route53:ChangeResourceRecordSets",
    ]

    resources = [
      "arn:aws:route53:::hostedzone/${var.r53_hosted_zone_id}"
    ]
  }

  statement {
    sid    = "ReadRoute53Records"
    effect = "Allow"

    actions = [
      "route53:ListResourceRecordSets",
    ]

    resources = [
      "arn:aws:route53:::hostedzone/${var.r53_hosted_zone_id}"
    ]
  }

  statement {
    sid    = "DiscoverRoute53Zones"
    effect = "Allow"

    actions = [
      "route53:ListHostedZones",
      "route53:ListTagsForResources",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "external_dns_policy" {
  name   = "ExternalDNSIAMPolicy"
  path   = "/"
  policy = data.aws_iam_policy_document.external_dns_policy.json
}

resource "aws_iam_role_policy_attachment" "external_dns_policy" {
  role       = aws_iam_role.external_dns_role.name
  policy_arn = aws_iam_policy.external_dns_policy.arn
}

data "aws_iam_policy_document" "pizzabox_uploader_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_url}:sub"
      values   = ["system:serviceaccount:pizzabox-app-ns:s3-uploader-serviceaccount"]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_url}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "pizzabox_uploader_role" {
  name               = "pizzabox-uploader-role"
  assume_role_policy = data.aws_iam_policy_document.pizzabox_uploader_assume_role.json
  tags               = var.tags
}

data "aws_iam_policy_document" "s3_media_policy" {
  statement {
    sid    = "ManageMediaObjects"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]
    resources = ["${var.s3_media_bucket_arn}/*"]
  }

  statement {
    sid       = "ReadMediaBucketMetadata"
    effect    = "Allow"
    actions   = ["s3:ListBucket", "s3:GetBucketLocation"]
    resources = [var.s3_media_bucket_arn]
  }
}
resource "aws_iam_policy" "s3_media_policy" {
  name        = "pizzabox-uploader-s3-media-policy"
  description = "Allows the PizzaBox API to access media objects"
  policy      = data.aws_iam_policy_document.s3_media_policy.json
}
resource "aws_iam_role_policy_attachment" "s3_media_policy" {
  role       = aws_iam_role.pizzabox_uploader_role.name
  policy_arn = aws_iam_policy.s3_media_policy.arn
}
