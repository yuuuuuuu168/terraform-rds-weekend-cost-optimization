# Scheduler Module - Main Configuration
# EventBridge Scheduler for RDS automatic stop/start

# IAM Role for EventBridge Scheduler
resource "aws_iam_role" "scheduler" {
  name = "${var.project_name}-${var.environment}-scheduler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-scheduler-role"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    CostCenter  = var.environment
  }
}

# IAM Policy for RDS stop/start operations
resource "aws_iam_role_policy" "scheduler_rds_policy" {
  name = "${var.project_name}-${var.environment}-scheduler-rds-policy"
  role = aws_iam_role.scheduler.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds:StopDBInstance",
          "rds:StartDBInstance",
          "rds:DescribeDBInstances"
        ]
        Resource = var.rds_instance_arn
      }
    ]
  })
}

# EventBridge Scheduler - Stop RDS (Saturday 00:00 JST)
resource "aws_scheduler_schedule" "stop_rds" {
  name       = "${var.project_name}-${var.environment}-stop-rds"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression          = var.stop_schedule
  schedule_expression_timezone = var.timezone

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:rds:stopDBInstance"
    role_arn = aws_iam_role.scheduler.arn

    input = jsonencode({
      DbInstanceIdentifier = var.rds_instance_id
    })

    retry_policy {
      maximum_retry_attempts = 2
    }
  }

  description = "Stop RDS instance on Saturday 00:00 JST"
}

# EventBridge Scheduler - Start RDS (Monday 00:00 JST)
resource "aws_scheduler_schedule" "start_rds" {
  name       = "${var.project_name}-${var.environment}-start-rds"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression          = var.start_schedule
  schedule_expression_timezone = var.timezone

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:rds:startDBInstance"
    role_arn = aws_iam_role.scheduler.arn

    input = jsonencode({
      DbInstanceIdentifier = var.rds_instance_id
    })

    retry_policy {
      maximum_retry_attempts = 2
    }
  }

  description = "Start RDS instance on Monday 00:00 JST"
}
