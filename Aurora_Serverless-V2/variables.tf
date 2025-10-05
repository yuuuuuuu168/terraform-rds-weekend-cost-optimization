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
  description = "Auroraへのアクセスを許可するCIDRブロック"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "database_port" {
  description = "データベースポート（MySQL: 3306, PostgreSQL: 5432）"
  type        = number
  default     = 3306
}

# Aurora Serverless V2設定
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
  description = "最小ACU（0に設定することで利用がない時のコストを0にできる）"
  type        = number
  default     = 0
}

variable "max_capacity" {
  description = "最大ACU（4はdb.m5d.large相当）"
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

variable "instance_count" {
  description = "Auroraインスタンス数"
  type        = number
  default     = 1
}
