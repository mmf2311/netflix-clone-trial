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


Once your application is deployed, users can access it through the public endpoint provided by the Kubernetes service. Here’s how the access flow works:

1. **Public Endpoint**:
   - When you deploy your application to Kubernetes on AWS EKS, you typically expose it using a Kubernetes service of type LoadBalancer.
   - AWS will provision an Elastic Load Balancer (ELB) and assign a public IP address or DNS name to the service.

2. **DNS and Load Balancer**:
   - The DNS name or IP address provided by the Load Balancer will serve as the public endpoint for your application.
   - Users can access the application by navigating to this DNS name or IP address in their web browser.

3. **Routing Traffic**:
   - The Load Balancer will route incoming HTTP/HTTPS traffic to the appropriate Kubernetes service.
   - The Kubernetes service will then route the traffic to the pods running your application.

### Steps for Accessing the Application

1. **Deploy the Application**:
   - Ensure your application is deployed and running on the Kubernetes cluster. This involves using the Kubernetes `deployment.yml` to define and deploy your application pods.

2. **Expose the Service**:
   - Use a Kubernetes service of type LoadBalancer to expose your application. This is typically defined in the `deployment.yml` file under the `Service` section.

3. **Retrieve the Load Balancer DNS Name**:
   - After deploying the service, retrieve the DNS name or public IP of the Load Balancer using the following command:
     ```sh
     kubectl get svc
     ```
   - Look for the `EXTERNAL-IP` column in the output, which contains the DNS name or IP address.

4. **Access the Application**:
   - Open a web browser and navigate to the DNS name or IP address obtained from the previous step.
   - This will direct the traffic through the Load Balancer to your Kubernetes service, which routes it to your application pods.

### Example Kubernetes Service Configuration

Here is an example of a Kubernetes `Service` definition that exposes your application using a Load Balancer:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: netflix-clone-service
spec:
  selector:
    app: netflix-clone
  ports:
    - protocol: TCP
      port: 80
      targetPort: 5000
  type: LoadBalancer
```

### Updated Deployment YAML

Here’s an example of how your `deployment.yml` might look:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: netflix-clone-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: netflix-clone
  template:
    metadata:
      labels:
        app: netflix-clone
    spec:
      containers:
      - name: netflix-clone
        image: <AWS_ECR_REPOSITORY_URL>:latest
        ports:
        - containerPort: 5000
        env:
        - name: TMDB_API_KEY
          valueFrom:
            secretKeyRef:
              name: tmdb-api-key
              key: api_key
---
apiVersion: v1
kind: Service
metadata:
  name: netflix-clone-service
spec:
  selector:
    app: netflix-clone
  ports:
    - protocol: TCP
      port: 80
      targetPort: 5000
  type: LoadBalancer
```

### Summary

To access your application once it is deployed:
1. Deploy the application using Kubernetes and ensure it’s running.
2. Expose the application using a Kubernetes `Service` of type `LoadBalancer`.
3. Retrieve the DNS name or public IP of the Load Balancer.
4. Open a web browser and navigate to the DNS name or public IP to access the application.

### Detailed Network Architecture Diagram (ASCII)

Here's an updated network architecture diagram showing the flow from user access to the deployed application:

```
 User
   |
   |
   V
+-----------------------------+
|    Public Internet          |
|                             |
|   +---------------------+   |
|   |  AWS Load Balancer  |   |
|   |  (DNS or IP)        |   |
|   +---------+-----------+   |
|             |               |
|             V               |
|   +---------------------+   |
|   |   Kubernetes        |   |
|   |   Service           |   |
|   |   (LoadBalancer)    |   |
|   +---------+-----------+   |
|             |               |
|             V               |
|   +---------+-----------+   |
|   |   Kubernetes        |   |
|   |   Deployment        |   |
|   |   (Pods)            |   |
|   +---------+-----------+   |
|             |               |
|             V               |
|   +---------+-----------+   |
|   |   Application       |   |
|   |   (netflix-clone)   |   |
|   +---------------------+   |
|                             |
+-----------------------------+
```

