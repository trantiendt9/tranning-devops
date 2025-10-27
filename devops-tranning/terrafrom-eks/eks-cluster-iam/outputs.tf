output "role_arn" {
  description = "ARN của EKS Cluster Role"
  value       = aws_iam_role.eks_cluster_role.arn
}
