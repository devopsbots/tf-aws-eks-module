output "eks_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "eks_cluster_id" {
  description = "The name of the cluster"
  value       = join("", aws_eks_cluster.eks_cluster.*.id)
}

output "eks_cluster_ca_cert" {
  value = base64decode(aws_eks_cluster.eks_cluster.certificate_authority[0].data)
}

output "eks_cluster_security_group_id" {
  value = aws_eks_cluster.eks_cluster.vpc_config.0.cluster_security_group_id
}

output "eks_worker_group_sg" {
  value = aws_security_group.eks_worker_group.id
}

output "eks_oidc_issuer" {
  value = aws_eks_cluster.eks_cluster.identity.0.oidc.0.issuer
}

output "openid_connect_provider_arn" {
  value = aws_iam_openid_connect_provider.cluster.arn
}
