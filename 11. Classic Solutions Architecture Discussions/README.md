# Solution Architecture

## Instantiating Applications Quickly
- When launching a full stack (EC2, EBS, RDS) it can take time to:
  - Install applications
  - Insert initial (or recovery) data
  - Configure everything
  - Launch the application
- We can take advantage of the cloud to speed this up
- EC2 Instances:
  - Use a **Golden AMI**: Install your application, OS dependencies etc. beforehand and launch your EC2 instance from the Golden AMI
  - **Bootstrap using User Data**: For dynamic configuration, use User Data scripts
  - Hybrid: mix Golden AMI and User Data (Elastic Beanstalk)
- RDS Databases:
  - Restore from a snapshot: the database will have schemas and data ready
- EBS Volumes:
  - Restore from a snapshot: the disk will already be formatted and have data

## Elastic Beanstalk
- Developer problems on AWS:
  - Managing infrastructure
  - Deploying code
  - Configuring all the databases, load balancers etc
  - Scaling concerns
  - Most web apps have the same architecture (ALB + ASG)
  - All the developers want is for their code to run
  - Possibly, consistently across different applications and environments
- Overview:
  - Elastic Beanstalk is a developer centric view of deploying an application on AWS
  - It uses all the component's we've seen before: EC2, ASG, ELB, RDS
  - Managed service
    - Automatically handles capacity provisioning, load balancing, scaling, application health monitoring, instance configuration
    - Just the application code is the responsibility of the developer
  - We still have full control over the configuration
  - Beanstalk is free but you pay for the underlying instances
- Components
  - Application: collection of Elastic Beanstalk components (environments, versions, configurations)
  - Application Version: an iteration of your application code
  - Environment
    - Collection of AWS resources running an application version (only one application version at a time)
    - Tiers: Web Server Environment Tier and Worker Environment Tier
    - You can create multiple environments (dev, test, prod)
