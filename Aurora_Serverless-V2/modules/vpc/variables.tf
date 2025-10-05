# VPC Module - Variables

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

variable "project_name" {
  description = "プロジェクト名（リソース名のプレフィックス）"
  type        = string
}

variable "environment" {
  description = "環境名"
  type        = string
  default     = "development"
}

variable "allowed_cidr_blocks" {
  description = "Auroraへのアクセスを許可するCIDRブロック"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "database_port" {
  description = "データベースポート"
  type        = number
  default     = 3306
}
