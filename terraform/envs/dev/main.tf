terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # backend "s3" {
  #   # This will be configured via CLI for security
  #   # bucket         = "your-tfstate-bucket"
  #   # key            = "symbiosis/dev/terraform.tfstate"
  #   # region         = "ap-southeast-1"
  #   # dynamodb_table = "your-tfstate-lock-table"
  # }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source       = "../../modules/vpc"
  project_name = var.project_name
  common_tags  = var.common_tags
}

module "alb" {
  source            = "../../modules/alb"
  project_name      = var.project_name
  common_tags       = var.common_tags
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
}

module "rds" {
  source          = "../../modules/rds"
  project_name    = var.project_name
  common_tags     = var.common_tags
  vpc_id          = module.vpc.vpc_id
  db_subnet_ids   = module.vpc.private_db_subnet_ids
}

module "ec2_asg" {
  source                 = "../../modules/ec2_asg"
  project_name           = var.project_name
  common_tags            = var.common_tags
  vpc_id                 = module.vpc.vpc_id
  private_app_subnet_ids = module.vpc.private_app_subnet_ids
  alb_security_group_id  = module.alb.alb_security_group_id
  target_group_arn       = module.alb.target_group_arn
  db_secret_arn          = module.rds.db_secret_arn
}

resource "aws_security_group_rule" "app_to_db" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = module.ec2_asg.app_security_group_id
  security_group_id        = module.rds.db_security_group_id
} 