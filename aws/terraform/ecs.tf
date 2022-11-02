# elastic container services declaration
resource "aws_ecs_cluster" "starp_tuto" {
  name = "blog-cluster"
}

# creating the security group of ecs

module "ecs_security_group"  {
  source = "terraform-aws-modules/security-group/aws"

  name        = "blog_ecs_sg"
  description = "Security group for strapi_tuto"
  vpc_id      = module.vpc.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      from_port   = 1337
      to_port     = 1337
      protocol    = "tcp"
      source_security_group_id = module.alb_security_group.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1
  egress_rules = ["all-all"]
}