##################################
####### General variables ########
##################################

variable "env" {
  description = "Global environment name"
  default     = "staging"
}

variable "name" {
  description = "Global project name"
  default     = "PROJECT"
}

############################
####### Networking #########
############################

variable "networking_name" {
  description = "Name prefix for all named resources"
  type        = string
  default     = "PROJECT"
}

variable "networking_region" {
  description = "Target AWS Region"
  type        = string
  default     = "eu-north-1"
}

variable "networking_environment_slug" {
  description = "Deployment environment slug"
  type        = string
  default     = "staging"
}

variable "networking_vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "networking_public_subnets_cidr" {
  description = "CIDR block of the public subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "networking_private_subnets_cidr" {
  description = "CIDR block of the private subnets"
  type        = list(string)
  default     = ["10.0.50.0/24", "10.0.60.0/24"]
}

#####################
####### ECS #########
#####################

variable "ecs_name" {
  description = "Name prefix for all named resources"
  type        = string
  default     = "PROJECT"
}

variable "capacity_providers" {
  description = "Capacity provider for ECS"
  type        = set(string)
  default     = ["FARGATE"]
}

variable "task_definition_network_mode_front" {
  description = "ECS network mode for frontend"
  type        = string
  default     = "awsvpc"
}

variable "task_definition_network_mode_backend" {
  description = "ECS network mode for backend"
  type        = string
  default     = "awsvpc"
}

variable "s3_env_file" {
  description = "ECS network mode for backend"
  type        = string
  default     = "s3://test/test.env"
}
