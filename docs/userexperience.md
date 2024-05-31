# User Experience Testing Guide for Backend Application

This document provides a step-by-step guide to test the backend application as an end user using a web browser, Postman, or any HTTP client.

## Deployment

Ensure your backend application is deployed and running. You should have a load balancer or a public IP address to access the application.

### Get the Load Balancer URL

Once your application is deployed on AWS, retrieve the URL of the load balancer. This is the public endpoint where your API is accessible.

1. Run the following command to get the load balancer URL:
    ```bash
    kubectl get svc netflix-clone-service
    ```
   
    The output should look something like this:
    ```
    NAME                    TYPE           CLUSTER-IP      EXTERNAL-IP        PORT(S)        AGE
    netflix-clone-service   LoadBalancer   172.20.41.228   a1b2c3d4e5f6g7h8   80:32047/TCP   2m18s
    ```

2. The `EXTERNAL-IP` (e.g., `a1b2c3d4e5f6g7h8`) is the URL you will use.

## Test the API Endpoints

### Using a Web Browser

Open your web browser and enter the URL of your API endpoint. For example:
```
http://a1b2c3d4e5f6g7h8/movies?title=inception
```

You should see a JSON response with the movie data.

### Using Postman

1. Open Postman.
2. Create a new request.
3. Set the request method to `GET`.
4. Enter the URL:
    ```
    http://a1b2c3d4e5f6g7h8/movies?title=inception
    ```
5. Click `Send`.
6. View the response.

## Detailed Example

### 1. Deploy the Backend Application

Ensure your CI/CD pipeline runs successfully, and the application is deployed on AWS.

### 2. Get the Load Balancer URL

Run the following command to get the load balancer URL:
```bash
kubectl get svc netflix-clone-service
```

The output should look something like this:
```
NAME                    TYPE           CLUSTER-IP      EXTERNAL-IP        PORT(S)        AGE
netflix-clone-service   LoadBalancer   172.20.41.228   a1b2c3d4e5f6g7h8   80:32047/TCP   2m18s
```

The `EXTERNAL-IP` (e.g., `a1b2c3d4e5f6g7h8`) is the URL you will use.

### 3. Test the API Endpoints

#### Using a Web Browser

Open your web browser and enter the URL:
``http://a1b2c3d4e5f6g7h8/movies?title=inception``

You should see a JSON response with the movie data.

#### Using Postman

1. Open Postman.
2. Create a new request.
3. Set the request method to `GET`.
4. Enter the URL:
    ```
    http://a1b2c3d4e5f6g7h8/movies?title=inception
    ```
5. Click `Send`.
6. View the response.

## Common Issues and Troubleshooting

- **No External IP:**
    - If the `EXTERNAL-IP` field is `<pending>`, ensure your Kubernetes cluster has the necessary permissions to create a load balancer.

- **403 Forbidden:**
    - If you receive a `403 Forbidden` error, check your security groups and ensure that the necessary ports (e.g., 80 or 5000) are open.

- **Timeouts:**
    - If the request times out, ensure that your application is running and accessible.

## Conclusion

By following these steps, you can simulate the end-user experience of interacting with your backend application. The key is to ensure your application is accessible via a public URL and that your API endpoints return the expected data.
