terraform {
  backend "s3" {
    bucket = "strapi-tutorial-terraform-backend-sbx"
    key    = "terraform.tfstate"
    region = "eu-west-1"
    profile= "vallai-sbx"
  }

#  required_version = "~> 1.2.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.35.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "vallai-sbx"
}
