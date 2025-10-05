# Scheduler Module - Variables

variable "rds_instance_arn" {
  description = "RDSインスタンスのARN"
  type        = string
}

variable "rds_instance_id" {
  description = "RDSインスタンスのID"
  type        = string
}

variable "stop_schedule" {
  description = "停止スケジュール（cron形式、UTC）"
  type        = string
  default     = "cron(0 15 ? * FRI *)" # JST Sat 00:00 (UTC Fri 15:00)
}

variable "start_schedule" {
  description = "起動スケジュール（cron形式、UTC）"
  type        = string
  default     = "cron(0 15 ? * SUN *)" # JST Mon 00:00 (UTC Sun 15:00)
}

variable "timezone" {
  description = "タイムゾーン"
  type        = string
  default     = "Asia/Tokyo"
}

variable "project_name" {
  description = "プロジェクト名"
  type        = string
}

variable "environment" {
  description = "環境名"
  type        = string
}
