########### Networking ################

module "networking" {
  source               = "../modules/networking"
  name                 = var.networking_name
  region               = var.networking_region
  environment          = var.env
  environment_slug     = var.env
  vpc_cidr             = var.networking_vpc_cidr
  public_subnets_cidr  = var.networking_public_subnets_cidr
  private_subnets_cidr = var.networking_private_subnets_cidr
  availability_zones   = ["${var.networking_region}a", "${var.networking_region}c"]
}

########### AWS ECR ################

module "ecr" {
  source                                  = "../modules/ecs-cluster/ecr"
  name                                    = var.name
  environment                             = var.env
  environment_slug                        = var.env
}

########### AWS ECS Role ################

module "ecs-role" {
  source                                  = "../modules/iam/ecs-role"
  name                                    = var.name
  environment                             = var.env
  environment_slug                        = var.env
}

########### AWS ECS ALB ################

module "ecs-alb" {
  source                                  = "../modules/ecs-cluster/ecs-alb"
  name                                    = var.name
  environment                             = var.env
  environment_slug                        = var.env
  alb_vpc_id                              = module.networking.vpc_id
  alb_subnets_id                          = module.networking.public_subnets_id
}

########### AWS ECS Cluster ################

module "ecs" {
  source                                  = "../modules/ecs-cluster/ecs"
  name                                    = var.ecs_name
  environment                             = var.env
  environment_slug                        = var.env
  alb_vpc_id                              = module.networking.vpc_id
  alb_subnets_id                          = module.networking.public_subnets_id
  capacity_providers                      = var.capacity_providers 
  task_definition_network_mode_front      = var.task_definition_network_mode_front
  task_definition_network_mode_backend    = var.task_definition_network_mode_backend
  ecr_repo_front                          = module.ecr.registry_url_front
  ecr_repo_back                           = module.ecr.registry_url_back
  execution_role                          = module.ecs-role.ecs_role
  s3_env_file                             = var.s3_env_file
  frontend_cpu                            = 256
  frontend_memory                         = 512
  backend_cpu                             = 256
  backend_memory                          = 512
  frontend_service_subnets                = module.networking.private_subnets_id
  backend_service_subnets                 = module.networking.private_subnets_id
  backend_target_group                    = module.ecs-alb.alb_back_tg
  frontend_target_group                   = module.ecs-alb.alb_front_tg
}
