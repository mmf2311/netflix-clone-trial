Sure, here's the complete set of updated files, the repository structure, and the README.md file for your record:

### Updated Repository Structure

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
│       ├── main.py
│       └── utils.py
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
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
      - dev
      - main
      - feature/*
  pull_request:
    branches:
      - dev

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v2

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v1

    - name: Configure AWS Credentials
      uses: aws-actions/configure-aws-credentials@v1
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ secrets.AWS_REGION }}

    - name: Log in to Amazon ECR
      run: |
        aws ecr get-login-password --region ${{ secrets.AWS_REGION }} | docker login --username AWS --password-stdin ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com

    - name: Create ECR repository if it does not exist
      run: |
        aws ecr describe-repositories --repository-names group-3-ecr-netflix-clone --region ${{ secrets.AWS_REGION }} || aws ecr create-repository --repository-name group-3-ecr-netflix-clone --region ${{ secrets.AWS_REGION }}

    - name: List backend directory contents
      run: ls -R backend

    - name: Build Docker image
      run: |
        docker build -t netflix-clone:latest -f backend/Dockerfile backend

    - name: Tag Docker image
      run: |
        docker tag netflix-clone:latest ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/group-3-ecr-netflix-clone:latest

    - name: Push Docker image to ECR
      run: |
        docker push ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/group-3-ecr-netflix-clone:latest

    - name: Terraform Init and Apply
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        AWS_REGION: ${{ secrets.AWS_REGION }}
        TF_VAR_tmdb_api_key: ${{ secrets.TMDB_API_KEY }}
        TF_VAR_aws_region: ${{ secrets.AWS_REGION }}
      run: |
        cd terraform
        terraform init
        terraform apply -auto-approve

    - name: Set up Kubernetes
      uses: azure/setup-kubectl@v1
      with:
        version: 'latest'

    - name: Configure Kubernetes context
      env:
        KUBECONFIG: ${{ secrets.KUBECONFIG }}
      run: |
        echo "${{ secrets.KUBECONFIG }}" | base64 --decode > $HOME/.kube/config

    - name: Deploy to Kubernetes
      env:
        AWS_REGION: ${{ secrets.AWS_REGION }}
        AWS_ACCOUNT_ID: ${{ secrets.AWS_ACCOUNT_ID }}
        TMDB_API_KEY: ${{ secrets.TMDB_API_KEY }}
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

    - name: Configure AWS Credentials
      uses: aws-actions/configure-aws-credentials@v1
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ secrets.AWS_REGION }}

    - name: Terraform Init
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        AWS_REGION: ${{ secrets.AWS_REGION }}
        TF_VAR_tmdb_api_key: ${{ secrets.TMDB_API_KEY }}
        TF_VAR_aws_region: ${{ secrets.AWS_REGION }}
      run: |
        cd terraform
        terraform init

    - name: Terraform Destroy
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        AWS_REGION: ${{ secrets.AWS_REGION }}
        TF_VAR_tmdb_api_key: ${{ secrets.TMDB_API_KEY }}
        TF_VAR_aws_region: ${{ secrets.AWS_REGION }}
      run: |
        cd terraform
        terraform destroy -auto-approve

    - name: Delete ECR repository
      run: |
        aws ecr describe-repositories --repository-names group-3-ecr-netflix-clone --region ${{ secrets.AWS_REGION }} && \
        aws ecr delete-repository --repository-name group-3-ecr-netflix-clone --region ${{ secrets.AWS_REGION }} --force || \
        echo "Repository group-3-ecr-netflix-clone does not exist or already deleted"

    - name: Delete IAM Role
      run: |
        aws iam delete-role-policy --role-name group-3-ecsTaskExecutionRole --policy-name ecs-task-execution-policy-attachment || true
        aws iam delete-role --role-name group-3-ecsTaskExecutionRole || true
```

### backend/Dockerfile

```dockerfile
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

COPY src/ /app

CMD ["python", "main.py"]
```

### backend/requirements.txt

```
Flask==2.0.3
requests==2.26.0
```

### backend/src/main.py

```python
from flask import Flask, jsonify, request
from utils import get_movie_data

app = Flask(__name__)

@app.route('/movie/<title>', methods=['GET'])
def movie(title):
    data = get_movie_data(title)
    return jsonify(data)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

### backend/src/utils.py

```python
import os
import requests

def get_movie_data(title):
    api_key = os.getenv('TMDB_API_KEY')
    url = f'https://api.themoviedb.org/3/search/movie?api_key={api_key}&query={title}'
    response = requests.get(url)
    return response.json()
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
data "aws_iam_role" "existing_ecs_task_execution_role" {
  name = "group-3-ecsTaskExecutionRole"
}

# IAM Role and Policy for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution_role

" {
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
  cluster = aws_ecs_cluster.netflix_clone_cluster.id
  name    = "group-3-ecs-service-netflix-clone"
}

resource "aws_ecs_service" "netflix_clone_service" {
  count            = length(data.aws_ecs_service.existing_service.id) == 0 ? 1 : 0
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
}

output "ecr_repository_url" {
  value = length(aws_ecr_repository.netflix_clone) > 0 ? aws_ecr_repository.netflix_clone[0].repository_url : data.aws_ecr_repository.existing_netflix_clone.repository_url
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
        env:
        - name: TMDB_API_KEY
          valueFrom:
            secretKeyRef:
              name: tmdb-api-key-secret
              key: TMDB_API_KEY
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
      restartPolicy: Always
---
apiVersion: v1
kind: Secret
metadata:
  name: tmdb-api-key-secret
type: Opaque
stringData:
  TMDB_API_KEY: "<YOUR_TMDB_API_KEY>"
```

### kubernetes/service.yml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: netflix-clone-service
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
│       ├── main.py
│       └── utils.py
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── kubernetes/
│   ├── deployment.yml
│   └── service.yml
└── README.md
```

## Technologies Used

- **AWS**: ECR, ECS, IAM, VPC, Subnet, Internet Gateway, Route Table
- **Docker**: Containerization of the backend application
- **Kubernetes**: Deployment and Service configuration
- **Terraform**: Infrastructure as Code (IaC) for AWS resources
- **GitHub Actions**: CI/CD pipeline automation
- **Flask**: Backend framework for the application
- **TMDB API**: External API for movie data

## Network Architecture

```plaintext
AWS VPC: group-3-vpc-netflix-clone
    ├── Subnet: group-3-subnet-netflix-clone
    ├── Internet Gateway: group-3-igw-netflix-clone
    ├── Route Table: group-3-rt-netflix-clone
    │   └── Route Table Association: group-3-rt-association-netflix-clone
    └── ECS Cluster: group-3-ecs-cluster-netflix-clone
        ├── ECS Task Definition: group-3-ecs-task-netflix-clone
        └── ECS Service: group-3-ecs-service-netflix-clone
            └── Docker Image: group-3-ecr-netflix-clone
```

## CI/CD Pipeline

The CI/CD pipeline is configured using GitHub Actions with the following steps:

1. **Checkout Code**: Checkout the latest code from the repository.
2. **Set up Docker Buildx**: Set up Docker Buildx for multi-platform builds.
3. **Configure AWS Credentials**: Configure AWS credentials using GitHub Secrets.
4. **Log in to Amazon ECR**: Authenticate Docker to the Amazon ECR registry.
5. **Create ECR Repository**: Create the ECR repository if it doesn't exist.
6. **Build Docker Image**: Build the Docker image for the backend application.
7. **Tag Docker Image**: Tag the Docker image with the latest tag.
8. **Push Docker Image to ECR**: Push the Docker image to Amazon ECR.
9. **Terraform Init and Apply**: Initialize and apply the Terraform configuration to create/update infrastructure.
10. **Deploy to Kubernetes**: Deploy the application to Kubernetes using the deployment and service configurations.

## Secrets Management

Secrets required for the CI/CD pipeline are stored in GitHub Secrets:
- `AWS_ACCESS_KEY_ID`


- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`
- `AWS_ACCOUNT_ID`
- `TMDB_API_KEY`
- `KUBECONFIG` (Base64 encoded content of your kubeconfig file)

## Kubernetes Deployment

### Create the TMDB API Key Secret

Before deploying the application, ensure the TMDB API key secret is created in the Kubernetes cluster.

```sh
kubectl create secret generic tmdb-api-key-secret --from-literal=TMDB_API_KEY=<YOUR_TMDB_API_KEY>
```

### Apply Kubernetes Resources

```sh
kubectl apply -f kubernetes/deployment.yml
kubectl apply -f kubernetes/service.yml
```

## Destroy Infrastructure

To destroy the infrastructure created by Terraform, a separate GitHub Actions workflow is provided (`destroy.yml`). This workflow will:
1. Checkout the latest code from the repository.
2. Configure AWS credentials using GitHub Secrets.
3. Run `terraform destroy` to destroy all resources created by Terraform.
4. Delete the ECR repository if it exists.
5. Delete the IAM role and policy if they exist.

## Getting Started

### Prerequisites

- AWS account with necessary permissions
- Docker installed
- Kubernetes cluster set up (e.g., EKS, GKE, AKS, or Minikube)
- GitHub repository with Actions enabled

### Clone the Repository

```sh
git clone https://github.com/yourusername/netflix-clone.git
cd netflix-clone
```

### Setting up Environment Variables

Set the required environment variables in GitHub Secrets.

### Running the Application Locally

1. **Build Docker Image**

   ```sh
   docker build -t netflix-clone:latest -f backend/Dockerfile backend
   ```

2. **Run Docker Container**

   ```sh
   docker run -p 5000:5000 --env TMDB_API_KEY=your_tmdb_api_key netflix-clone:latest
   ```

### Trigger CI/CD Pipeline

Push changes to the repository or create a pull request to trigger the CI/CD pipeline.

### Destroy Infrastructure

Trigger the `Destroy Infrastructure` workflow manually from the GitHub Actions tab.

## Conclusion

This project demonstrates a comprehensive setup for deploying a cloud-native application using modern DevOps practices. The CI/CD pipeline ensures that the application can be reliably and efficiently deployed, while Terraform provides infrastructure as code for reproducibility and scalability.
```

Ensure you replace placeholders such as `<YOUR_AWS_ACCOUNT_ID>`, `<YOUR_AWS_REGION>`, and `<YOUR_TMDB_API_KEY>` with actual values. Commit and push these changes to your repository. This setup should provide a comprehensive record of your project and ensure that your CI/CD pipeline can handle idempotent ECS service creation.

test