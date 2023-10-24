output "vpc_id" {
  value       = aws_vpc.this.id
  description = "The VPC ID"
}

output "vpc_cidr" {
  value       = var.vpc_cidr
  description = "The VPC CIDR Block"
}

output "public_subnets_ids" {
  value       = values(aws_subnet.public)[*].id
  description = "The Public Subnets ID"
}

output "private_subnets_ids" {
  value       = values(aws_subnet.private)[*].id
  description = "The Private Subnets ID"
}
