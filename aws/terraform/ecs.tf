# elastic container services declaration
resource "aws_ecs_cluster" "starpi_tuto" {
  name = var.stack_name
}

# creating the security group of ecs

module "ecs_security_group" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.stack_name}-ecs-sg"
  description = "Security group for strapi tuto"
  vpc_id      = module.vpc.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      from_port                = var.backend_port
      to_port                  = var.backend_port
      protocol                 = "tcp"
      source_security_group_id = module.alb_security_group.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1
  egress_rules                                             = ["all-all"]
}


resource "aws_ecs_task_definition" "backend" {
  family                   = "backend"
  execution_role_arn       = module.ecs_execution_role.iam_role_arn
  task_role_arn            = module.ecs_task_role.iam_role_arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = jsonencode([
    {
      name = "backend"
      image = aws_ecr_repository.image_repository.repository_url
      portMappings = [
        {
          containerPort = var.backend_port
        }
      ],
      healthCheck = {
        command = ["CMD", "curl", "--fail", "http://localhost:${var.backend_port}/_health"]
        interval = 300
      }
      environment = [
        {
          name = "AWS_REGION"
          value = var.aws_region
        },
        {
          name = "AWS_SDK_LOAD_CONFIG" # load config from ~/.aws
          value = "1"
        },
        {
          name = "DATABASE_HOST"
          value = module.database.db_instance_address
        },
        {
          name = "DATABASE_USERNAME"
          value = module.database.db_instance_username
        },
        {
          name = "DATABASE_PASSWORD"
          value = module.database.db_instance_password
        },
        {
          name = "PROXY"
          value = "true"
        },
        {
          name = "STRAPI_TELEMETRY_DISABLED"
          value = "true"
        },
        {
          name = "URL"
          value = "http://${aws_lb.strapi.dns_name}"
        },
        {
          name = "ADMIN_JWT_SECRET"
          valueFrom = "tobemodified"
        },
        {
          name = "API_TOKEN_SALT"
          valueFrom = "tobemodified"
        },
        {
          name = "APP_KEYS"
          valueFrom = "toBeModified1,toBeModified2"
        },
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-create-group = "true"
          awslogs-group = "/ecs/${var.stack_name}"
          awslogs-region = var.aws_region
          awslogs-stream-prefix = "backend"
        }
      }
    }
  ])

  lifecycle {
    ignore_changes = [container_definitions]
  }
}

resource "aws_ecs_service" "backend" {
  name            = "backend"
  cluster         = aws_ecs_cluster.starpi_tuto.id
  desired_count   = 1
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.backend.arn

  network_configuration {
    security_groups  = [module.ecs_security_group.security_group_id]
    subnets          = module.vpc.private_subnets
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.backend_service.arn
    container_name   = "backend"
    container_port   = var.backend_port
  }
}
