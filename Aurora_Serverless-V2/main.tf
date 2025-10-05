# プロバイダー設定
provider "aws" {
  region = var.aws_region
}

# VPCモジュール
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr             = var.vpc_cidr
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  project_name         = var.project_name
  environment          = var.environment
  allowed_cidr_blocks  = var.allowed_cidr_blocks
  database_port        = var.database_port
}

# Auroraモジュール
module "aurora" {
  source = "./modules/aurora"

  cluster_identifier           = var.cluster_identifier
  engine                       = var.engine
  engine_version               = var.engine_version
  database_name                = var.database_name
  master_username              = var.master_username
  master_password              = var.master_password
  min_capacity                 = var.min_capacity
  max_capacity                 = var.max_capacity
  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window
  deletion_protection          = var.deletion_protection
  skip_final_snapshot          = var.skip_final_snapshot
  vpc_security_group_ids       = [module.vpc.security_group_id]
  db_subnet_group_name         = module.vpc.db_subnet_group_name
  environment                  = var.environment
  project_name                 = var.project_name
  instance_count               = var.instance_count

  depends_on = [module.vpc]
}
