# Cấu hình AWS Provider
provider "aws" {
  region = var.aws_region
}

# Sử dụng module vpc
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  # Định nghĩa các subnet public và private trên 2 AZs khác nhau
  azs             = var.azs
  public_subnets  = var.public_subnets_cidr
  private_subnets = var.private_subnets_cidr

  # Cấu hình NAT Gateway để private subnet có thể truy cập internet (pull image, update)
  enable_nat_gateway = true
  single_nat_gateway = true # Tùy chọn để tiết kiệm chi phí

  # Bật DNS
  enable_dns_support   = true
  enable_dns_hostnames = true

  # Tag đặc biệt để EKS nhận biết các subnet
  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}
