provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr             = var.vpc_cidr
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  project_name         = var.project_name
  environment          = var.environment
  allowed_cidr_blocks  = var.allowed_cidr_blocks
}

module "rds" {
  source = "./modules/rds"

  identifier              = var.rds_identifier
  engine                  = var.rds_engine
  engine_version          = var.rds_engine_version
  instance_class          = var.rds_instance_class
  allocated_storage       = var.rds_allocated_storage
  storage_type            = var.rds_storage_type
  db_name                 = var.rds_db_name
  username                = var.rds_username
  password                = var.rds_password
  backup_retention_period = var.rds_backup_retention_period
  backup_window           = var.rds_backup_window
  maintenance_window      = var.rds_maintenance_window
  multi_az                = var.rds_multi_az
  publicly_accessible     = var.rds_publicly_accessible
  deletion_protection     = var.rds_deletion_protection
  skip_final_snapshot     = var.rds_skip_final_snapshot
  vpc_security_group_ids  = [module.vpc.security_group_id]
  db_subnet_group_name    = module.vpc.db_subnet_group_name
  environment             = var.environment
  project_name            = var.project_name

  depends_on = [module.vpc]
}

module "scheduler" {
  source = "./modules/scheduler"

  rds_instance_arn = module.rds.db_instance_arn
  rds_instance_id  = module.rds.db_instance_id
  stop_schedule    = var.stop_schedule
  start_schedule   = var.start_schedule
  timezone         = var.timezone
  project_name     = var.project_name
  environment      = var.environment

  depends_on = [module.rds]
}
