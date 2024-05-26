# Setup Instructions

## Prerequisites
- Docker
- Terraform
- AWS CLI
- Kubernetes CLI (kubectl)
- GitHub account with access to repository

## Setup Steps
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
   docker tag netflix-clone:latest <AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com/group-3-ecr-netflix-clone:latest
   docker push <AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com/group-3-ecr-netflix-clone:latest
   ```

4. **Deploy Infrastructure using Terraform**:
   ```bash
   cd terraform
   terraform init
   terraform apply -auto-approve
   ```

5. **Create Kubernetes Secret for TMDB API Key**:
   ```bash
   kubectl create secret generic tmdb-api-key-secret --from-literal=TMDB_API_KEY=your_tmdb_api_key
   ```

6. **Deploy to Kubernetes**:
   ```bash
   kubectl apply -f ./kubernetes