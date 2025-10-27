output "eks_cluster_id" {
  description = "ID của EKS cluster"
  value       = module.eks.cluster_id
}

output "eks_cluster_endpoint" {
  description = "Endpoint của EKS cluster API"
  value       = module.eks.cluster_endpoint
}

output "kubeconfig" {
  description = "kubeconfig để kết nối"
  value       = module.eks.kubeconfig
}
