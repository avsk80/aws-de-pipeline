terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "network" {
  source = "../../modules/network"

  project_name  = var.project_name
  environment   = var.environment
  aws_region    = var.aws_region

  vpc_cidr             = var.vpc_cidr
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones

  create_cloudwatch_logs_endpoint = var.create_cloudwatch_logs_endpoint
}

module "pipeline" {
  source = "../../modules/s3"

  project_name          = var.project_name
  environment           = var.environment
  raw_bucket_name       = var.raw_bucket_name
  processed_bucket_name = var.processed_bucket_name

  lambda_package_path = var.lambda_package_path
  lambda_memory_size  = var.lambda_memory_size
  lambda_timeout      = var.lambda_timeout

  vpc_id             = module.network.vpc_id
  vpc_cidr           = module.network.vpc_cidr
  private_subnet_ids = module.network.private_subnet_ids
}