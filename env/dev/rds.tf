provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}


################################################################################
# Random Pass + Secret Manager
################################################################################
resource "random_password" "master"{
  length           = 10
  special          = true
  override_special = "_!%^"
}

resource "aws_secretsmanager_secret" "password" {
  name                    = "${var.application_name}-${var.secret_intent}-sm-${var.environment}"
  description             = "RDS Admin password"
}

resource "aws_secretsmanager_secret_version" "password" {
  secret_id = aws_secretsmanager_secret.password.id
  secret_string = random_password.master.result
}


#-------------->
# data block for secret manager
#-------------->
data "aws_secretsmanager_secret" "password" {
  name = aws_secretsmanager_secret.password.name
}
data "aws_secretsmanager_secret_version" "password" {
  secret_id = data.aws_secretsmanager_secret.password.id
}

################################################################################
# RDS Module
################################################################################


module "db" {
  
  source = "../../modules/rds"

  identifier = "${var.application_name}-rds-${var.environment}"

  engine               = "mysql"
  engine_version       = "8.0"
  family               = "mysql8.0" 
  major_engine_version = "8.0"      
  instance_class       = "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = 100

  db_name  = "sample_db"
  username = "admin"
  password = data.aws_secretsmanager_secret_version.password.secret_string
  port     = 3306
  manage_master_user_password = false
  publicly_accessible = true

  # multi_az               = false
  # db_subnet_group_name   = module.vpc.database_subnet_group
  # vpc_security_group_ids = [module.security_group.security_group_id]

  # maintenance_window              = "Mon:00:00-Mon:03:00"
  # backup_window                   = "03:00-06:00"
  # enabled_cloudwatch_logs_exports = ["general"]
  # create_cloudwatch_log_group     = true

  # skip_final_snapshot = true
  # deletion_protection = false

  # performance_insights_enabled          = true
  # performance_insights_retention_period = 7
  # create_monitoring_role                = true
  # monitoring_interval                   = 60

  tags = var.tags
}

# module "db_disabled" {
#   source = ""

#   identifier = "${local.name}-disabled"

#   create_db_instance        = false
#   create_db_parameter_group = false
#   create_db_option_group    = false
# }

# ################################################################################
# # Supporting Resources
# ################################################################################


# module "security_group" {
#   source  = "terraform-aws-modules/security-group/aws"
#   version = "~> 5.0"

#   name        = local.name
#   description = "Complete MySQL example security group"
#   vpc_id      = module.vpc.vpc_id

#   # ingress
#   ingress_with_cidr_blocks = [
#     {
#       from_port   = 3306
#       to_port     = 3306
#       protocol    = "tcp"
#       description = "MySQL access from within VPC"
#       cidr_blocks = module.vpc.vpc_cidr_block
#     },
#   ]

#   tags = local.tags
# }
