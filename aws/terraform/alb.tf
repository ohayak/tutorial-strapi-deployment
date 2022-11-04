resource "aws_lb" "strapi" {
  name            = "${var.stack_name}-alb"
  subnets         = module.vpc.public_subnets
  security_groups = [module.alb_security_group.security_group_id]
}

resource "aws_lb_target_group" "backend_service" {
  name        = var.stack_name
  port        = var.backend_port
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "300"
    protocol            = "HTTP"
    matcher             = "200,204"
    timeout             = "30"
    path                = "/_health"
    unhealthy_threshold = "2"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "frontend_service" {
  name        = "frontend"
  port        = var.frontend_port
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "300"
    protocol            = "HTTP" #tfsec:ignore:AWS004 - uses plain HTTP instead of HTTPS
    matcher             = "200,204"
    timeout             = "30"
    path                = "/"
    unhealthy_threshold = "2"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "backend" {
  load_balancer_arn = aws_lb.strapi.arn
  port              = var.backend_port
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_service.arn
  }
}
resource "aws_lb_listener" "frontend" {
  load_balancer_arn = aws_lb.strapi.arn
  port              = var.frontend_port
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_service.arn
  }
}


module "alb_security_group" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.stack_name}-alb-sg"
  description = "Security group for Strapi ALB"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      rule        = "http-80-tcp"
      cidr_blocks = "0.0.0.0/0" #tfsec:ignore:AWS008
    },
    {
      rule        = "https-443-tcp"
      cidr_blocks = "0.0.0.0/0" #tfsec:ignore:AWS008
    },
    {
      from_port                = var.frontend_port
      to_port                  = var.frontend_port
      protocol                 = "tcp"
      cidr_blocks = "0.0.0.0/0" #tfsec:ignore:AWS008
    },
    {
      from_port                = var.backend_port
      to_port                  = var.backend_port
      protocol                 = "tcp"
      cidr_blocks = "0.0.0.0/0" #tfsec:ignore:AWS008
    }
  ]

  egress_rules = ["all-all"]
}