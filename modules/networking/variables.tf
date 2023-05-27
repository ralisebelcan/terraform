variable "name" {
  description = "Name prefix for all named resources"
}

variable "region" {
  description = "Target AWS Region"
}

variable "availability_zones" {
  type        = list(string)
  description = "AZ that will be hosting resources"
}

variable "environment" {
  description = "Deployment environment"
}

variable "environment_slug" {
  description = "Deployment environment slug"
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
}

variable "public_subnets_cidr" {
  type        = list(string)
  description = "CIDR blocks of the private subnets for each individual AZ"
}

variable "private_subnets_cidr" {
  type        = list(string)
  description = "CIDR blocks of the private subnets for each individual AZ"
}
