output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_id" {
  description = "ID of the private subnets"
  value       = aws_subnet.private.id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.main.id
}