variable "docker_image_tag" {
  description = "Tag for the Docker images"
  type        = string
}

variable "docker_image_repo_frontend" {
  description = "ECR repository for frontend image"
  type        = string
}

variable "docker_image_repo_backend" {
  description = "ECR repository for backend image"
  type        = string
}
