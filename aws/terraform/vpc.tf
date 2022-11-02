module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name             = "strapi-tuto-vpc"
  cidr             = "10.0.0.0/16"
  azs              = ["eu-west-1a", "eu-west-1b"]
  private_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets   = ["10.0.101.0/24", "10.0.102.0/24"]
  database_subnets = ["10.0.201.0/24", "10.0.202.0/24"]

  # one NAT gateway per subnet & single NAT for all of them
  enable_nat_gateway = true
  single_nat_gateway = true

  # enable DNS support and hostnames in the VPC
  enable_dns_support   = true
  enable_dns_hostnames = true
}