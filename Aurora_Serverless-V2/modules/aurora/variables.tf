# Aurora Module Variables

variable "cluster_identifier" {
  description = "Auroraクラスターの識別子"
  type        = string
}

variable "engine" {
  description = "データベースエンジン（aurora-mysql, aurora-postgresql）"
  type        = string
  default     = "aurora-mysql"
}

variable "engine_version" {
  description = "エンジンバージョン"
  type        = string
  default     = "8.0.mysql_aurora.3.04.0"
}

variable "database_name" {
  description = "初期データベース名"
  type        = string
}

variable "master_username" {
  description = "マスターユーザー名"
  type        = string
  sensitive   = true
}

variable "master_password" {
  description = "マスターパスワード"
  type        = string
  sensitive   = true
}

variable "min_capacity" {
  description = "最小ACU"
  type        = number
  default     = 0
}

variable "max_capacity" {
  description = "最大ACU"
  type        = number
  default     = 4
}

variable "backup_retention_period" {
  description = "バックアップ保持期間（日）"
  type        = number
  default     = 1
}

variable "preferred_backup_window" {
  description = "バックアップウィンドウ（UTC）"
  type        = string
  default     = "17:00-18:00"
}

variable "preferred_maintenance_window" {
  description = "メンテナンスウィンドウ（UTC）"
  type        = string
  default     = "sun:18:00-sun:19:00"
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

variable "instance_count" {
  description = "Auroraインスタンス数"
  type        = number
  default     = 1
}
