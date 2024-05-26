# Network Architecture

The architecture consists of the following components:

- **Users**: End users interact with the application through a web interface.
- **Route 53**: AWS Route 53 is used for DNS management, directing user traffic to the appropriate endpoints.
- **API Gateway**: AWS API Gateway handles the routing and exposure of RESTful APIs created by AWS Lambda functions.
- **Lambda**: AWS Lambda functions execute the backend logic in a serverless environment, handling requests and interacting with other AWS services.
- **DynamoDB**: AWS DynamoDB is a NoSQL database used to store application data, such as user profiles and movie details.
- **SQS**: AWS Simple Queue Service (SQS) is used for decoupling microservices and managing message queues for asynchronous processing.
- **SNS**: AWS Simple Notification Service (SNS) is used to send notifications and messages to users or other systems.
- **TMDB API**: An external API used to fetch movie data, including details, search results, and other relevant information. It is integrated into the backend application using the `utils.py` module.
- **Docker**: Docker is used to containerize the application, ensuring portability and consistency across different environments.
- **ECR**: AWS Elastic Container Registry (ECR) is used to store and manage Docker images.
- **ECS**: AWS Elastic Container Service (ECS) is used to run containerized applications. It works with EC2 to provide scalable compute capacity.
- **EC2**: AWS EC2 instances provide the underlying compute capacity for running the ECS cluster and other resources.
- **Kubernetes**: Kubernetes is used for container orchestration, managing the deployment, scaling, and operations of containerized applications.
- **Terraform**: Terraform is used for managing infrastructure as code, automating the setup and configuration of all the necessary AWS resources.

### Detailed Architecture Diagram

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
                        |
                        |
                  +-----+------+
                  |  TMDB API  |
                  +------------+
                        |
                        |
                  +-----+------+
                  |  Docker    |
                  +------------+
                        |
                        |
                  +-----+------+
                  |  ECR       |
                  +------------+
                        |
                        |
                  +-----+------+
                  |  ECS       |
                  +------------+
                        |
                        |
                  +-----+------+
                  |  EC2       |
                  +------------+
                        |
                        |
                  +-----+------+
                  |  Kubernetes|
                  +------------+
                        |
                        |
                  +-----+------+
                  |  Terraform |
                  +------------+
