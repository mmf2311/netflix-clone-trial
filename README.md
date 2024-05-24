# Netflix Clone

A Netflix clone application built with React for the frontend and Node.js with Express for the backend. It uses various AWS services for deployment and infrastructure management, Docker for containerization, and GitHub Actions for CI/CD. The project also includes unit tests for both frontend and backend.

## Table of Contents

- [Netflix Clone](#netflix-clone)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Architecture](#architecture)
    - [Architecture Components](#architecture-components)
  - [Project Structure](#project-structure)
  - [Dependencies](#dependencies)
  - [Setup and Installation](#setup-and-installation)
    - [Prerequisites](#prerequisites)
    - [Environment Variables](#environment-variables)
    - [Frontend Setup](#frontend-setup)
    - [Backend Setup](#backend-setup)
    - [Docker Setup](#docker-setup)
    - [Terraform Setup](#terraform-setup)
  - [Running Unit Tests](#running-unit-tests)
  - [Branching Strategy](#branching-strategy)
  - [CI/CD Pipeline](#cicd-pipeline)
  - [Destroying the Infrastructure](#destroying-the-infrastructure)
  - [Troubleshooting and Debugging](#troubleshooting-and-debugging)
  - [Group Members](#group-members)
  - [License](#license)
  - [Acknowledgements](#acknowledgements)

## Overview

This project is a full-stack Netflix clone application designed to showcase the use of modern web technologies and cloud infrastructure. The application fetches movie data from the TMDB API and displays it in a Netflix-like interface.

## Architecture

### Detailed Architecture Diagram

```plaintext
                                         +---------------------+
                                         |        User         |
                                         +---------+-----------+
                                                   |
                                                   v
                                         +---------+-----------+
                                        

 |   AWS CloudFront    |
                                         +---------+-----------+
                                                   |
                                                   v
                                         +---------+-----------+
                                         |       AWS S3        |
                                         |   (Frontend React)  |
                                         +---------+-----------+
                                                   |
                                                   v
                                         +---------+-----------+
                                         |     API Gateway     |
                                         +---------+-----------+
                                                   |
                                                   v
                                         +---------+-----------+
                                         |    Load Balancer    |
                                         +---------+-----------+
                                                   |
                                                   v
                    +--------------+--------------+  +--------------+--------------+  +--------------+--------------+
                    |  Dev Environment            |  |  Stage Environment          |  |  Prod Environment           |
                    +--------------+--------------+  +--------------+--------------+  +--------------+--------------+
                    |    AWS ECS                   |  |    AWS ECS                 |  |    AWS ECS                   |
                    |  (Node.js Backend)           |  |  (Node.js Backend)         |  |  (Node.js Backend)           |
                    +--------------+---------------+  +--------------+--------------+  +--------------+--------------+
                              |                              |                               |
                              v                              v                               v
                      +-------+-------+              +-------+-------+               +-------+-------+
                      |  Amazon RDS   |              |  Amazon RDS   |               |  Amazon RDS   |
                      |  (Database)   |              |  (Database)   |               |  (Database)   |
                      +-------+-------+              +-------+-------+               +-------+-------+
                              |                              |                               |
                              v                              v                               v
                  +-----------+-----------+        +-----------+-----------+       +-----------+-----------+
                  |  Amazon ElastiCache   |        |  Amazon ElastiCache   |       |  Amazon ElastiCache   |
                  |     (Cache)           |        |     (Cache)           |       |     (Cache)           |
                  +-----------+-----------+        +-----------+-----------+       +-----------+-----------+
                              |                              |                               |
                              v                              v                               v
                  +-----------+-----------+        +-----------+-----------+       +-----------+-----------+
                  |   Cached Responses   |        |   Cached Responses   |       |   Cached Responses   |
                  +----------------------+        +----------------------+       +----------------------+

                                   +----------------------+
                                   |     Terraform        |
                                   |  (Infrastructure as  |
                                   |      Code)           |
                                   +----------------------+
                                           |
                                           v
                       +-------------------+-------------------+
                       |    VPC, Subnets, Security Groups,     |
                       |        IAM Roles and Policies         |
                       +-------------------+-------------------+

                                   +----------------------+
                                   |   GitHub Actions     |
                                   |   (CI/CD Pipeline)   |
                                   +----------------------+
                                           |
                                           v
                                   +----------------------+
                                   |  Build, Test, Deploy |
                                   +----------------------+

                                   +----------------------+
                                   |     TMDB API         |
                                   |  (External Service)  |
                                   +----------------------+
```

### Components and Connections:

1. **Frontend (React)**
   - **AWS S3**: Hosts the static files for the React frontend.
   - **AWS CloudFront**: Serves the frontend content globally with low latency.

2. **Backend (Node.js with Express)**
   - **Docker**: Containerizes the backend application.
   - **AWS ECR (Elastic Container Registry)**: Stores the Docker images.
   - **AWS ECS (Elastic Container Service)**: Manages and runs the Docker containers.
   - **API Gateway**: Routes requests to the backend services in ECS.
   - **Load Balancer**: Distributes traffic among ECS tasks.

3. **Environments**:
   - **Development Environment**:
     - **AWS ECS**: Runs the Node.js backend.
     - **Amazon RDS**: Relational data storage.
     - **Amazon ElastiCache**: Caches frequently accessed data.
   - **Staging Environment**:
     - **AWS ECS**: Runs the Node.js backend.
     - **Amazon RDS**: Relational data storage.
     - **Amazon ElastiCache**: Caches frequently accessed data.
   - **Production Environment**:
     - **AWS ECS**: Runs the Node.js backend.
     - **Amazon RDS**: Relational data storage.
     - **Amazon ElastiCache**: Caches frequently accessed data.

4. **Infrastructure**
   - **Terraform**: Manages the infrastructure as code.
   - **Components**:
     - **VPC**: Virtual Private Cloud for network isolation.
     - **Subnets**: Public and private subnets for organizing resources.
     - **Security Groups**: Controls traffic with firewall rules.
     - **IAM Roles and Policies**: Manages access permissions.

5. **CI/CD (GitHub Actions)**
   - **Automated Workflows**: For building, testing, and deploying the application.
   - **Processes**: Runs on every push to any branch, includes deploying to dev, stage, and prod environments.

6. **External API**
   - **TMDB API**: Provides movie data for the application.

## Project Structure

```plaintext
netflix-clone/
├── frontend/
│   ├── src/
│   │   ├── App.js
│   │   ├── App.test.js
│   │   ├── App.css
│   │   └── ...
│   ├── public/
│   ├── Dockerfile
│   ├── package.json
│   ├── package-lock.json
│   └── ...
├── backend/
│   ├── src/
│   │   ├── index.js
│   │   ├── movies.js
│   │   ├── movies.test.js
│   │   └── ...
│   ├── Dockerfile
│   ├── package.json
│   ├── package-lock.json
│   └── ...
├── infrastructure/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── ...
│   ├── stage/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── ...
│   ├── prod/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── ...
│   └── ...
├── .github/
│   └── workflows/
│       ├── ci-cd.yml
│       ├── destroy.yml
│       └── ...
└── README.md
```

## Dependencies

### Frontend

- React
- React DOM
- Babel
- Webpack
- Jest
- @testing-library/react
- @testing-library/jest-dom
- @babel/preset-react

### Backend

- Express
- Axios
- Jest
- Supertest

### Infrastructure

- Terraform
- AWS CLI

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

## Running Unit Tests

### Frontend

To run the frontend unit tests, navigate to the `frontend` directory and use the following command:

```sh
npm test
```

### Backend

To run the backend unit tests, navigate to the `backend` directory and use the following command:

```sh
npm test
```

## Branching Strategy

The branching strategy for this project is as follows:

1. **`prod`**: Production branch
2. **`stage`**: Staging branch, merges from `dev`
3. **`dev`**: Development branch, merges from feature branches
4. **`feature/*`**: Feature branches, branched from `dev` and merge back into `dev`

## CI/CD Pipeline

The CI/CD pipeline is defined using GitHub

 Actions and includes the following workflows:

- **Build and Test**: Runs on every push to any branch
- **Deploy to Dev**: Runs on push to `dev` branch
- **Deploy to Stage**: Runs on push to `stage` branch
- **Deploy to Prod**: Runs on push to `prod` branch

For detailed configuration, see the [GitHub Actions workflow file](.github/workflows/ci-cd.yml).

## Destroying the Infrastructure

To destroy the infrastructure for each environment, you can use the following GitHub Actions workflow.

For detailed configuration, see the [GitHub Actions destroy workflow file](.github/workflows/destroy.yml).

### Running the Destroy Workflow

1. Go to the Actions tab in your GitHub repository.
2. Select the "Destroy Infrastructure" workflow.
3. Click the "Run workflow" button and choose the appropriate environment (dev, stage, or prod) to destroy the infrastructure.

This will trigger the workflow and execute `terraform destroy` for the specified environment, removing all AWS resources created by the CI/CD pipeline.

## Troubleshooting and Debugging

### Common Issues

1. **Error: Network connection issues**
   - Ensure that your AWS credentials are correctly configured.
   - Verify that your network allows connections to AWS services.

2. **Error: Docker container not starting**
   - Check the Docker logs for more information: `docker logs <container_id>`
   - Ensure that the Docker service is running on your machine.

3. **Error: Terraform apply fails**
   - Check the Terraform logs for more details.
   - Ensure that your AWS credentials have the necessary permissions.

### Debugging Tips

- Use `console.log` in Node.js and `console.debug` in React to log useful debugging information.
- Use breakpoints and the debugger in your IDE to step through your code.

## Group Members

- Nor Shukri
- Muhammad Tarmizi
- Hnin Wut Yee
- Mohamed Malik
- Mohammad Sufiyan

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgements

- [TMDB API](https://www.themoviedb.org/documentation/api) for movie data
- [React](https://reactjs.org/)
- [Node.js](https://nodejs.org/)
- [AWS](https://aws.amazon.com/)
- [Docker](https://www.docker.com/)
- [Terraform](https://www.terraform.io/)