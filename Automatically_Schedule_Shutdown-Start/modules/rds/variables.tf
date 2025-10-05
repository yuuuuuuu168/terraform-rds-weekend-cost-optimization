# RDS Module Variables

variable "identifier" {
  description = "RDSインスタンスの識別子"
  type        = string
}

variable "engine" {
  description = "データベースエンジン（mysql, postgres）"
  type        = string
  default     = "mysql"
}

variable "engine_version" {
  description = "エンジンバージョン"
  type        = string
  default     = "8.0"
}

variable "instance_class" {
  description = "インスタンスクラス"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "割り当てストレージ（GB）"
  type        = number
  default     = 20
}

variable "storage_type" {
  description = "ストレージタイプ"
  type        = string
  default     = "gp3"
}

variable "db_name" {
  description = "初期データベース名"
  type        = string
}

variable "username" {
  description = "マスターユーザー名"
  type        = string
  sensitive   = true
}

variable "password" {
  description = "マスターパスワード"
  type        = string
  sensitive   = true
}

variable "backup_retention_period" {
  description = "バックアップ保持期間（日）"
  type        = number
  default     = 1
}

variable "backup_window" {
  description = "バックアップウィンドウ（UTC）"
  type        = string
  default     = "17:00-18:00"
}

variable "maintenance_window" {
  description = "メンテナンスウィンドウ（UTC）"
  type        = string
  default     = "sun:18:00-sun:19:00"
}

variable "multi_az" {
  description = "マルチAZ構成の有効化"
  type        = bool
  default     = false
}

variable "publicly_accessible" {
  description = "パブリックアクセスの有効化"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "削除保護の有効化"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "最終スナップショットのスキップ"
  type        = bool
  default     = true
}

variable "vpc_security_group_ids" {
  description = "セキュリティグループIDのリスト"
  type        = list(string)
}

variable "db_subnet_group_name" {
  description = "DB Subnet Group名"
  type        = string
}

variable "environment" {
  description = "環境名"
  type        = string
}

variable "project_name" {
  description = "プロジェクト名"
  type        = string
}

