output "vpc_id" {
  description = "ID của VPC"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "ID của các public subnets"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "ID của các private subnets"
  value       = module.vpc.private_subnets
}
