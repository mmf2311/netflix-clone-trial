provider "aws" {
  region = var.aws_region
}

# New VPC Resource
resource "aws_vpc" "netflix_clone_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "group-3-vpc-netflix-clone"
  }
}

# New Subnet Resource
resource "aws_subnet" "netflix_clone_subnet" {
  vpc_id                  = aws_vpc.netflix_clone_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "group-3-subnet-netflix-clone"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "netflix_clone_igw" {
  vpc_id = aws_vpc.netflix_clone_vpc.id
  tags = {
    Name = "group-3-igw-netflix-clone"
  }
}

# Route Table
resource "aws_route_table" "netflix_clone_route_table" {
  vpc_id = aws_vpc.netflix_clone_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.netflix_clone_igw.id
  }

  tags = {
    Name = "group-3-rt-netflix-clone"
  }
}

# Route Table Association
resource "aws_route_table_association" "netflix_clone_route_table_association" {
  subnet_id      = aws_subnet.netflix_clone_subnet.id
  route_table_id = aws_route_table.netflix_clone_route_table.id
}

# Check for existing IAM Role
data "aws_iam_role" "existing_ecs_task_execution_role" {
  name = "group-3-ecsTaskExecutionRole"
}

# IAM Role and Policy for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution_role" {
  count = length(data.aws_iam_role.existing_ecs_task_execution_role.arn) == 0 ? 1 : 0

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
  depends_on = [aws_iam_role.ecs_task_execution_role]

  name       = "ecs-task-execution-policy-attachment"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  roles      = length(aws_iam_role.ecs_task_execution_role) > 0 ? [aws_iam_role.ecs_task_execution_role[0].name] : [data.aws_iam_role.existing_ecs_task_execution_role.name]
}

# Check for existing ECR repository
data "aws_ecr_repository" "existing_netflix_clone" {
  name = "group-3-ecr-netflix-clone"
}

resource "aws_ecr_repository" "netflix_clone" {
  count = length(data.aws_ecr_repository.existing_netflix_clone.repository_url) == 0 ? 1 : 0

  name                 = "group-3-ecr-netflix-clone"
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
  execution_role_arn       = length(aws_iam_role.ecs_task_execution_role) > 0 ? aws_iam_role.ecs_task_execution_role[0].arn : data.aws_iam_role.existing_ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name  = "netflix-clone"
    image = length(aws_ecr_repository.netflix_clone) > 0 ? "${aws_ecr_repository.netflix_clone[0].repository_url}:latest" : "${data.aws_ecr_repository.existing_netflix_clone.repository_url}:latest"
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

# Check for existing ECS Service
data "aws_ecs_service" "existing_service" {
  cluster_arn  = aws_ecs_cluster.netflix_clone_cluster.arn
  service_name = "group-3-ecs-service-netflix-clone"
}

resource "aws_ecs_service" "netflix_clone_service" {
  count = length(data.aws_ecs_service.existing_service.arn) == 0 ? 1 : 0
  name             = "group-3-ecs-service-netflix-clone"
  cluster          = aws_ecs_cluster.netflix_clone_cluster.id
  task_definition  = aws_ecs_task_definition.netflix_clone_task.arn
  desired_count    = 1
  launch_type      = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.netflix_clone_subnet.id]
    assign_public_ip = true
  }

  lifecycle {
    ignore_changes = [
      task_definition,
      desired_count,
    ]
  }

  depends_on = [aws_ecs_task_definition.netflix_clone_task]
}

# API Gateway
resource "aws_api_gateway_rest_api" "netflix_clone_api" {
  name = "netflix-clone-api"
}

resource "aws_api_gateway_resource" "netflix_clone_resource" {
  rest_api_id = aws_api_gateway_rest_api.netflix_clone_api.id
  parent_id   = aws_api_gateway_rest_api.netflix_clone_api.root_resource_id
  path_part   = "movies"
}

resource "aws_api_gateway_method" "netflix_clone_method" {
  rest_api_id   = aws_api_gateway_rest_api.netflix_clone_api.id
  resource_id   = aws_api_gateway_resource.netflix_clone_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "netflix_clone_integration" {
  rest_api_id = aws_api_gateway_rest_api.netflix_clone_api.id
  resource_id = aws_api_gateway_resource.netflix_clone_resource.id
  http_method = aws_api_gateway_method.netflix_clone_method.http_method
  type        = "HTTP_PROXY"
  uri         = "http://example.com/movies"  # Replace with actual backend URI
}

resource "aws_api_gateway_deployment" "netflix_clone_deployment" {
  depends_on  = [aws_api_gateway_integration.netflix_clone_integration]
  rest_api_id = aws_api_gateway_rest_api.netflix_clone_api.id
  stage_name  = "prod"
}
