locals {
  aws_region = "eu-west-1"
  stack_name = replace(path_relative_to_include(), "/", "-")
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    encrypt = true
    bucket  = "terraform-tuto-backend-mp"
    key     = "${local.stack_name}.tfstate"
    region  = local.aws_region
  }
}

generate "provider" {
  path = "versions.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.17"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
  }
}

provider "cloudflare" {}

provider "aws" {
  region = "${local.aws_region}"
  default_tags {
    tags = {
      managed-by = "terraform"
      stack    = "${local.stack_name}"
    }
  }
}
EOF
}

inputs = {
  aws_region = local.aws_region
  stack_name = local.stack_name
}
