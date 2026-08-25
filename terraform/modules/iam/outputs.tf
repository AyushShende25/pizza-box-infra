output "cluster_role_arn" {
  value      = aws_iam_role.cluster.arn
  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}

output "node_role_arn" {
  value = aws_iam_role.node_role.arn
  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ec2_container_registry_read_only
  ]
}
