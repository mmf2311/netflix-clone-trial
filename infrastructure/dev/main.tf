provider "aws" {
  region = "us-east-1"
}

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

resource "aws_s3_bucket" "frontend" {
  bucket = "group-3-s3-netflix-clone-frontend-dev"
  acl    = "public-read"

  website {
    index_document = "index.html"
  }
}

resource "aws_s3_bucket_object" "frontend_files" {
  for_each = fileset("${path.module}/../../frontend/build", "**")
  bucket   = aws_s3_bucket.frontend.bucket
  key      = each.key
  source   = "${path.module}/../../frontend/build/${each.key}"
  acl      = "public-read"
}

resource "aws_ecs_cluster" "netflix_clone_dev" {
  name = "group-3-ecs-netflix-clone-dev"
}

resource "aws_ecs_task_definition" "frontend" {
  family                = "group-3-task-def-netflix-clone-frontend-dev"
  network_mode          = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                   = 256
  memory                = 512
  execution_role_arn    = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([{
    name      = "frontend"
    image     = "${var.docker_image_repo_frontend}:${var.docker_image_tag}"
    portMappings = [{
      containerPort = 80
      hostPort      = 80
    }]
  }])
}

resource "aws_ecs_task_definition" "backend" {
  family                = "group-3-task-def-netflix-clone-backend-dev"
  network_mode          = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                   = 256
  memory                = 512
  execution_role_arn    = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([{
    name      = "backend"
    image     = "${var.docker_image_repo_backend}:${var.docker_image_tag}"
    portMappings = [{
      containerPort = 4000
      hostPort      = 4000
    }]
  }])
}

resource "aws_ecs_service" "frontend" {
  name            = "group-3-ecs-service-netflix-clone-frontend-dev"
  cluster         = aws_ecs_cluster.netflix_clone_dev.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.main.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}

resource "aws_ecs_service" "backend" {
  name            = "group-3-ecs-service-netflix-clone-backend-dev"
  cluster         = aws_ecs_cluster.netflix_clone_dev.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.main.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}

resource "aws_security_group" "ecs_sg" {
  name_prefix = "group-3-sg-ecs-"
  description = "ECS Security Group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4000
    to_port     = 4000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
}
