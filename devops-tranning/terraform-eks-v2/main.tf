<<<<<<< HEAD
# main.tf

# Cấu hình các providers và đảm bảo sử dụng phiên bản mới nhất
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}

# Provider AWS
provider "aws" {
  region = var.aws_region
}

# Sử dụng Data Source để lấy thông tin VPC đã có sẵn
data "aws_vpc" "devops-vpc" {
  id = var.vpc_id
}

# Sử dụng Data Source để lấy thông tin các subnets đã có sẵn
data "aws_subnets" "devops-vpc" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  tags = {
    # Sử dụng các tags để lọc ra các private subnets mong muốn
    "purpose" = "eks-private" 
  }
}

# Tạo cụm EKS với module EKS
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  # Các biến đã được đổi tên trong module v21.0+
  name               = var.cluster_name
  kubernetes_version = var.cluster_version

  # Truyền ID của VPC và subnets đã có sẵn
  vpc_id     = data.aws_vpc.devops-vpc.id
  subnet_ids = data.aws_subnets.devops-vpc.ids

  # Cấu hình các nút (nodes)
  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.small"]
      min_size       = 1
      max_size       = 3
      desired_size   = 2
    }
  }
}

# Không tạo kubeconfig bằng Terraform
# Sau khi `terraform apply` hoàn tất, chạy lệnh:
# `aws eks update-kubeconfig --name <cluster_name> --region <aws_region>`
=======
# main.tf

# Cấu hình các providers và đảm bảo sử dụng phiên bản mới nhất
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}

# Provider AWS
provider "aws" {
  region = var.aws_region
}

# Sử dụng Data Source để lấy thông tin VPC đã có sẵn
data "aws_vpc" "devops-vpc" {
  id = var.vpc_id
}

# Sử dụng Data Source để lấy thông tin các subnets đã có sẵn
data "aws_subnets" "devops-vpc" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  tags = {
    # Sử dụng các tags để lọc ra các private subnets mong muốn
    "purpose" = "eks-private" 
  }
}

# Tạo cụm EKS với module EKS
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  # Các biến đã được đổi tên trong module v21.0+
  name               = var.cluster_name
  kubernetes_version = var.cluster_version

  # Truyền ID của VPC và subnets đã có sẵn
  vpc_id     = data.aws_vpc.devops-vpc.id
  subnet_ids = data.aws_subnets.devops-vpc.ids

  # Cấu hình các nút (nodes)
  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.small"]
      min_size       = 1
      max_size       = 3
      desired_size   = 2
    }
  }
}

# Không tạo kubeconfig bằng Terraform
# Sau khi `terraform apply` hoàn tất, chạy lệnh:
# `aws eks update-kubeconfig --name <cluster_name> --region <aws_region>`
>>>>>>> 3b3555d05f0199d1d80fea95d701706c6da139ea
