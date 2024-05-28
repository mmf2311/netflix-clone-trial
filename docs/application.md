The Netflix clone application is a web-based streaming service that allows users to search for movies and view detailed information about them. Below is a detailed explanation of the application, including its architecture, features, tools used, and workflow.

Application Overview
Purpose:
The purpose of this application is to create a simplified version of Netflix, where users can search for movies using the TMDB (The Movie Database) API and view details about the movies. The application is containerized and deployed using modern DevOps practices, leveraging AWS services for scalability and reliability.

Key Features
Movie Search: Users can search for movies by title.
Movie Details: The application fetches and displays details about the searched movies using the TMDB API.
Containerized Deployment: The backend application is containerized using Docker.
CI/CD Pipeline: Automated deployment using GitHub Actions.
AWS Integration: Utilizes AWS services like ECR, ECS, EKS, IAM, and VPC.

Tools and Technologies
Python & Flask: Used for the backend API to handle movie search requests.
Requests Library: To make HTTP requests to the TMDB API.
Docker: For containerizing the application.
Terraform: For infrastructure as code, managing AWS resources.
AWS Services: ECR (Elastic Container Registry), ECS (Elastic Container Service), EKS (Elastic Kubernetes Service), IAM (Identity and Access Management), VPC (Virtual Private Cloud).
GitHub Actions: For CI/CD pipeline to automate build, test, and deployment processes.

+------------------------------------------------+
|                    User                        |
+------------------------------------------------+
                       |
                       v
+---------------------+--------------------------+
|               Load Balancer (ELB)              |
+---------------------+--------------------------+
                       |
                       v
+---------------------+--------------------------+
|                AWS EKS Cluster                 |
|  +------------------------------------------+  |
|  |           Kubernetes Deployment          |  |
|  |  +------------------------------------+  |  |
|  |  |  Pod (netflix-clone container)     |  |  |
|  |  +------------------------------------+  |  |
|  +------------------------------------------+  |
+---------------------+--------------------------+
                       |
                       v
+---------------------+--------------------------+
|                    TMDB API                    |
+---------------------+--------------------------+

Workflow
User Request:

The user makes a search request for a movie title through the web interface.
Load Balancer:

The request is directed to the Load Balancer (ELB), which routes the request to one of the pods in the EKS cluster.
EKS Cluster:

The EKS cluster hosts the Kubernetes deployment, which includes pods running the Netflix clone application.
Kubernetes Deployment:

The pod runs the Flask application, which processes the user request and makes an API call to the TMDB API to fetch movie details.
TMDB API Call:

The Flask application uses the Requests library to fetch movie data from the TMDB API.
Response Handling:

The TMDB API responds with the movie details, which the Flask application processes and sends back to the user through the Load Balancer.

User Experience
Accessing the Application:

The user accesses the application via a web browser.
They enter the movie title they want to search for.
Search and Display:

The application sends the search query to the backend Flask application.
The backend queries the TMDB API and retrieves movie details.
The application displays the movie details to the user.

CI/CD Pipeline
Code Push:

Developer pushes code to the GitHub repository.
GitHub Actions triggers the CI/CD pipeline based on branch push.
Build and Test:

Code is checked out and Docker Buildx is set up.
Docker image is built and pushed to AWS ECR.
Infrastructure Deployment:

Terraform initializes and applies infrastructure changes (EKS, ECS, IAM, VPC, etc.).
Kubernetes configuration is updated, and the application is deployed.
Monitoring and Management:

AWS services monitor the application.
Developers can use GitHub Actions to destroy resources as needed.

Summary
The Netflix clone application leverages a range of AWS services and modern DevOps practices to provide a scalable, efficient, and reliable movie search application. The detailed architecture and CI/CD setup ensure that the application is always up-to-date and can handle user requests effectively.
