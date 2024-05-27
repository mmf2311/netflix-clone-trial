locals {
  timestamp = replace(formatdate("YYYYMMDD-HHMMSS", time()), ":", "")
}

resource "aws_vpc" "netflix_clone_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "group-3-vpc-netflix-clone-${var.branch_name}-${local.timestamp}"
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "group-3-ecsTaskExecutionRole-${var.branch_name}-${local.timestamp}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_ecs_cluster" "netflix_clone_cluster" {
  name = "group-3-ecs-cluster-netflix-clone-${var.branch_name}-${local.timestamp}"

  tags = {
    Name = "group-3-ecs-cluster-netflix-clone-${var.branch_name}-${local.timestamp}"
  }
}

resource "aws_ecr_repository" "netflix_clone" {
  name = "group-3-ecr-netflix-clone-${var.branch_name}-${local.timestamp}"

  image_tag_mutability = "MUTABLE"
}

resource "aws_eks_cluster" "eks_cluster" {
  name = "group-3-eks-netflix-clone-${var.branch_name}-${local.timestamp}"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = aws_subnet.subnet[*].id
  }
}

resource "aws_iam_role" "eks_cluster_role" {
  name = "group-3-eks-cluster-role-${var.branch_name}-${local.timestamp}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.netflix_clone_vpc.id
  cidr_block = "10.0.1.0/24"
}
