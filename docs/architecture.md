                                       +------------------------+
                                       |      AWS Account       |
                                       |                        |
+-------------------+                  |  +------------------+  |
|                   |                  |  |   IAM Policies   |  |
|    End Users      |  <-------------->|  +------------------+  |
|                   |                  |                        |
+---------+---------+                  |                        |
          |                            |  +------------------+  |
          |                            |  |   VPC            |  |
          |                            |  |  (10.0.0.0/16)   |  |
          |                            |  +--------+---------+  |
          |                            |           |            |
          |                            |  +--------+---------+  |
          |                            |  |      Subnet      |  |
          |                            |  |  (10.0.1.0/24)   |  |
          |                            |  +--------+---------+  |
          |                            |           |            |
          |                            |  +--------+---------+  |
          |                            |  |      Subnet      |  |
          |                            |  |  (10.0.2.0/24)   |  |
          |                            |  +--------+---------+  |
          |                            |           |            |
          |                            |  +--------+---------+  |
          |                            |  |    Internet       |  |
          |                            |  |     Gateway       |  |
          |                            |  +--------+---------+  |
          |                            |           |            |
          |                            |  +--------+---------+  |
          |                            |  |  Route Tables    |  |
          |                            |  +--------+---------+  |
          |                            |                        |
          |                            |  +------------------+  |
          |                            |  |     ECS Cluster   | |
          |                            |  +------------------+  |
          |                            |  |    ECS Service    | |
          |                            |  |ECS Task Definition| |
          |                            |  +------------------+  |
          |                            |                        |
          |                            |  +------------------+  |
          |                            |  |     EKS Cluster   | |
          |                            |  +------------------+  |
          |                            |  |     Node Group    | |
          |                            |  +------------------+  |
          |                            |                        |
          |                            |  +------------------+  |
          |                            |  |     ECR Repo     |  |
          |                            |  +------------------+  |
          |                            |                        |
          +---------------------------->   |  K8s Deployment   | |
          |                            |  +------------------+  |
          |                            |  |   K8s Service    |  |
          |                            |  +------------------+  |
          +---------------------------->+------------------+  |
                                       |  |  ALB (Load Balancer) |
                                       |  +------------------+  |
                                       +------------------------+


End Users: Access the application via a public URL.
IAM Policies: Manage permissions for the ECS and EKS clusters.
VPC: Network isolation for the resources, with two subnets in different availability zones for high availability.
Internet Gateway: Allows instances within the VPC to access the internet.
Route Tables: Manage routing rules within the VPC.
ECS Cluster and Service: Manages the deployment of Docker containers.
EKS Cluster: Manages Kubernetes clusters for container orchestration.
ECR Repo: Stores Docker images used by ECS and EKS.
Kubernetes Deployment and Service: Defines the deployment of applications in the EKS cluster.
ALB (Load Balancer): Distributes incoming application traffic across multiple targets in multiple availability zones.



# Architecture Overview

## Introduction
This document provides an overview of the architecture for the Netflix Clone application.

## Components
1. **Backend Application**
   - Flask-based application to fetch movie data using TMDB API.
   - Dockerized and hosted on ECS Fargate.

2. **Infrastructure**
   - Managed using Terraform.
   - Includes VPC, subnets, EKS cluster, ECS cluster, ECR repository, IAM roles, and security groups.

3. **CI/CD Pipeline**
   - GitHub Actions workflow for automated build, test, and deployment.
   - Terraform for infrastructure as code.
   - Docker for containerization.
   - Kubernetes for container orchestration.

4. **Kubernetes Deployment**
   - Deployment and Service YAML files for deploying the application to the EKS cluster.
   - Uses LoadBalancer type for external access.

## Diagram

[Insert the updated architecture diagram here]

## Networking
- VPC with public subnets across multiple availability zones.
- EKS and ECS clusters within the VPC.
- Load Balancer for external access to the application.

## Security
- IAM roles for ECS task execution and EKS cluster management.
- Security groups to control inbound and outbound traffic.

## Storage
- ECR repository for storing Docker images.

