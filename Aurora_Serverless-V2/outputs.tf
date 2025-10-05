# VPC出力値
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "プライベートサブネットIDのリスト"
  value       = module.vpc.private_subnet_ids
}

output "db_subnet_group_name" {
  description = "DB Subnet Group名"
  value       = module.vpc.db_subnet_group_name
}

output "security_group_id" {
  description = "Aurora用セキュリティグループID"
  value       = module.vpc.security_group_id
}

# Aurora出力値
output "cluster_id" {
  description = "AuroraクラスターID"
  value       = module.aurora.cluster_id
}

output "cluster_arn" {
  description = "AuroraクラスターARN"
  value       = module.aurora.cluster_arn
}

output "cluster_endpoint" {
  description = "Auroraクラスターエンドポイント（書き込み）"
  value       = module.aurora.cluster_endpoint
}

output "cluster_reader_endpoint" {
  description = "Auroraクラスターリーダーエンドポイント（読み取り）"
  value       = module.aurora.cluster_reader_endpoint
}

output "cluster_port" {
  description = "Auroraクラスターポート"
  value       = module.aurora.cluster_port
}

output "cluster_database_name" {
  description = "データベース名"
  value       = module.aurora.cluster_database_name
  sensitive   = true
}

output "instance_ids" {
  description = "AuroraインスタンスIDのリスト"
  value       = module.aurora.instance_ids
}

output "instance_endpoints" {
  description = "Auroraインスタンスエンドポイントのリスト"
  value       = module.aurora.instance_endpoints
}
