terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"

  name_prefix         = var.name_prefix
  cidr_block          = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
}

module "ecs" {
  source = "./modules/ecs"

  name_prefix         = var.name_prefix
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.public_subnet_ids
  app_image           = var.app_image
  app_container_port  = var.app_container_port
  app_desired_count   = var.app_desired_count
  mongo_image         = var.mongo_image
  mongo_port          = var.mongo_port
  app_cpu             = var.app_cpu
  app_memory          = var.app_memory
  mongo_cpu           = var.mongo_cpu
  mongo_memory        = var.mongo_memory
  environment         = var.environment
}

output "alb_dns_name" {
  value = module.ecs.alb_dns_name
}

output "app_service_name" {
  value = module.ecs.app_service_name
}

output "mongo_service_name" {
  value = module.ecs.mongo_service_name
}
