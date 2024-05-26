# Netflix Clone Application

This project is a Netflix clone application built using GitHub Actions, AWS resources, Docker, Terraform, and other tools.

## Team Members
1. Mohammad Nor Shukri
2. Muhammad Tarmizi
3. Hnin Wut Yee
4. Mohamed Malik
5. Mohammad Sufiyan

## Project Overview
The objective of this project is to create a Netflix clone application that automates the deployment process using CI/CD pipelines, containerization, and various AWS services. The application includes features like user authentication, movie browsing, and searching using the TMDB API, and more.

## Features
- User authentication
- Movie browsing and searching using TMDB API
- Movie details view
- Basic user profile management

## Project Structure
- `.github/workflows`: GitHub Actions workflows for CI/CD and destroying infrastructure
  - `ci-cd.yml`: CI/CD pipeline workflow
  - `destroy.yml`: Workflow to destroy all AWS resources
- `backend`: Backend application source code and Dockerfile
  - `src`: Source code directory
    - `main.py`: Main application file
    - `utils.py`: Utility functions
- `terraform`: Terraform scripts for infrastructure as code
  - `main.tf`: Main Terraform configuration
  - `variables.tf`: Terraform variables
  - `outputs.tf`: Terraform outputs
- `kubernetes`: Kubernetes deployment and service files
  - `deployment.yml`: Kubernetes deployment configuration
  - `service.yml`: Kubernetes service configuration
- `docs`: Documentation files
  - `architecture.md`: Network architecture documentation
  - `setup.md`: Setup instructions
- `README.md`: Project documentation file

## Versioning
This project follows Semantic Versioning:
- **MAJOR** version when making incompatible API changes
- **MINOR** version when adding functionality in a backwards-compatible manner
- **PATCH** version when making backwards-compatible bug fixes

### Current Version
- **1.0.0**: Initial release with base features including user authentication, movie browsing, and searching.

## Getting Started
### Prerequisites
- Docker
- Terraform
- AWS CLI
- Kubernetes CLI (kubectl)
- GitHub account with access to the repository

### Setup
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/yourusername/netflix-clone.git
   cd netflix-clone
   ```

2. **Configure AWS CLI**:
   ```bash
   aws configure
   ```

3. **Build and Push Docker Image**:
   ```bash
   docker build -t netflix-clone ./backend
   docker tag netflix-clone:latest <AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com/netflix-clone:latest
   docker push <AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com/netflix-clone:latest
   ```

4. **Deploy Infrastructure using Terraform**:
   ```bash
   cd terraform
   terraform init
   terraform apply -auto-approve
   ```

5. **Deploy to Kubernetes**:
   ```bash
   kubectl apply -f ./kubernetes
   ```

## CI/CD Pipeline
The CI/CD pipeline is managed using GitHub Actions and includes the following workflows:
- **CI/CD Workflow (ci-cd.yml)**: Builds, tests, and deploys the application on every push or pull request to the `dev`, `main`, or `feature/*` branches.
- **Destroy Workflow (destroy.yml)**: Destroys all resources created in AWS.

### CI/CD Workflow Details
1. **Build and push Docker image**:
   - Uses Docker to build the image and pushes it to AWS ECR.
2. **Deploy to ECR**:
   - Tags and pushes the Docker image to AWS Elastic Container Registry.
3. **Terraform Apply**:
   - Deploys infrastructure using Terraform.
4. **Deploy to Kubernetes**:
   - Applies Kubernetes configurations for deployment and service.

### Destroy Workflow Details
1. **Terraform Destroy**:
   - Destroys all infrastructure resources created by Terraform.

## Network Architecture
The architecture consists of the following components:
- **API Gateway**: Exposes the Lambda functions as RESTful APIs.
- **Lambda**: Handles the business logic in a serverless environment.
- **Docker**: Ensures portability and consistency across different environments.
- **Terraform**: Manages infrastructure as code, providing version control and reusability.
- **ECR**: Stores Docker images.
- **ECS**: Runs containerized applications.
- **SNS**: Sends notifications.
- **SQS**: Manages message queues to decouple microservices.
- **EC2**: Runs virtual servers.
- **Kubernetes**: Manages container orchestration.

### ASCII Diagram
```plaintext
                                      +-------------+
                                      |   Users     |
                                      +------+------+
                                             |
                                             |
                                      +------+------+
                                      |   Route53   |
                                      +------+------+
                                             |
                                             |
                                      +------+------+
                                      | API Gateway |
                                      +------+------+
                                             |
                        +--------------------+------------------+
                        |                                       |
                +-------+-------+                       +-------+-------+
                |  AWS Lambda   |                       |  AWS Lambda   |
                +-------+-------+                       +-------+-------+
                        |                                       |
                        |                                       |
           +------------+------------+            +------------+------------+
           |                         |            |                         |
    +------+-----+            +------+-----+  +------+-----+            +------+-----+
    |  DynamoDB  |            |  SQS Queue |  |  SNS Topic |            |  DynamoDB  |
    +------------+            +------------+  +------------+            +------------+
```

## Potential Enhancements
- **User Reviews and Ratings**: Implement a system for users to leave reviews and rate movies.
- **Recommendation Engine**: Develop a recommendation engine to suggest movies based on user preferences and watch history.
- **Video Streaming**: Integrate video streaming capabilities.
- **User Notifications**: Use SNS to notify users about new movies, updates, or recommendations.
- **Offline Mode**: Allow users to download movies for offline viewing.
- **Multi-language Support**: Add support for multiple languages to cater to a broader audience.

## Documentation
Detailed documentation is available in the `docs` directory:
- [Network Architecture](docs/architecture.md)
- [Setup Instructions](docs/setup.md)

## Contributing
To contribute to this project:
1. Create a new feature branch from the `dev` branch.
2. Make your changes.
3. Create a pull request to the `dev` branch.

## License
This project is licensed under the MIT License.