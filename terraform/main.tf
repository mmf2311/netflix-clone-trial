data "aws_iam_policy_document" "eks_cluster_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_vpc" "netflix_clone_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "ce5-group-3-vpc-${var.branch_name}-netflixclone"
  }
}

resource "aws_subnet" "netflix_clone_subnet_1" {
  vpc_id            = aws_vpc.netflix_clone_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "ce5-group-3-subnet1-${var.branch_name}-netflixclone"
  }
}

resource "aws_subnet" "netflix_clone_subnet_2" {
  vpc_id            = aws_vpc.netflix_clone_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "ce5-group-3-subnet2-${var.branch_name}-netflixclone"
  }
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = "ce5-group-3-ekscluster-${var.branch_name}-netflixclone"
  role_arn = aws_iam_role.eks_cluster_role.arn
  vpc_config {
    subnet_ids = [
      aws_subnet.netflix_clone_subnet_1.id,
      aws_subnet.netflix_clone_subnet_2.id
    ]
  }
}

resource "aws_iam_role" "eks_cluster_role" {
  name = "ce5-group-3-eks-cluster-role-${var.branch_name}-netflixclone"
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

resource "aws_ecr_repository" "netflix_clone" {
  name = "ce5-group-3-ecrrepository-${var.branch_name}-netflixclone"
}

resource "aws_ecs_cluster" "netflix_clone_cluster" {
  name = "ce5-group-3-ecs-cluster-${var.branch_name}-netflixclone"
}

resource "aws_ecs_task_definition" "netflix_clone_task" {
  family                   = "ce5-group-3-ecs-task-${var.branch_name}-netflixclone"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions    = jsonencode([
    {
      name      = "netflix-clone"
      image     = "${aws_ecr_repository.netflix_clone.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ]
    }
  ])
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ce5-group-3-ecs-task-execution-role-${var.branch_name}-netflixclone"
  assume_role_policy = jsonencode({
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
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

resource "aws_ecs_service" "netflix_clone_service" {
  name            = "ce5-group-3-ecs-service-${var.branch_name}-netflixclone"
  cluster         = aws_ecs_cluster.netflix_clone_cluster.id
  task_definition = aws_ecs_task_definition.netflix_clone_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets = [
      aws_subnet.netflix_clone_subnet_1.id,
      aws_subnet.netflix_clone_subnet_2.id
    ]
    assign_public_ip = true
  }
}
