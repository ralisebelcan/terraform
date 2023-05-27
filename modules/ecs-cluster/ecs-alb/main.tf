##################################
# ECS Application Load Balancer
##################################

locals {
  resource_prefix = "${var.name}-${var.environment_slug}"
}

# Create ALB security group
resource "aws_security_group" "alb_sg" {
  vpc_id = var.alb_vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Replace with your desired source IP ranges
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Replace with your desired source IP ranges
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${local.resource_prefix}-alb-sg"
    Environment = var.environment
  }
}

# Create ALB
resource "aws_lb" "alb" {
  name               = "${local.resource_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.alb_subnets_id
  security_groups    = [aws_security_group.alb_sg.id]

  tags = {
    Name        = "${local.resource_prefix}-alb"
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "frontend" {
  name        = "${local.resource_prefix}-frontend-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.alb_vpc_id
  target_type = "ip"
}

resource "aws_lb_target_group" "backend" {
  name        = "${local.resource_prefix}-backend-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.alb_vpc_id
  target_type = "ip"
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.frontend.arn
    type             = "forward"
  }

  # default_action {
  #   type = "redirect"
  #   redirect {
  #     port        = "443"
  #     protocol    = "HTTPS"
  #     status_code = "HTTP_301"
  #   }
}
