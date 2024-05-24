# Netflix Clone

A Netflix clone application built with React for the frontend and Node.js with Express for the backend. It uses various AWS services for deployment and infrastructure management, Docker for containerization, and GitHub Actions for CI/CD.

## Table of Contents

- [Netflix Clone](#netflix-clone)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Architecture](#architecture)
  - [Setup and Installation](#setup-and-installation)
    - [Prerequisites](#prerequisites)
    - [Environment Variables](#environment-variables)
    - [Frontend Setup](#frontend-setup)
    - [Backend Setup](#backend-setup)
    - [Docker Setup](#docker-setup)
    - [Terraform Setup](#terraform-setup)
  - [Branching Strategy](#branching-strategy)
  - [CI/CD Pipeline](#cicd-pipeline)
  - [Destroying the Infrastructure](#destroying-the-infrastructure)
  - [License](#license)
  - [Acknowledgements](#acknowledgements)

## Overview

This project is a full-stack Netflix clone application designed to showcase the use of modern web technologies and cloud infrastructure. The application fetches movie data from the TMDB API and displays it in a Netflix-like interface.

## Architecture

The application is structured as follows:

![Architecture Diagram](architecture-diagram.png)

### Architecture Components

1. **Frontend (React)**:
   - **React**: A JavaScript library for building user interfaces.
   - **S3**: AWS Simple Storage Service, used to host the static files for the frontend.
   - **CloudFront**: AWS Content Delivery Network (CDN), used to deliver the frontend content globally with low latency.

2. **Backend (Node.js with Express)**:
   - **Node.js**: A JavaScript runtime built on Chrome's V8 JavaScript engine.
   - **Express**: A web application framework for Node.js, used to build the RESTful API.
   - **Docker**: Used to containerize the backend application for consistent deployment.
   - **ECR**: AWS Elastic Container Registry, used to store Docker images.
   - **ECS**: AWS Elastic Container Service, used to run the Docker containers.
   - **API Gateway**: AWS API Gateway, used to expose the backend services.

3. **Infrastructure (Terraform)**:
   - **Terraform**: An infrastructure as code tool used to provision and manage the AWS resources.
   - **IAM**: AWS Identity and Access Management, used to manage access to AWS services and resources.
   - **VPC, Subnets, Security Groups**: AWS Virtual Private Cloud, used to create a secure network environment.

4. **CI/CD (GitHub Actions)**:
   - **GitHub Actions**: Used for Continuous Integration and Continuous Deployment (CI/CD) to automate the build, test, and deployment process.

5. **External API**:
   - **TMDB API**: The Movie Database API, used to fetch movie data for the application.

## Setup and Installation

### Prerequisites

Ensure you have the following installed:

- [Node.js](https://nodejs.org/)
- [npm](https://www.npmjs.com/)
- [Docker](https://www.docker.com/)
- [Terraform](https://www.terraform.io/)
- AWS CLI configured with appropriate credentials

### Environment Variables

Set the following environment variables in your GitHub repository secrets and locally as needed:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `DOCKER_USERNAME`
- `DOCKER_PASSWORD`
- `AWS_ACCOUNT_ID`
- `AWS_REGION` (us-east-1)
- `TMDB_API_KEY`

### Frontend Setup

1. Navigate to the `frontend` directory:
   ```sh
   cd frontend
   ```

2. Initialize the project and install dependencies:
   ```sh
   npm install
   ```

3. Start the frontend application:
   ```sh
   npm start
   ```

### Backend Setup

1. Navigate to the `backend` directory:
   ```sh
   cd backend
   ```

2. Initialize the project and install dependencies:
   ```sh
   npm install
   ```

3. Start the backend application:
   ```sh
   npm start
   ```

### Docker Setup

1. Ensure you have Docker installed and running.

2. Build and run the Docker containers:
   ```sh
   docker-compose up
   ```

### Terraform Setup

1. Navigate to the appropriate infrastructure directory (`dev`, `stage`, or `prod`):
   ```sh
   cd infrastructure/dev
   ```

2. Initialize Terraform:
   ```sh
   terraform init
   ```

3. Apply the Terraform configuration:
   ```sh
   terraform apply -var="docker_image_tag=latest"
   ```

## Branching Strategy

The branching strategy for this project is as follows:

1. **`prod`**: Production branch
2. **`stage`**: Staging branch, merges from `dev`
3. **`dev`**: Development branch, merges from feature branches
4. **`feature/*`**: Feature branches, branched from `dev` and merge back into `dev`

## CI/CD Pipeline

The CI/CD pipeline is defined using GitHub Actions and includes the following workflows:

- **Build and Test**: Runs on every push to any branch
- **Deploy to Dev**: Runs on push to `dev` branch
- **Deploy to Stage**: Runs on push to `stage` branch
- **Deploy to Prod**: Runs on push to `prod` branch

**GitHub Actions Workflow (`.github/workflows/ci-cd.yml`):**

```yaml
name: CI/CD Pipeline

on:
  push:
    branches:
      - prod
      - stage
      - dev
      - 'feature/*'

jobs:
  build-and-test:
    runs-on: ubuntu-latest

    services:
      docker:
        image: docker:19.03.12
        options: --privileged

    steps:
    - name: Checkout code
      uses: actions/checkout@v2

    - name: Set up Node.js
      uses: actions/setup-node@v2
      with:
        node-version: '14'

    - name: Install dependencies and run tests (frontend)
      run: |
        cd frontend
        npm install
        npm test

    - name: Install dependencies and run tests (backend)
      run: |
        cd backend
        npm install
        npm test

    - name: Build and tag Docker images (frontend)
      run: |
        docker build -t group-3-frontend-netflix-clone:latest ./frontend
        docker tag group-3-frontend-netflix-clone:latest ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/group-3-frontend-netflix-clone:latest

    - name: Build and tag Docker images (backend)
      run: |
        docker build -t group-3-backend-netflix-clone:latest ./backend
        docker tag group-3-backend-netflix-clone:latest ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/group-3-backend-netflix-clone:latest

    - name: Login to AWS ECR
      id: ecr-login
      uses: aws-actions/amazon-ecr-login@v1

    - name: Push Docker images to ECR (frontend)
      run: |
        docker push ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/group-3-frontend-netflix-clone:latest

    - name: Push Docker images to ECR (backend)
      run: |
        docker push ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/group-3-backend-netflix-clone:latest

  deploy-dev:
    if: github.ref == 'refs/heads/dev'
    needs: build-and-test
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v2

    - name: Set up AWS credentials
      uses: aws-actions/configure-aws-credentials@v1
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ secrets.AWS_REGION }}

    - name: Deploy to ECS (Dev)
      run: |
        cd infrastructure/dev
        terraform init
        terraform apply -auto-approve -var="docker_image_tag=latest" -var="docker_image_repo_frontend=${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/group-3-frontend-netflix-clone" -var="docker_image_repo_backend=${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/group-3-backend-netflix-clone"

  deploy-stage:
    if: github.ref == 'refs/heads/stage'
    needs: build-and-test
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v2

    - name: Set up AWS credentials
      uses: aws-actions/configure-aws-credentials@v1
      with:


        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ secrets.AWS_REGION }}

    - name: Deploy to ECS (Stage)
      run: |
        cd infrastructure/stage
        terraform init
        terraform apply -auto-approve -var="docker_image_tag=latest" -var="docker_image_repo_frontend=${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/group-3-frontend-netflix-clone" -var="docker_image_repo_backend=${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/group-3-backend-netflix-clone"

  deploy-prod:
    if: github.ref == 'refs/heads/prod'
    needs: build-and-test
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v2

    - name: Set up AWS credentials
      uses: aws-actions/configure-aws-credentials@v1
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ secrets.AWS_REGION }}

    - name: Deploy to ECS (Prod)
      run: |
        cd infrastructure/prod
        terraform init
        terraform apply -auto-approve -var="docker_image_tag=latest" -var="docker_image_repo_frontend=${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/group-3-frontend-netflix-clone" -var="docker_image_repo_backend=${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/group-3-backend-netflix-clone"
```

## Destroying the Infrastructure

To destroy the infrastructure for each environment, you can use the following GitHub Actions workflow.

**GitHub Actions Workflow (`.github/workflows/destroy.yml`):**

```yaml
name: Destroy Infrastructure

on:
  workflow_dispatch:

jobs:
  destroy-dev:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v2

    - name: Set up AWS credentials
      uses: aws-actions/configure-aws-credentials@v1
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ secrets.AWS_REGION }}

    - name: Destroy Dev Infrastructure
      run: |
        cd infrastructure/dev
        terraform init
        terraform destroy -auto-approve

  destroy-stage:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v2

    - name: Set up AWS credentials
      uses: aws-actions/configure-aws-credentials@v1
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ secrets.AWS_REGION }}

    - name: Destroy Stage Infrastructure
      run: |
        cd infrastructure/stage
        terraform init
        terraform destroy -auto-approve

  destroy-prod:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v2

    - name: Set up AWS credentials
      uses: aws-actions/configure-aws-credentials@v1
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ secrets.AWS_REGION }}

    - name: Destroy Prod Infrastructure
      run: |
        cd infrastructure/prod
        terraform init
        terraform destroy -auto-approve
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgements

- [TMDB API](https://www.themoviedb.org/documentation/api) for movie data
- [React](https://reactjs.org/)
- [Node.js](https://nodejs.org/)
- [AWS](https://aws.amazon.com/)
- [Docker](https://www.docker.com/)
- [Terraform](https://www.terraform.io/)
```

This `README.md` file includes a detailed architecture section explaining the use of each tool and service in the project. It follows best practices for documentation, ensuring clarity and ease of use. Adjust the content as needed to fit the specifics of your project.