# プロジェクト設定
variable "project_name" {
  description = "プロジェクト名（リソース名のプレフィックス）"
  type        = string
}

variable "environment" {
  description = "環境名"
  type        = string
  default     = "development"
}

variable "aws_region" {
  description = "AWSリージョン"
  type        = string
  default     = "ap-northeast-1"
}

# VPC設定
variable "vpc_cidr" {
  description = "VPCのCIDRブロック"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_cidrs" {
  description = "プライベートサブネットのCIDRブロックリスト"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "availability_zones" {
  description = "使用するアベイラビリティゾーン"
  type        = list(string)
  default     = ["ap-northeast-1a", "ap-northeast-1c"]
}

variable "allowed_cidr_blocks" {
  description = "RDSへのアクセスを許可するCIDRブロック"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

# RDS設定
variable "rds_identifier" {
  description = "RDSインスタンスの識別子"
  type        = string
}

variable "rds_engine" {
  description = "データベースエンジン（mysql, postgres）"
  type        = string
  default     = "mysql"
}

variable "rds_engine_version" {
  description = "エンジンバージョン"
  type        = string
  default     = "8.0.35"
}

variable "rds_instance_class" {
  description = "インスタンスクラス"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "割り当てストレージ（GB）"
  type        = number
  default     = 20
}

variable "rds_storage_type" {
  description = "ストレージタイプ"
  type        = string
  default     = "gp3"
}

variable "rds_db_name" {
  description = "初期データベース名"
  type        = string
}

variable "rds_username" {
  description = "マスターユーザー名"
  type        = string
  sensitive   = true
}

variable "rds_password" {
  description = "マスターパスワード"
  type        = string
  sensitive   = true
}

variable "rds_backup_retention_period" {
  description = "バックアップ保持期間（日）"
  type        = number
  default     = 1
}

variable "rds_backup_window" {
  description = "バックアップウィンドウ（UTC）"
  type        = string
  default     = "17:00-18:00"
}

variable "rds_maintenance_window" {
  description = "メンテナンスウィンドウ（UTC）"
  type        = string
  default     = "sun:18:00-sun:19:00"
}

variable "rds_multi_az" {
  description = "マルチAZ構成の有効化"
  type        = bool
  default     = false
}

variable "rds_publicly_accessible" {
  description = "パブリックアクセスの有効化"
  type        = bool
  default     = false
}

variable "rds_deletion_protection" {
  description = "削除保護の有効化"
  type        = bool
  default     = false
}

variable "rds_skip_final_snapshot" {
  description = "最終スナップショットのスキップ"
  type        = bool
  default     = true
}

# スケジュール設定
variable "stop_schedule" {
  description = "停止スケジュール（cron形式、UTC）"
  type        = string
  default     = "cron(0 15 ? * FRI *)"
}

variable "start_schedule" {
  description = "起動スケジュール（cron形式、UTC）"
  type        = string
  default     = "cron(0 15 ? * SUN *)"
}

variable "timezone" {
  description = "タイムゾーン"
  type        = string
  default     = "Asia/Tokyo"
}
