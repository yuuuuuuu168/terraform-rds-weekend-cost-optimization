# Aurora Module Outputs

output "cluster_id" {
  description = "AuroraクラスターID"
  value       = aws_rds_cluster.main.id
}

output "cluster_arn" {
  description = "AuroraクラスターARN"
  value       = aws_rds_cluster.main.arn
}

output "cluster_endpoint" {
  description = "Auroraクラスターエンドポイント（書き込み）"
  value       = aws_rds_cluster.main.endpoint
}

output "cluster_reader_endpoint" {
  description = "Auroraクラスターリーダーエンドポイント（読み取り）"
  value       = aws_rds_cluster.main.reader_endpoint
}

output "cluster_port" {
  description = "Auroraクラスターポート"
  value       = aws_rds_cluster.main.port
}

output "cluster_database_name" {
  description = "データベース名"
  value       = aws_rds_cluster.main.database_name
}

output "instance_ids" {
  description = "AuroraインスタンスIDのリスト"
  value       = aws_rds_cluster_instance.main[*].id
}

output "instance_endpoints" {
  description = "Auroraインスタンスエンドポイントのリスト"
  value       = aws_rds_cluster_instance.main[*].endpoint
}
