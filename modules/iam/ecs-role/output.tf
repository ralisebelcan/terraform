output "ecs_role" {
  value = aws_iam_role.ecsTaskExecutionRole.arn
}