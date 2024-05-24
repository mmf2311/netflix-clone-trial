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
