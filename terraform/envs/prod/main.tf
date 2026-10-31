# 1. VPC & Networking Module
module "vpc" {
  source      = "../../modules/vpc"
  aws_region  = var.aws_region
  environment = var.environment
}


module "iam" {
  source      = "../../modules/iam"
  vpc_id      = module.vpc.vpc_id
  environment = var.environment
}


module "rds" {
  source                = "../../modules/rds"
  environment           = var.environment
  private_subnet_ids    = module.vpc.private_subnet_ids
  rds_security_group_id = module.iam.rds_security_group_id
}

module "alb" {
  source                = "../../modules/alb"
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  alb_security_group_id = module.iam.alb_security_group_id
}

module "ecs" {
  source                   = "../../modules/ecs"
  aws_region               = var.aws_region
  environment              = var.environment
  private_subnet_ids       = module.vpc.private_subnet_ids
  ecs_security_group_id    = module.iam.ecs_security_group_id
  ec2_instance_profile_arn = module.iam.ec2_instance_profile_arn
  ecs_execution_role_arn    = module.iam.ecs_execution_role_arn
  target_group_arn         = module.alb.target_group_arn
  db_endpoint              = module.rds.db_endpoint
  secret_arn               = module.rds.secret_arn
  instance_type            = var.ec2_instance_type
}