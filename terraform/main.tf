resource "aws_vpc" "netflix_clone_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "group-3-vpc-netflix-clone-${var.branch_name}-${local.timestamp}"
  }
}

resource "aws_subnet" "netflix_clone_subnet" {
  vpc_id     = aws_vpc.netflix_clone_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "group-3-subnet-netflix-clone-${var.branch_name}-${local.timestamp}"
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "group-3-ecsTaskExecutionRole-${var.branch_name}-${local.timestamp}"
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

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_task_execution_role.name
}

resource "aws_ecs_cluster" "netflix_clone_cluster" {
  name = "group-3-ecs-cluster-netflix-clone-${var.branch_name}-${local.timestamp}"
}

resource "aws_ecs_task_definition" "netflix_clone_task" {
  family                   = "group-3-ecs-task-netflix-clone-${var.branch_name}-${local.timestamp}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions    = jsonencode([
    {
      name = "netflix-clone"
      image = "${aws_ecr_repository.netflix_clone.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ]
      environment = [
        {
          name  = "TMDB_API_KEY"
          value = var.tmdb_api_key
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "netflix_clone_service" {
  name            = "group-3-ecs-service-netflix-clone-${var.branch_name}-${local.timestamp}"
  cluster         = aws_ecs_cluster.netflix_clone_cluster.id
  task_definition = aws_ecs_task_definition.netflix_clone_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = [aws_subnet.netflix_clone_subnet.id]
    assign_public_ip = true
  }
}

resource "aws_ecr_repository" "netflix_clone" {
  name = "group-3-ecr-netflix-clone-${var.branch_name}-${local.timestamp}"
}

