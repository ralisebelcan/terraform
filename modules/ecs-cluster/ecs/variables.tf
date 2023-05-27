variable "name" {
  type = string
  description = "Name prefix for all named resources"
}

variable "environment" {
  type = string
  description = "Deployment environment"
}


variable "environment_slug" {
  type = string
  description = "Deployment environment slug"
}

variable "alb_vpc_id" {
  type = string
  description = "VPC for ALB security group"
}

variable "alb_subnets_id" {
  type = set(string)
  description = "Subnets for ALB"
}

variable "capacity_providers" {
  type = set(string)
  description = "Capacity providers to use in ECS cluster"
}

variable "task_definition_network_mode_front" {
  type = string
  description = "Network mode for frontend task definition"
}

variable "task_definition_network_mode_backend" {
  type = string
  description = "Network mode for backend task definition"
}

variable "frontend_cpu" {
  type = number
  description = "Frontend CPU"
}

variable "frontend_memory" {
  type = number
  description = "Frontend memory"
}

variable "backend_cpu" {
  type = number
  description = "Backend CPU"
}

variable "backend_memory" {
  type = number
  description = "Backend memory"
}

variable "ecr_repo_front" {
  type = string
  description = "Set ECR front registry url"
}

variable "ecr_repo_back" {
  type = string
  description = "Set ECR back registry url"
}

variable "s3_env_file" {
  type = string
  description = "Put path to s3 env file"
}

variable "execution_role" {
  type = string
  description = "Set execution role for ECS service"
}

variable "frontend_service_subnets" {
  type = set(string)
  description = "Frontend ECS service subnets"
}

variable "backend_service_subnets" {
  type = set(string)
  description = "Frontend ECS service subnets"
}

variable "backend_target_group" {
  type = string
  description = "ECS ALB target group for backend"
}

variable "frontend_target_group" {
  type = string
  description = "ECS ALB target group for frontend"
}


