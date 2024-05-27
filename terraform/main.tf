locals {
  timestamp = replace(formatdate("YYYYMMDD-HHMMSS", timestamp()), ":", "")
}

resource "aws_vpc" "netflix_clone_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "group-3-vpc-netflix-clone-${var.branch_name}-${local.timestamp}"
  }
}

resource "aws_subnet" "netflix_clone_subnet" {
  vpc_id     = aws_vpc.netflix_clone_vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "group-3-subnet-netflix-clone-${var.branch_name}-${local.timestamp}"
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "group-3-ecsTaskExecutionRole-${var.branch_name}-${local.timestamp}"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_task_execution_role.name
}

resource "aws_ecs_cluster" "netflix_clone_cluster" {
  name = "group-3-ecs-cluster-netflix-clone-${var.branch_name}-${local.timestamp}"
}

resource "aws_ecr_repository" "netflix_clone" {
  name = "group-3-ecr-netflix-clone-${var.branch_name}-${local.timestamp}"
}

resource "aws_ecs_task_definition" "netflix_clone_task" {
  family                   = "group-3-ecs-task-netflix-clone-${var.branch_name}-${local.timestamp}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions    = jsonencode([{
    name  = "netflix-clone"
    image = "${aws_ecr_repository.netflix_clone.repository_url}:latest"
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

data "aws_iam_policy_document" "eks_cluster_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_eks_cluster" "eks_cluster" {
  name = "group-3-eks-netflix-clone-${var.branch_name}-${local.timestamp}"
  role_arn = aws_iam_role.eks_cluster_role.arn
  vpc_config {
    subnet_ids = [aws_subnet.netflix_clone_subnet.id, aws_subnet.netflix_clone_subnet.id]
  }
}

resource "aws_iam_role" "eks_cluster_role" {
  name = "group-3-eks-cluster-role-${var.branch_name}-${local.timestamp}"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster_role.name
}
