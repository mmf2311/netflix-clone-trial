provider "aws" {
  region = var.aws_region
}

resource "aws_ecr_repository" "netflix_clone" {
  name = "group-3-ecr-netflix-clone"
}

resource "aws_ecs_cluster" "netflix_clone_cluster" {
  name = "group-3-ecs-cluster-netflix-clone"
}

resource "aws_ecs_task_definition" "netflix_clone_task" {
  family                   = "group-3-ecs-task-netflix-clone"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([{
    name  = "netflix-clone"
    image = "${aws_ecr_repository.netflix_clone.repository_url}:latest"
    essential = true

    portMappings = [{
      containerPort = 5000
      hostPort      = 5000
    }]
  }])
}

resource "aws_ecs_service" "netflix_clone_service" {
  name            = "group-3-ecs-service-netflix-clone"
  cluster         = aws_ecs_cluster.netflix_clone_cluster.id
  task_definition = aws_ecs_task_definition.netflix_clone_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = ["subnet-0123456789abcdef0"]
    assign_public_ip = true
  }
}
