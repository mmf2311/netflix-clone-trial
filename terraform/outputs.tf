output "ecr_repository_url" {
  value = aws_ecr_repository.netflix_clone[0].repository_url
}
