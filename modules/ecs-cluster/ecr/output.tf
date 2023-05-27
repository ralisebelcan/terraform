output "registry_url_front" {
  value = aws_ecr_repository.aws-ecr-front.repository_url
}

output "registry_arn_front" {
  value = aws_ecr_repository.aws-ecr-front.arn
}

output "registry_url_back" {
  value = aws_ecr_repository.aws-ecr-back.repository_url
}

output "registry_arn_back" {
  value = aws_ecr_repository.aws-ecr-back.arn
}