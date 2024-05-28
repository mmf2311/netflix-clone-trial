### Project Structure

```
netflix-clone/
├── .github/
│   └── workflows/
│       ├── ci-cd.yml
│       └── destroy.yml
├── backend/
│   ├── Dockerfile
│   ├── requirements.txt
│   └── src/
│       └── main.py
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── provider.tf
├── kubernetes/
│   ├── deployment.yml
│   └── service.yml
└── README.md
```

### .github/workflows/ci-cd.yml

```yaml
name: CI/CD Pipeline

on:
  push:
    branches:
      - main
      - dev
      - stage
      - prod
  pull_request:
    branches:
      - main
      - dev
      - stage
      - prod
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v1

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ secrets.AWS_REGION }}

      - name: Log in to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v1

      - name: Build, tag, and push Docker image to Amazon ECR
        id: build-image
        uses: docker/build-push-action@v2
        with:
          context: ./backend
          file: ./backend/Dockerfile
          push: true
          tags: ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/group-3-ecr-netflix-clone:latest

      - name: Terraform Init and Apply
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          AWS_REGION: ${{ secrets.AWS_REGION }}
          TF_VAR_tmdb_api_key: ${{ secrets.TMDB_API_KEY }}
        run: |
          cd terraform
          terraform init
          terraform apply -auto-approve

      - name: Deploy to Kubernetes
        env:
          KUBECONFIG: ${{ secrets.KUBECONFIG }}
        run: |
          kubectl apply -f kubernetes/deployment.yml
          kubectl apply -f kubernetes/service.yml
```

### .github/workflows/destroy.yml

```yaml
name: Destroy Infrastructure

on:
  workflow_dispatch:

jobs:
  destroy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ secrets.AWS_REGION }}

      - name: Install Terraform
        run: |
          sudo apt-get update && sudo apt-get install -y unzip
          curl -LO https://releases.hashicorp.com/terraform/1.0.11/terraform_1.0.11_linux_amd64.zip
          unzip terraform_1.0.11_linux_amd64.zip
          sudo mv terraform /usr/local/bin/
          terraform -install-autocomplete

      - name: Initialize Terraform
        run: terraform init
        working-directory: terraform

      - name: Plan Terraform Destroy
        run: terraform plan -destroy -out=tfplan
        working-directory: terraform

      - name: Apply Terraform Destroy
        run: terraform apply -auto-approve tfplan
        working-directory: terraform

      - name: Delete ECR repository
        run: |
          aws ecr delete-repository --repository-name group-3-ecr-netflix-clone --force || true
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          AWS_REGION: ${{ secrets.AWS_REGION }}

      - name: Delete IAM Role
        run: |
          aws iam delete-role-policy --role-name group-3-ecsTaskExecutionRole --policy-name ecs-task-execution-policy || true
          aws iam delete-role --role-name group-3-ecsTaskExecutionRole || true
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          AWS_REGION: ${{ secrets.AWS_REGION }}

      - name: Delete ECS Cluster
        run: |
          aws ecs delete-cluster --cluster group-3-ecs-cluster-netflix-clone || true
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          AWS_REGION: ${{ secrets.AWS_REGION }}

      - name: Delete VPC and related resources
        run: |
          vpc_id=$(aws ec2 describe-vpcs --filters Name=tag:Name,Values=group-3-vpc-netflix-clone --query "Vpcs[0].VpcId" --output text)
          if [ "$vpc_id" != "None" ]; then
            aws ec2 delete-subnet --subnet-id $(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$vpc_id" --query "Subnets[0].SubnetId" --output text)
            aws ec2 delete-route-table --route-table-id $(aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$vpc_id" --query "RouteTables[0].RouteTableId" --output text)
            aws ec2 delete-internet-gateway --internet-gateway-id $(aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$vpc_id" --query "InternetGateways[0].InternetGatewayId" --output text)
            aws ec2 delete-vpc --vpc-id $vpc_id
          fi
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          AWS_REGION: ${{ secrets.AWS_REGION }}
```

### backend/Dockerfile

```Dockerfile
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

COPY src/ /app

CMD ["python", "main.py"]
```

### backend/requirements.txt

```text
Flask==2.0.1
requests==2.25.1
```

### backend/src/main.py

```python
from flask import Flask, jsonify
import requests
import os

app = Flask(__name__)

TMDB_API_KEY = os.getenv("TMDB_API_KEY")

@app.route('/movies', methods=['GET'])
def get_movies():
    response = requests.get(f'https://api.themoviedb.org/3/movie/popular?api_key={TMDB_API_KEY}')
    return jsonify(response.json())

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

### terraform/main.tf

```hcl
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
data "aws_iam_role"

 "existing_ecs_task_execution_role" {
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

output "ecr_repository_url" {
  value = length(aws_ecr_repository.netflix_clone) > 0 ? aws_ecr_repository.netflix_clone[0].repository_url : data.aws_ecr_repository.existing_netflix_clone.repository_url
}

output "api_gateway_url" {
  value = aws_api_gateway_deployment.netflix_clone_deployment.invoke_url
}
```

### terraform/variables.tf

```hcl
variable "aws_region" {
  description = "The AWS region to deploy to"
}

variable "tmdb_api_key" {
  description = "Your TMDB API key"
}
```

### terraform/outputs.tf

```hcl
output "ecr_repository_url" {
  value = length(aws_ecr_repository.netflix_clone) > 0 ? aws_ecr_repository.netflix_clone[0].repository_url : data.aws_ecr_repository.existing_netflix_clone.repository_url
}

output "api_gateway_url" {
  value = aws_api_gateway_deployment.netflix_clone_deployment.invoke_url
}
```

### terraform/provider.tf

```hcl
provider "aws" {
  region = var.aws_region
}
```

### kubernetes/deployment.yml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: netflix-clone
  labels:
    app: netflix-clone
spec:
  replicas: 1
  selector:
    matchLabels:
      app: netflix-clone
  template:
    metadata:
      labels:
        app: netflix-clone
    spec:
      containers:
        - name: netflix-clone
          image: <YOUR_AWS_ACCOUNT_ID>.dkr.ecr.<YOUR_AWS_REGION>.amazonaws.com/group-3-ecr-netflix-clone:latest
          ports:
            - containerPort: 5000
          resources:
            limits:
              memory: "512Mi"
              cpu: "500m"
          env:
            - name: TMDB_API_KEY
              valueFrom:
                secretKeyRef:
                  name: tmdb-api-key-secret
                  key: TMDB_API_KEY
      restartPolicy: Always
```

### kubernetes/service.yml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: netflix-clone
spec:
  selector:
    app: netflix-clone
  ports:
    - protocol: TCP
      port: 80
      targetPort: 5000
  type: LoadBalancer
```

### README.md

```markdown
# Netflix Clone Application

## Project Overview

This project is a Netflix clone application that demonstrates a cloud-native application using a modern CI/CD pipeline. It utilizes various AWS services, Docker, Kubernetes, and other technologies to automate the deployment process.

## Team Members

1. Mohammad Nor Shukri
2. Muhammad Tarmizi
3. Hnin Wut Yee
4. Mohamed Malik
5. Mohammad Sufiyan

## Project Structure

```
netflix-clone/
├── .github/
│   └── workflows/
│       ├── ci-cd.yml
│       └── destroy.yml
├── backend/
│   ├── Dockerfile
│   ├── requirements.txt
│   └── src/
│       └── main.py
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── provider.tf
├── kubernetes/
│   ├── deployment.yml
│   └── service.yml
└── README.md
```

## Technologies Used

- **AWS**: ECR, ECS, IAM, VPC, Subnet, Internet Gateway, Route Table, API Gateway, Lambda, SNS, SQS, EC2
- **Docker**: Containerization of the backend application
- **Kubernetes**: Deployment and Service configuration
- **Terraform**: Infrastructure as Code (IaC) for AWS resources
- **GitHub Actions**: CI/CD pipeline automation
- **Flask**: Backend framework for the application
- **TMDB API**: External API for movie data

## Detailed Network Architecture Diagram

```plaintext
                            +---------------------------+
                            |        Users              |
                            +------------+--------------+
                                        

 |
                                         v
                            +------------+--------------+
                            |     AWS API Gateway       |
                            +------------+--------------+
                                         |
                                         v
+-------------------------+  +-----------+-------------+  +-------------------------+
|  Public Subnet          |  |  Private Subnet         |  |  Public Subnet          |
|                         |  |                         |  |                         |
|  +-------------------+  |  |  +-------------------+  |  |  +-------------------+  |
|  |                   |  |  |  |                   |  |  |  |                   |  |
|  |    EC2 Instance   +--+<->+--+  Lambda Function +--+<->+--+    EC2 Instance   |  |
|  |                   |  |  |  |                   |  |  |  |                   |  |
|  +--------+----------+  |  |  +--------+----------+  |  |  +--------+----------+  |
|           |             |  |           |             |  |           |             |
|           v             |  |           v             |  |           v             |
|  +--------+----------+  |  |  +--------+----------+  |  |  +--------+----------+  |
|  |  Docker Container |  |  |  |  Docker Container |  |  |  |  Docker Container |  |
|  |     (Backend)     +--+<->+--+     (Backend)     +--+<->+--+     (Backend)     |  |
|  +-------------------+  |  |  +-------------------+  |  |  +-------------------+  |
+-------------------------+  +-------------------------+  +-------------------------+
                            |       VPC (Virtual Private Cloud)                     |
                            +-------------------------------------------------------+
```

## Detailed Reasoning of Tools Used

- **AWS ECR (Elastic Container Registry)**: For storing Docker images.
- **AWS ECS (Elastic Container Service)**: For running the Docker containers.
- **AWS IAM (Identity and Access Management)**: For managing permissions.
- **AWS VPC (Virtual Private Cloud)**: For creating a secure network environment.
- **AWS Subnet**: For logically segmenting the VPC.
- **AWS Internet Gateway**: For allowing access to the internet.
- **AWS Route Table**: For managing routing within the VPC.
- **AWS API Gateway**: For exposing APIs to the internet.
- **AWS Lambda**: For serverless functions.
- **AWS SNS (Simple Notification Service)**: For sending notifications.
- **AWS SQS (Simple Queue Service)**: For message queuing.
- **AWS EC2 (Elastic Compute Cloud)**: For running virtual servers.
- **Docker**: For containerizing the application.
- **Kubernetes**: For orchestrating the Docker containers.
- **Terraform**: For managing infrastructure as code.
- **GitHub Actions**: For automating the CI/CD pipeline.
- **Flask**: For the backend web framework.
- **TMDB API**: For fetching movie data.

## Versioning and Detailed Explanation to Start with Base Features of the Application

1. **Version 1.0.0**: Initial release with the following features:
   - Basic movie browsing functionality using the TMDB API.
   - Backend containerized with Docker.
   - Deployment pipeline set up with GitHub Actions.
   - Infrastructure managed with Terraform.
   - Application deployed on AWS using ECS and Kubernetes.

## Future Enhancements

1. **User Authentication**: Implement user authentication using AWS Cognito.
2. **Movie Reviews**: Allow users to add reviews to movies.
3. **User Profiles**: Implement user profile management.
4. **Notifications**: Use SNS to send notifications for new movie releases.
5. **Messaging Queue**: Use SQS for handling asynchronous tasks.

## Full Code and Documentation in README.md

The complete code and documentation are included in the repository structure provided above. Each component is explained in detail, and the CI/CD workflows are fully automated to ensure a seamless deployment process.

## GitHub Actions Workflow

The provided GitHub Actions workflows are designed to automate the CI/CD process, including the destroy workflow to clean up all resources created in AWS. This ensures that the entire lifecycle of the application, from development to deployment and eventual teardown, is managed efficiently and securely.

testtesttesttesttesttesttesttest

