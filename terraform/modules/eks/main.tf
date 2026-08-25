
# CLUSTER
resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.k8s_version

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = false
  }

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  tags = var.tags
}


# WORKER-NODES
resource "aws_eks_node_group" "eks_ng" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = var.node_group_name
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids
  instance_types  = var.worker_instance_types
  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  update_config {
    max_unavailable = 1
  }

  tags = var.tags
}

# OIDC
data "tls_certificate" "eks" {
  url = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks.identity[0].oidc[0].issuer

  tags = var.tags
}

# ACCESS-ENTRY
resource "aws_eks_access_entry" "admin" {
  cluster_name  = aws_eks_cluster.eks.name
  principal_arn = var.admin_principal_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin" {
  cluster_name  = aws_eks_cluster.eks.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = var.admin_principal_arn

  access_scope {
    type = "cluster"
  }
}


# ADD-ONS
resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.eks.name
  addon_name   = "vpc-cni"
}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.eks.name
  addon_name   = "coredns"
  depends_on   = [aws_eks_node_group.eks_ng]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.eks.name
  addon_name   = "kube-proxy"
}
