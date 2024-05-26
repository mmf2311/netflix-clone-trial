provider "aws" {
  region = var.aws_region
}

data "aws_ecr_repository" "existing" {
  name = "group-3-ecr-netflix-clone"
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "group-3-ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "ecs_task_execution_policy" {
  name       = "ecs-task-execution-policy-attachment"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  roles      = [aws_iam_role.ecs_task_execution_role.name]
}

resource "aws_ecr_repository" "netflix_clone" {
  count = length(data.aws_ecr_repository.existing.id) == 0 ? 1 : 0

  name = "group-3-ecr-netflix-clone"
  image_tag_mutability = "MUTABLE"
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
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name  = "netflix-clone"
    image = "${data.aws_ecr_repository.existing.repository_url}:latest"
    essential = true

    portMappings = [{
      containerPort = 5000
      hostPort      = 5000
    }]

    environment = [{
      name  = "TMDB_API_KEY"
      value = var.tmdb_api_key
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
    subnets         = [
      "subnet-VALID_SUBNET_ID_1",
      "subnet-VALID_SUBNET_ID_2"
    ]
    assign_public_ip = true
  }
}

output "ecr_repository_url" {
  value = data.aws_ecr_repository.existing.repository_url
}
