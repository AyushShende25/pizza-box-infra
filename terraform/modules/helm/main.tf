terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
    }
  }
}

resource "helm_release" "eso" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  version          = "2.10.0"
  namespace        = "external-secrets"
  create_namespace = true

  set = [
    {
      name  = "serviceAccount.name"
      value = "external-secrets"
    },
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = var.eso_role_arn
    },
  ]

  depends_on = [
    helm_release.alb
  ]
}

resource "helm_release" "alb" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "3.5.0"
  namespace  = "kube-system"

  set = [
    {
      name  = "clusterName"
      value = var.cluster_name
    },
    {
      name  = "vpcId"
      value = var.vpc_id
    },
    {
      name  = "serviceAccount.create"
      value = true
    },
    {
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller"
    },
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = var.lb_controller_role_arn
    }
  ]
}

resource "helm_release" "dns" {
  name             = "external-dns"
  version          = "1.21.1"
  repository       = "https://kubernetes-sigs.github.io/external-dns/"
  chart            = "external-dns"
  namespace        = "external-dns"
  create_namespace = true

  set = [
    {
      name  = "provider.name"
      value = "aws"
    },
    {
      name  = "policy"
      value = "sync"
    },
    {
      name  = "domainFilters[0]"
      value = var.r53_hosted_zone
    },
    {
      name  = "txtOwnerId"
      value = var.cluster_name
    },
    {
      name  = "sources[0]"
      value = "ingress"
    },
    {
      name  = "serviceAccount.create"
      value = true
    },
    {
      name  = "serviceAccount.name"
      value = "external-dns"
    },
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = var.external_dns_role_arn
    }
  ]

  set_list = [{
    name = "extraArgs"
    value = [
      "--aws-zone-type=public"
    ]
  }]

  depends_on = [
    helm_release.alb
  ]
}
