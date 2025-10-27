variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "cluster_name" {
  description = "Tên của EKS cluster"
  type        = string
  default     = "tien-tran-eks-cluster"
}

variable "vpc_name" {
  description = "Tên của VPC"
  type        = string
  default     = "tien-tran-eks-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block cho VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Danh sách các availability zones"
  type        = list(string)
  default     = ["ap-southeast-1a", "ap-southeast-1b"]
}

variable "public_subnets_cidr" {
  description = "CIDR block cho các public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets_cidr" {
  description = "CIDR block cho các private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "tags" {
  description = "Các tag mặc định"
  type        = map(string)
  default = {
    Project = "EKS"
  }
}
