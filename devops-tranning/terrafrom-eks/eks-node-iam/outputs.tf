output "role_arn" {
  description = "ARN của EKS Node Role"
  value       = aws_iam_role.eks_node_role.arn
}
