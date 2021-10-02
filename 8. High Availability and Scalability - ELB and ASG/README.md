## Scalability and High Availability
- Scalability means that an app / system can handle greater loads by adapting
- Two types:
  - vertical
  - horizontal (= elasticity)
- Scalability is linked but different to high availability

### Vertical Scalability
- Increase **size** of instance
- t2.micro -> t2.large
- Vertical scalability is very common for non-distributed systems, such as a database
- RDS, ElastiCache are services that can scale vertically
- There's usually a limit to how much you can vertically scale (hardware limit)

### Horizontal Scalability
- Increase number of instances / systems for your application
- Horizontal scaling implies distributed systems
- Very common for web apps/modern applications
- Easy to horizontally scale thanks to the cloud offerings, such as Amazon EC2
- High Availability usually goes hand in hand with horizontal scaling
- High availability means running your application/system in at least 2 data centers (== Availability Zones)
- The goal is to survive a data center loss
- The high availability can be passive (for RDS Multi AZ for example)
- The high availability can be active (for horizontal scaling)

### High Availability & Scalability for EC2
- Vertical scaling: Increase instance size (= scale up / down)
- Horizontal scaling: Increase number of instances (= scale out / in)
  - Auto Scaling Group
  - Load Balancer
- High Availability: Run instances for the same app across multi AZ
  - Auto Scaling Group multi AZ
  - Load Balancer multi AZ

## Elastic Load Balancing (ELB)
- Load Balances are servers that forward traffic to multiple servers (e.g. EC2 instances) downstream
- Spread load across multiple downstream instances
- Expose a single point of access (DNS) to your application
- Seamlessly handle failures of downstream instances
- Do regular health checks to your instances
- Provide SSL termination (HTTPS) for your websites
- Enforce stickiness with cookies
- High availability across zones
- Separate public traffic from private traffic

### Why use an ELB?
- ELB is a **managed load balancer**
  - AWS guarantees that it will be working
  - AWS takes care of upgrades, maintenance, high availability
  - AWS provides only a few config knobs
- It costs less to setup your own load balancer, but it will be a lot more effort on your end
- It is integrated with many AWS offerings/services
  - EC2, EC2 Auto Scaling Groups, ECS
  - AWS Cert Manager (ACM), CloudWatch
  - Route53, AWS WAF, AWS Global Accelerator

### Health Checks
- Health Checks ae crucial for load balancers
- They enable the load balancer to know if instances it forwards traffic to are available to reply to requests
- The health check is done on a port and a route (/health is common)
- If the response is not 200 (OK), then the instance is unhealthy

### Types of load balancer on AWS
- **4 kinds of managed Load Balancers**
- Classic Load Balancer (v1 - old gen, DEPRECATED)
- Application Load Balancer (v2 - new gen) - ALB
  - HTTP, HTTPS, WebSocket
- Network Load Balancer (v2 - new gen) - NLB
  - TCP, TLS(secure TCP), UDP
- Gateway Load Balancer - GWLB
  - Operates at layer 3 (network layer) - IP Protocol
- Some load balancers can be setup as **internal** (private) or **external** (public) ELBs

## Classic Load Balancers
- Supports TCP (Layer 4), HTTP & HTTPS (Layer 7)
- Health checks are TCP or HTTP based
- Fixed hostname XXX.region.elb.amazonaws.com

## Application Load Balancers (v2)
- Application load balancers are Layer 7 (HTTP)
- Load balancing to multiple HTTP applications across machines (target groups)
- Load balancing to multiple applications on the same machine (ex: containers)
- Support for HTTP/2 and WebSocket
- Support redirects (from HTTP to HTTPS for example)
- Routing tables to different target groups:
  - Routing based on path in URL (example.com/**users** and example.com/**posts**)
  - Routing based on hostname in URL (**one.example.com** and **other.example.com**)
  - Routing based on Query String, Headers (example.com/users?**id=123&order=false**)
- ALBs are a great fit for micro-services and container based application (example: Docker and Amazon ECS)
- Has a port mapping feature to redirect to a dynamic port in ECS
- In comparison, we'd need multiple Classic Load Balancer per application

### ALB Target Groups
- EC2 instances (can be managed by an Auto Scaling Group) - HTTP
- ECS tasks (managed by ECS itself) - HTTP
- Lambda functions - HTTP request is translated into a JSON event
- IP Addresses - must be private IPs
- ALB can route to multiple target groups
- Health checks are at the target group level

### ALB Good to know
- Fixed hostname
- Application servers don't see the IP of the client directly
  - The true IP of the client is inserted into the header X-Forwarded-For
  - We can also get Port (X-Forwarded-Port) and proto (X-Forwarded-Proto)

## Network Load Balancer (v2)
- Network load balancers (Layer 4) allow to:
  - Forward TCP and UDP traffic to your instances
  - Handle millions of requests per second
  - Less latency ~100 ms (vs 400ms for ALB)
- NLB has **one static IP per AZ**, and supports assigning Elastic IP (helpful for whitelisting specific IP)
- NLB are used for extreme performance, TCP or UDP traffic
- Not included in AWS free tier

## Sticky Sessions (Session Affinity)
- It is possible to implement stickiness so that the same client is always redirected to the same instance behind a load balancer
- This works for Classic Load Balancer and Application Load Balancer
- The "Cookie" used for stickiness has an expiration date you control
- Use case: Make sure the user doesn't lose his session data
- Enabling stickiness may bring imbalance to the load over the backend EC2 instances

### Cookie Names
- Application-based cookies
  - Custom cookie
    - Generated by the target (application itself)
    - Can include any custom attributes required by the application
    - Cookie name must be specified individually for each target group
    - Don't use AWSALB, AWSALBAPP, or AWSALBTG (reserved for use by the ELB)
  - Application cookie
    - Generated by the load balancer
    - Cookie name is AWSALBAPP
- Duration-based Cookies
  - Cookie generated by the load balancer
  - Cookie name is AWSALB for ALB, AWSELB for CLB

## Cross Zone Load Balancing
- With cross zone load balancing: Each load balancer instance distributes evenly across all registered instances in all AZ
- Without cross zone load balancing: Requests are distributes in the instances of the node of the Elastic Load Balancer
- ALB
  - Always on (can't be disabled)
  - No charges for inter AZ data
- Network Load Balancer
  - Disabled by default
  - You pay charges for inter AZ data if enabled
- Classic Load Balancer
  - Through console -> enabled by default
  - Through CLI/API -> disabled by default
  - No charges for inter AZ data if enabled

## SSL Certificates
