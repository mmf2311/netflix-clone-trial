output "ecr_repository_url" {
  value = data.aws_ecr_repository.existing.repository_url
}
