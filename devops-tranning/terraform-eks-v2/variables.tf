# variables.tf
variable "aws_region" {
  description = "Khu vực AWS để tạo cụm EKS."
  type        = string
  default     = "ap-southeast-1"
}

variable "vpc_id" {
  description = "ID của VPC đã có sẵn."
  type        = string
}

variable "cluster_name" {
  description = "Tên của cụm EKS."
  type        = string
  default     = "my-eks-cluster"
}

variable "cluster_version" {
  description = "Phiên bản Kubernetes cho cụm EKS."
  type        = string
  default     = "1.34"
}
