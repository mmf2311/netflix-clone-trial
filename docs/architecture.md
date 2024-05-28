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

