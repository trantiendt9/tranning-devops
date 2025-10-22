# Cấu hình AWS provider
provider "aws" {
  region = var.aws_region
}

# Gọi module VPC
module "vpc" {
  source = "./vpc"

  vpc_name           = var.vpc_name
  vpc_cidr           = var.vpc_cidr
  azs                = var.azs
  public_subnets_cidr  = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
  cluster_name       = var.cluster_name
}

# Gọi module IAM Role cho EKS Cluster
module "eks_cluster_iam" {
  source = "./eks-cluster-iam"

  role_name = "${var.cluster_name}-eks-cluster-role"
  tags      = var.tags
}

# Gọi module IAM Role cho EKS Node
module "eks_node_iam" {
  source = "./eks-node-iam"

  role_name = "${var.cluster_name}-eks-node-role"
  tags      = var.tags
}

# Tạo EKS Cluster sử dụng module `terraform-aws-modules/eks/aws`
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0" # Sử dụng phiên bản mới nhất để tương thích với Kubernetes 1.34

  cluster_name    = var.cluster_name
  cluster_version = "1.34" # Chỉ định phiên bản Kubernetes là 1.34
  vpc_id          = module.vpc.vpc_id # Lấy VPC ID từ output của module VPC
  subnet_ids      = module.vpc.private_subnets # Lấy private subnets từ output của module VPC
  cluster_role_arn = module.eks_cluster_iam.role_arn # Lấy ARN của EKS Cluster Role

  # Định nghĩa nhóm node được quản lý bởi EKS (EKS Managed Node Groups)
  eks_managed_node_groups = {
    eks_nodes = {
      name         = "${var.cluster_name}-node-group"
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 5
      desired_size   = 1
      iam_role_arn   = module.eks_node_iam.role_arn # Lấy ARN của EKS Node Role
    }
  }

  tags = var.tags
}
