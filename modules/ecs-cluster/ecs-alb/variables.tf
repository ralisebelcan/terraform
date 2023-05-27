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
