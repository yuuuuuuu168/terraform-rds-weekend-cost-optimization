# RDS Module Outputs

output "db_instance_id" {
  description = "RDSインスタンスID"
  value       = aws_db_instance.main.id
}

output "db_instance_arn" {
  description = "RDSインスタンスARN"
  value       = aws_db_instance.main.arn
}

output "db_instance_endpoint" {
  description = "RDSインスタンスエンドポイント"
  value       = aws_db_instance.main.endpoint
  sensitive   = true
}

output "db_instance_address" {
  description = "RDSインスタンスアドレス"
  value       = aws_db_instance.main.address
}

output "db_instance_port" {
  description = "RDSインスタンスポート"
  value       = aws_db_instance.main.port
}
