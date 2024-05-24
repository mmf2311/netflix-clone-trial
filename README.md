# netflix-clone-trial

Updated Network Architecture Description
Frontend

Users: Access the application via web or mobile devices.
Content Delivery Network (CDN): AWS CloudFront to distribute content with low latency.
Static Website Hosting: S3 buckets for hosting static assets like HTML, CSS, and JavaScript.
Backend Services

API Gateway: Acts as the entry point for all client requests.
Lambda Functions: Stateless computation to handle API requests, process data, and communicate with other services.
ECS/EKS (Docker Containers/Kubernetes): For running containerized microservices that handle business logic, user management, and content recommendations.
EC2 Instances: For workloads that require dedicated servers, such as encoding/decoding videos.
TMDB API: External service providing movie data.
Databases

RDS (PostgreSQL/MySQL): For relational data like user information and metadata.
DynamoDB: For NoSQL data storage like user preferences, watch history, and session data.
ElastiCache (Redis/Memcached): For caching frequently accessed data to improve performance.
Storage

S3: For storing video content, user-uploaded images, and other static resources.
EFS (Elastic File System): For file storage that needs to be shared across multiple instances.
Security

AWS Secrets Manager: For managing sensitive information like API keys and database credentials.
IAM (Identity and Access Management): For managing user permissions and roles.
Cognito: For user authentication and authorization.
Messaging & Notifications

SNS (Simple Notification Service): For sending notifications.
SQS (Simple Queue Service): For managing task queues and asynchronous processing.
Monitoring & Logging

CloudWatch: For monitoring AWS resources and logging.
ElasticSearch Service & Kibana: For centralized logging and analytics.