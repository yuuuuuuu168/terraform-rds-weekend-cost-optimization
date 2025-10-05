# Scheduler Module - Outputs

output "stop_schedule_arn" {
  description = "停止スケジュールのARN"
  value       = aws_scheduler_schedule.stop_rds.arn
}

output "start_schedule_arn" {
  description = "起動スケジュールのARN"
  value       = aws_scheduler_schedule.start_rds.arn
}

output "scheduler_role_arn" {
  description = "Scheduler実行ロールのARN"
  value       = aws_iam_role.scheduler.arn
}
