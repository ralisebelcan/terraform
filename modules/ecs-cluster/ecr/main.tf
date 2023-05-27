##################################
# ECR Configuration
##################################

locals {
  resource_prefix = "${var.name}-${var.environment_slug}"
}

resource "aws_ecr_repository" "aws-ecr-front" {
  name = "${local.resource_prefix}-front-ecr"
  tags = {
    Name        = "${local.resource_prefix}-front-ecr"
    Environment = var.environment
  }
}

resource "aws_ecr_repository" "aws-ecr-back" {
  name = "${local.resource_prefix}-back-ecr"
  tags = {
    Name        = "${local.resource_prefix}-back-ecr"
    Environment = var.environment
  }
}