# Netflix Clone Backend Application

## Project Overview

The objective of this project is to build a backend application that mimics some of the functionalities of Netflix, such as retrieving user and movie data. The application is containerized using Docker and managed through a CI/CD pipeline for automated deployment. The project uses AWS resources to ensure scalability, reliability, and ease of management.

## Key Requirements

### Backend Application

- A Flask-based web application.
- Endpoints to fetch user and movie data.
- Containerized using Docker.

### CI/CD Pipeline

- Automated build, test, and deployment process.
- Integration with GitHub Actions.
- Environment-specific deployments (dev, uat, prod).

### AWS Resources

- Use of EKS for Kubernetes.
- ECR for Docker image storage.
- IAM roles for managing permissions.
- VPC for network isolation.

### TMDB API Integration

- Fetch movie data from TMDB API.

### Branching Strategy

- Branches: prod, uat, dev, and feature.
- Developers work on feature branches, merge to dev.
- dev merges to uat, and uat merges to prod upon approval.

## Detailed Requirements

### Backend Application

- Develop endpoints to handle user and movie data.
- Ensure the application can be run in a Docker container.
- Use Flask to build the API endpoints.

### CI/CD Pipeline

- Automate Docker image build and push to ECR.
- Use Terraform to manage infrastructure as code.
- Automate Kubernetes deployment using kubectl.
- Implement environment-specific configurations for dev, uat, and prod environments.

### AWS Infrastructure

- EKS (Elastic Kubernetes Service): Manage Kubernetes clusters.
- ECR (Elastic Container Registry): Store Docker images.
- IAM (Identity and Access Management): Manage permissions and roles.
- VPC (Virtual Private Cloud): Network configuration and isolation.

### TMDB API Integration

- Fetch and display movie data from the TMDB API.
- Secure API key management using AWS Secrets Manager.

## Implementation Details

### Backend Application

- **Flask Application**: Handle API requests and responses.
- **Docker Container**: Encapsulate the application and its dependencies.
- **Endpoints**:
  - `/api/users`: Fetch user data.
  - `/api/movies`: Fetch movie data from TMDB API.

### CI/CD Pipeline

- **GitHub Actions**: Automate the build and deployment process.
  - **Steps**:
    1. Checkout code.
    2. Build Docker image.
    3. Push Docker image to ECR.
    4. Terraform apply to set up AWS infrastructure.
    5. Deploy to Kubernetes using kubectl.
    6. Tag subnets for Load Balancer.
    7. Update kubeconfig for AWS EKS.
- **Branches**:
  - Feature: Development of new features.
  - Dev: Integration testing.
  - Uat: User acceptance testing.
  - Prod: Production deployment.

### AWS Resources

- **VPC**: Isolated network for the application.
- **EKS Cluster**: Kubernetes management.
- **ECR Repository**: Store Docker images.
- **IAM Roles**: Permissions for EKS and ECS tasks.
- **Subnets**: Network segments for EKS nodes and services.

### TMDB API Integration

- **Flask Route**: Fetch and display movie data.
- **API Key Management**: Secure handling of TMDB API key using AWS Secrets Manager.

## Expected User Experience

### API Access

- Users can access the API endpoints to retrieve data.
- Example endpoints: `/api/users` and `/api/movies`.

### Deployment

- Continuous integration and deployment ensure the latest changes are always available.
- Environment-specific deployments allow for testing and validation before production release.

### Scalability

- AWS EKS and ECS provide scalable infrastructure to handle increasing load.
- Docker containers ensure consistent application deployment across environments.

### Reliability

- Automated testing and deployment reduce the risk of errors.
- AWS infrastructure provides high availability and fault tolerance.

## Repository Structure

```plaintext
.
├── backend
│   ├── src
│   │   ├── main.py
│   │   ├── utils.py
│   │   └── requirements.txt
│   └── Dockerfile
├── kubernetes
│   ├── deployment.yml
│   └── service.yml
├── terraform
│   ├── main.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── variables.tf
│   └── versions.tf
├── .github
│   └── workflows
│       ├── ci-cd.yml
│       └── destroy.yml
└── README.md
```

## Setup and Deployment

### Prerequisites

- Docker
- AWS CLI
- Terraform
- GitHub Actions configured with necessary secrets

### Local Development

1. Clone the repository:

```bash
git clone https://github.com/your-repo/netflix-clone.git
cd netflix-clone
```

2. Set up a virtual environment and install dependencies:

```bash
cd backend/src
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

3. Run the application locally:

```bash
python main.py
```

The application will be accessible at `http://localhost:5000`.

### Containerization

1. Build the Docker image:

```bash
docker build -t netflix-clone-backend:latest .
```

2. Run the Docker container:

```bash
docker run -p 5000:5000 netflix-clone-backend:latest
```

### Infrastructure Deployment

1. Initialize and apply Terraform configuration:

```bash
cd terraform
terraform init
terraform apply -auto-approve
```

### CI/CD Pipeline

The CI/CD pipeline is managed using GitHub Actions. It includes steps for:

- Checking out the code
- Setting up Docker Buildx
- Logging in to Amazon ECR
- Building and pushing Docker images
- Initializing and applying Terraform configuration
- Generating kubeconfig for EKS
- Configuring AWS credentials for kubectl
- Deploying to Kubernetes

The workflow files are located in `.github/workflows/ci-cd.yml` and `.github/workflows/destroy.yml`.

### Destroying Infrastructure

To destroy the infrastructure, run the destroy workflow from the GitHub Actions UI, providing the branch name for which resources need to be destroyed.

## Contributions

Contributions are welcome! Please fork the repository and submit pull requests.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

## Contact

For any questions or inquiries, please contact the group members via GitHub.
test