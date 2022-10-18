module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name             = "${var.stack_name}-vpc"
  azs              = ["${var.aws_region}a", "${var.aws_region}b"]
  cidr             = "10.0.0.0/18"
  public_subnets   = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets  = ["10.0.11.0/24", "10.0.12.0/24"]

  # Single NAT Gateway
  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_support   = true
  enable_dns_hostnames = true

  # manage_default_security_group = true
  # default_security_group_name   = "${var.stack_name}-default-sg"
  # default_security_group_egress = [{
  #   self        = true
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = "-1"
  #   cidr_blocks = "0.0.0.0/0"
  # }]
  # default_security_group_ingress = [{
  #   self        = true
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = "-1"
  #   cidr_blocks = local.vpc_cidr_block
  # }]
}

# data "aws_security_group" "default" {
#   name   = "default"
#   vpc_id = module.main_vpc.vpc_id
# }
