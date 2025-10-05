# VPC出力
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
  description = "RDS用セキュリティグループID"
  value       = module.vpc.security_group_id
}

# RDS出力
output "db_instance_id" {
  description = "RDSインスタンスID"
  value       = module.rds.db_instance_id
}

output "db_instance_arn" {
  description = "RDSインスタンスARN"
  value       = module.rds.db_instance_arn
}

output "db_instance_endpoint" {
  description = "RDSインスタンスエンドポイント"
  value       = module.rds.db_instance_endpoint
  sensitive   = true
}

output "db_instance_address" {
  description = "RDSインスタンスアドレス"
  value       = module.rds.db_instance_address
  sensitive   = true
}

output "db_instance_port" {
  description = "RDSインスタンスポート"
  value       = module.rds.db_instance_port
}

# Scheduler出力
output "stop_schedule_arn" {
  description = "停止スケジュールのARN"
  value       = module.scheduler.stop_schedule_arn
}

output "start_schedule_arn" {
  description = "起動スケジュールのARN"
  value       = module.scheduler.start_schedule_arn
}

output "scheduler_role_arn" {
  description = "Scheduler実行ロールのARN"
  value       = module.scheduler.scheduler_role_arn
}
