# Network Architecture

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
- **TMDB API**: Provides movie data used for searching and displaying movie details.

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
