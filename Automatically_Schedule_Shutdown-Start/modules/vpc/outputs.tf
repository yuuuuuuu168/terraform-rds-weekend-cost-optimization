# VPC Module - Output Definitions

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "private_subnet_ids" {
  description = "プライベートサブネットIDのリスト"
  value       = aws_subnet.private[*].id
}

output "db_subnet_group_name" {
  description = "DB Subnet Group名"
  value       = aws_db_subnet_group.main.name
}

output "security_group_id" {
  description = "RDS用セキュリティグループID"
  value       = aws_security_group.rds.id
}
