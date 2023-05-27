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