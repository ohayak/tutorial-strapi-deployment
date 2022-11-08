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
    },
    {
      from_port                = var.frontend_port
      to_port                  = var.frontend_port
      protocol                 = "tcp"
      source_security_group_id = module.alb_security_group.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 2
  egress_rules                                             = ["all-all"]
}


resource "aws_ecs_task_definition" "strapi" {

  family                   = "strapi"
  execution_role_arn       = module.ecs_execution_role.iam_role_arn
  task_role_arn            = module.ecs_task_role.iam_role_arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = jsonencode([
    {
      name = "frontend"
      image = "${aws_ecr_repository.image_repository.repository_url}:frontend"
      portMappings = [
        {
          containerPort = var.frontend_port
        }
      ],
      healthCheck = {
        command = ["CMD", "curl", "--fail", "http://localhost:${var.frontend_port}"]
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
          name = "NEXT_PUBLIC_STRAPI_API_URL"
          value = "http://${aws_lb.strapi.dns_name}:1337"
        }

      ]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-create-group = "true"
          awslogs-group = "/ecs/${var.stack_name}"
          awslogs-region = var.aws_region
          awslogs-stream-prefix = "frontend"
        }
      }
    },
    {
      name = "backend"
      image = "${aws_ecr_repository.image_repository.repository_url}:backend"
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
          name = "DATABASE_NAME"
          value = module.database.db_instance_name
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
          value = "http://${aws_lb.strapi.dns_name}:${var.backend_port}"
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
  task_definition = aws_ecs_task_definition.strapi.arn

  network_configuration {
    security_groups  = [module.ecs_security_group.security_group_id]
    subnets          = module.vpc.private_subnets
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.backend.arn
    container_name   = "backend"
    container_port   = var.backend_port
  }
#  service_registries {
#    registry_arn = aws_service_discovery_service.strapi_service.arn
#  }

}

resource "aws_ecs_service" "frontend" {
  name            = "frontend"
  cluster         = aws_ecs_cluster.starpi_tuto.id
  desired_count   = 1
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.strapi.arn

  network_configuration {
    security_groups  = [module.ecs_security_group.security_group_id]
    subnets          = module.vpc.private_subnets
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = "frontend"
    container_port   = var.frontend_port
  }
#  service_registries {
#    registry_arn = aws_service_discovery_service.strapi_service.arn
#  }
}
#
#resource "aws_service_discovery_private_dns_namespace" "segement" {
#  name = "network"
#  description = "domaine for intern services"
#  vpc  = module.vpc.name
#}
#
#resource "aws_service_discovery_service" "strapi_service" {
#  name = "starpi_service"
#  dns_config {
#    namespace_id = aws_service_discovery_private_dns_namespace.segement.id
#    routing_policy = "MULTIVALUE"
#    dns_records {
#      ttl  = 10
#      type = "A"
#    }
#  }
#  health_check_config {
#    failure_threshold = 5
#  }
#}