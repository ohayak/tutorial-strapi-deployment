module "rds_security_group" {
  source  = "terraform-aws-modules/security-group/aws"

  name        = "${var.stack_name}-rds-sg"
  description = "Security group for strapi application"
  vpc_id      = module.vpc.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      # Traffic to the DB should only come from ECS
      rule = "postgresql-tcp"
      source_security_group_id = module.ecs_security_group.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  ingress_with_cidr_blocks = [
    {
      rule = "postgresql-tcp"
      cidr_blocks = "0.0.0.0/0" #tfsec:ignore:AWS008
    }
  ]

  egress_rules = [ "all-all" ]
}

module "public_rds_security_group" {
  source  = "terraform-aws-modules/security-group/aws"

  name        = "${var.stack_name}-public-rds-sg"
  description = "Security group for strapi tuto Public RDS"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      rule = "postgresql-tcp"
      cidr_blocks = "0.0.0.0/0" #tfsec:ignore:AWS008
    }
  ]
}


module "database" {
  source = "terraform-aws-modules/rds/aws"

  identifier     = "blog-rds"
  engine         = "postgres"
  family         = "postgres13"
  engine_version = "13.7"
  major_engine_version = "13"
  instance_class       = "db.t3.small"

  allocated_storage     = 20
  max_allocated_storage = 100

  db_subnet_group_name   = module.vpc.database_subnet_group_name

  multi_az               = false
  create_db_subnet_group = false

  vpc_security_group_ids = [
    module.rds_security_group.security_group_id,
    module.public_rds_security_group.security_group_id
  ]

  publicly_accessible    = true

  iam_database_authentication_enabled = false
  db_name                      = var.stack_name
  username                     = var.stack_name
  password                     = var.stack_name
  create_random_password = false
  parameter_group_name = aws_db_parameter_group.pg_transport.id
  create_db_parameter_group = false
  parameter_group_use_name_prefix = false
  storage_encrypted   = true
  apply_immediately   = true

  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "03:00-06:00"
  backup_retention_period = 7
  skip_final_snapshot     = true
  # enable_http_endpoint = true

  # enabled_cloudwatch_logs_exports = ["postgresql"]
  # scaling_configuration = {
  #   auto_pause               = true
  #   min_capacity             = 2
  #   max_capacity             = 16
  #   seconds_until_auto_pause = 300
  #   timeout_action           = "ForceApplyCapacityChange"
  # }
}