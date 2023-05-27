##################################
# ECS Configuration
##################################

locals {
  resource_prefix = "${var.name}-${var.environment_slug}"
}

##################################
# ECS Cluster
##################################

resource "aws_ecs_cluster" "aws-ecs-cluster" {
  name = "${local.resource_prefix}-cluster"
  capacity_providers = var.capacity_providers
  tags = {
    Name        = "${local.resource_prefix}-ecs"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "log-group" {
  name = "${var.name}-${var.environment_slug}-logs"

  tags = {
    Name        = "${local.resource_prefix}-logs"
    Environment = var.environment
  }
}

##################################
# ECS Task Definitions
##################################

resource "aws_ecs_task_definition" "frontend_task_definition" {
  family                   = "frontend"
  execution_role_arn       = var.execution_role
  task_role_arn            = var.execution_role
  network_mode             = var.task_definition_network_mode_front
  requires_compatibilities = var.capacity_providers
  cpu       = var.frontend_cpu
  memory    = var.frontend_memory

  container_definitions = jsonencode([
      {
        "name": "frontend-service",
        "image": "${var.ecr_repo_front}:latest",
        "portMappings": [
          {
            "containerPort": 80,
            "hostPort": 80,
            "protocol": "tcp"
          }
        ],
        "environmentFiles": [
          {
            "value": "${var.s3_env_file}",
            "type": "s3"
          }
        ]
      }
    ])

  tags = {
    Name        = "${local.resource_prefix}-ecs-frontend-td"
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = all
  }

}

resource "aws_ecs_task_definition" "backend_task_definition" {
  family                   = "backend"
  execution_role_arn       = var.execution_role
  task_role_arn            = var.execution_role
  network_mode             = var.task_definition_network_mode_front
  requires_compatibilities = var.capacity_providers
  cpu       = var.backend_cpu
  memory    = var.backend_memory

  container_definitions = jsonencode([
      {
        "name": "backend-service",
        "image": "${var.ecr_repo_back}:latest",
        "portMappings": [
          {
            "containerPort": 80,
            "hostPort": 80,
            "protocol": "tcp"
          }
        ],
        "environmentFiles": [
          {
            "value": "${var.s3_env_file}",
            "type": "s3"
          }
        ]
      }
    ])
  
  tags = {
    Name        = "${local.resource_prefix}-ecs-backend-td"
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = all
  }
}

##################################
# ECS Services
##################################

resource "aws_security_group" "service_security_group" {
  vpc_id = var.alb_vpc_id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${local.resource_prefix}-ecs-service-sg"
    Environment = var.environment
  }
}

resource "aws_ecs_service" "frontend-service" {
  name                 = "${local.resource_prefix}-frontend"
  cluster              = aws_ecs_cluster.aws-ecs-cluster.name
  task_definition      = "${aws_ecs_task_definition.frontend_task_definition.family}"
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = 1
  force_new_deployment = true

  network_configuration {
    subnets          = var.frontend_service_subnets
    assign_public_ip = false
    security_groups = [
      aws_security_group.service_security_group.id,
      aws_security_group.alb_sg.id
    ]
  }

  load_balancer {
    target_group_arn = var.frontend_target_group
    container_name   = "frontend-service"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.listener]
}

resource "aws_ecs_service" "backend-service" {
  name                 = "${local.resource_prefix}-backend"
  cluster              = aws_ecs_cluster.aws-ecs-cluster.name
  task_definition      = "${aws_ecs_task_definition.backend_task_definition.family}"
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = 1
  force_new_deployment = true

  network_configuration {
    subnets          = var.backend_service_subnets
    assign_public_ip = false
    security_groups = [
      aws_security_group.service_security_group.id,
      aws_security_group.alb_sg.id
    ]
  }

  load_balancer {
    target_group_arn = var.backend_target_group
    container_name   = "backend-service"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.listener]
}

