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
    protocol            = "HTTP" #tfsec:ignore:AWS004 - uses plain HTTP instead of HTTPS
    matcher             = "200,204"
    timeout             = "30"
    path                = "/_health"
    unhealthy_threshold = "2"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "strapi" {
  load_balancer_arn = aws_lb.strapi.arn
  port              = var.public_port
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_service.arn
    # type = "fixed-response"
    # fixed_response {
    #   content_type = "text/plain"
    #   message_body = "Welcome Strapi"
    #   status_code  = "200"
    # }
  }
}

# resource "aws_lb_listener" "strapi_https" {
#   load_balancer_arn = aws_lb.strapi.arn
#   port              = 443
#   protocol          = "HTTPS"
#   certificate_arn   = aws_acm_certificate.alb.arn

#   default_action {
#     type = "fixed-response"

#     fixed_response {
#       content_type = "text/plain"
#       message_body = "Not Found"
#       status_code  = "404"
#     }
#   }
# }

# resource "aws_lb_listener_rule" "strapi_https" {
#   listener_arn = aws_lb_listener.strapi_https.arn

#   condition {
#     host_header {
#       values = [aws_lb.strapi.dns_name]
#     }
#   }

#   action {
#     # type             = "forward"
#     # target_group_arn = aws_lb_target_group.vapi_ecs_service[each.key].arn
#     type = "fixed-response"

#     fixed_response {
#       content_type = "text/plain"
#       message_body = "Not Found"
#       status_code  = "404"
#     }
#   }
# }

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
  ]

  egress_rules = ["all-all"]
}