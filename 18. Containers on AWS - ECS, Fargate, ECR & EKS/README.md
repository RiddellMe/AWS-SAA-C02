## Docker
- Docker is a software development platform to deploy app
- Apps are packaged in containers that can be run on any OS
- Apps run the same, regardless of where they're run:
  - Any machine
  - No compatibility issues
  - Predictable behaviour
  - Less work
  - Easier to maintain and deploy
  - Works with any language, any OS, any technology
- Where are Docker images stored?
  - Docker images are stored in Docker Repositories:
    - Docker Hub:
      - Find base images for many technologies or OS:
        - Ubuntu
        - MySQL
        - NodeJS
        - Java
    - Private Repositories:
      - Amazon ECR (Elastic Container Registry)
    - Public Repositories:
      - Amazon ECR Public
- Docker vs Virtual Machine
  - Docker is 'sort of' a virtualization technology, but not exactly
  - Resources are shared with the host -> many containers on one server
- Docker Container Management
- To manage containers, we need a container management platform
- Three choices:
  - ECS: Amazon's own container platform
  - Fargate: Amazon's own Serverless container platform
  - EKS: Amazon's managed Kubernetes (open source)

## ECS
- ECS = Elastic Container Service
- Launch Docker containers on AWS
- You must provision and maintain the infrastructure (the EC2 instances)
- AWS takes care of starting/stopping containers
- Has integrations with the Application Load Balancer

## Fargate
- Launch docker containers on AWS
- You do not provision the infrastructure (no EC2 instances to manage) - simpler
- Serverless offering (because we don't directly manage any servers)
- AWS just runs containers for you based on the CPU/RAM you need 

### IAM Roles for ECS Tasks
- EC2 Instance Profile:
  - Used by the **ECS Agent**
  - Make API calls to ECS service
  - Send container logs to CloudWatch Logs
  - Pull Docker image from ECR
  - Reference sensitive data in Secrets Manager or SSM Parameter Store
- ECS Task Role:
  - Allow each task to have a specific role
  - Use different roles for the different ECS Services you run
  - Task Role is defined in the **task definition**
  - Best practice: One task role for one task

### ECS Data Volumes - EFS File Systems
- EC2 + EFS NFS
- Works for both EC2 Tasks and Fargate tasks
- Ability to mount EFS volumes onto tasks
- Tasks launched in any AZ will be able to share the same data in the EFS volume
- Fargate + EFS = serverless + data storage without managing servers
- Use case: persistent multi-AZ shared storage for your containers

## Load Balancing for EC2 Launch Type
- We get a dynamic port mapping
- The ALB supports finding the right port on your EC2 instances
- **You must allow on the EC2 instance's security group any port from the ALB security group**

## Load Balancing for Fargate
- Each task has a **unique IP**
- but due to having an ENI, task has a fixed port
- You  must allow on the ENI's security group **the  task port** from the ALB security group

## ECS Scaling - Service CPU Usage Example
- Can scale number if tasks inside a service
- Can scale backing EC2 instances (if not using Fargate)

## ECS Rolling Updates
- When updating from v1 to v2, we can control how many tasks can be started and stopped, and in which order
- Adjust Minimum Healthy Percent (if it's at 50%, we can terminate 50% of the tasks whilst updating)
- Adjust Maximum Percent (if it's at 200%, we can launch 100% additional tasks to the normal capacity whilst updating)
- The above can be used in harmony to create rollout strategies

## ECR - Elastic Container Registry
- Store, manage, and deploy containers on AWS, pay for what you use
- Fully integrated with ECS & IAM for security, backed by Amazon S3
- Supports image vulnerability scanning, version, tag, image lifecycle

## Amazon EKS
- Amazon EKS = Amazon Elastic **Kubernetes** Service
- It is a way to launch managed Kubernetes clusters on AWS
- Kubernetes is an open-source system for automatic deployment, scaling, and management of containerized (usually Docker) applications
- It's an alternative to ECS, similar goal but different API
- EKS supports EC2 if you want to deploy worker nodes or Fargate to deploy serverless containers
- Use case: if your company is already using Kubernetes on-premises or in another cloud, and wants to migrate to AWS using Kubernetes
- Kubernetes is cloud-agnostic (can be used in any cloud - Azure, GCP etc)


