variable "role_name" {
  description = "Tên của IAM Role cho EKS Cluster"
  type        = string
}

variable "tags" {
  description = "Các tag cho role"
  type        = map(string)
  default     = {}
}
