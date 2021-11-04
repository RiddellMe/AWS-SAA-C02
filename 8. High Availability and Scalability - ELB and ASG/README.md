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

## Gateway Load Balancer
- Deploy, scale, and manage a fleet of 3rd party network virtual appliances in AWS
- Example: Firewalls, Intrusion Detection and Prevention Systems, Deep Packet Inspection Systems, payload manipulation...
- Operates at Layer 3 (Network Layer) - IP Packets
- Combines the following functions:
  - Transparent Network Gateway - single entry/exit for all traffic
  - Load Balancer - distributes traffic to your virtual appliances
- Uses the GENEVE protocol on port 6081
- Target Groups
  - EC2 instances
  - IP Addresses - must be private IPs

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

## SSL/TLS - Basics
- An SSL Certificate allows traffic between your clients and your load balancer to be encrypted in transit (in-flight encryption)
- SSL refers to Secure Socket Layer, usd to encrypt connections
- TLS refers to Transport Layer Security, which is a newer version
- Nowadays, TLS certs are mainly used, but people still refer to it as SSL
- Public SSL certs are issues by Certificate Authorities (CA)
  - Comodo, Symantec, GoDaddy, GlobalSign, Digicert, Letsencrypt, etc...
- SSL certs have an expiration date (you set) and must be renewed
- The load balancer uses an X.509 certificate (SSL/TLS server certificate)
- You can manage certificates using ACM (AWS certificate manager)
- You can upload your own certificates to ACM alternatively
- HTTPS listener:
  - You must specify a default certificate
  - You can add an optional list of certs to support multiple domains
  - Clients can use SNI (Server Name Indication) to specify the hostname they reach
  - Ability to specify a security policy to support older versions of SSL/TLS (legacy clients)

### SSL - Server Name Indication
- SNI solves the problem of multiple SSL certificates onto one web server (to serve multiple websites)
- It's a "newer" protocol, and requires the client to indicate the hostname of the target server in the initial SSL handshake
- The server will then find the correct certificate, or return the default one
- Note: Only works for ALB and NL (newer gen) or CloudFront
- Does nto work for CLB (old gen)

### SSL Certs
- Classic Load Balancer (v1)
  - Support only one SSL certificate
  - Must use multiple CLB for multiple hostname with multiple SSL certificates
- Application Load Balancer (v2)
  - Supports multiple listeners with multiple SSL certificates
  - Uses SNI to make it work
- Network Load Balancer (v2)
  - Supports multiple listeners with multiple SSL certificates
  - Uses SNI to make it work

## Connection Draining
- Feature naming
  - Connection Draining - for CLB
  - Deregistration Delay - for ALB and NLB
- Time to complete "in-flight requests" while instance is de-registering or unhealthy
- Stops sending new requests to the EC2 instance which is de-registering
- Between 1 to 3600 seconds (default: 300 seconds)
- Can be disabled (set value to 0)
- Set to a low value if your requests are short

## Auto Scaling Group
- In real-life, the load on your websites and application can change
- In the cloud, you can create and get rid of servers very quickly
- The goal of an Auto Scaling Group (ASG) is to:
  - Scale out (add EC2 instances) to match an increased load
  - Scale in (remove EC2 instances) to match a decreased load
  - Ensure we have a minimum and maximum number of machines running
  - Automatically Register new instances to a load balancer
- ASG have the following attributes
  - A launch configuration
    - AMI + Instance Type
    - EC2 User Data
    - EBS Volumes
    - Security Groups
    - SSH Key Pair
  - Min size / Max size / Initial capacity
  - Network + Subnets information
  - Load Balancer Information
  - Scaling Policies
- Auto Scaling Alarms
  - It is possible to scale an ASG based on CloudWatch alarms
  - An alarm monitors a metric (such as Average CPU)
  - **Metrics are computed for the overall ASG instances**
  - Based on the alarm:
    - We can create scale-out policies
    - We can create scale-in policies
  - Auto Scaling New Rules
    - It is possible to define "better" auto scaling rules that are directly managed by EC2
      - Target Average CPU Usage
      - Number of requests on the ELB per instance
      - Average Network In
      - Average Network Out
    - These rules are easier to set up and can make more sense
  - Auto Scaling Custom Metric
    - We can auto scale based on a custom metric (ex: Number of connected users)
    1. Send custom metric from application on EC2 to CloudWatch (PutMetric API)
    2. Create CloudWatch alarm to react to low/high values
    3. Use the CloudWatch alarm as the scaling policy for ASG
  - ASG Brain Dump
    - Scaling policies can be on CPU, Network... and can even be on custom metrics or based on a schedule (if you know your visitors patterns)
    - ASGs use Launch configurations or Launch Templates (newer)
    - To update an ASG, you must provide a new launch configuration/launch template
    - IAM roles attached to an ASG will get assigned to EC2 instances
    - ASG are free. You pay for the underlying resources being launched
    - Having instances under an ASG means that if they get terminated for whatever reason, the ASG will automatically **create new ones as a replacement**. Extra Safety!
    - ASG can terminate instances marked as unhealthy by an LB (and hence replace them)

## AUto Scaling Groups - Dynamic Scaling Policies
- Target Tracking Scaling
  - Most simple and easy to set-up
  - Ex: I want the average ASG CPU to stay at around 40%
- Simple / Step Scaling
  - When a CloudWatch alarm is triggered (ex: CPU > 70%) then add 2 units
  - When a CloudWatch alarm is triggered( ex: CPU < 30%) then remove 1
- Scheduled Actions
  - Anticipate scaling based on known usage patterns
  - Ex: Increase the min capacity at 10 at 5pm on Fridays
- Predictive Scaling
  - Continuously forecast load and scheduling scaling ahead
- Good metrics to scale on
  - CPUUtilization: Average CPU utilization across your instances
    - RequestCountPerTarget: To make sure the number of requests per EC2 instances is stable
    - Average network in / out (if your application is network bound)
    - Any custom metric (that you push using CloudWatch)
- Scaling Cooldowns
  - After a scaling activity happens, you are in the cooldown period (default 300 seconds)
  - During the cooldown period, the ASG will not launch of terminate additional instances (to allow for metrics to stabilize)
  - Advice: Use a ready-to-use AMI to reduce configuration time in order to be serving requests faster and reduce the cooldown period

## ASG for Solutions Architects
- ASG Default Termination Policy(simplified):
  - Find the AZ which has the most number of instances
  - If there are multiple instances in the AZ to choose from, delete the one with the oldest launch configuration
- ASG tries to balance the number of instances across AZ by default
- Lifecycle Hooks:
  - By default, as soon as an instance is launched in an ASG, it's in service
  - You have the ability to perform extra steps before the instance goes in service (pending state)
  - You have the ability to perform some actions before the instance is terminated (terminating state)
- Launch template vs Launch configuration
  - Both:
    - ID of the Amazon Machine Image (AMI), the instance type, a key pair, security groups, and the other parameters that you use to launch EC2 instances (tags, EC2 user-data)
    - Launch Configuration (legacy):
      - Must be re-created every time
    - Launch Template (newer):
      - Can have multiple versions
      - Create parameters subsets (partial configuration for re-use and inheritance)
      - Provision using both On-Demand and Spot instances (or a mix)
      - Can use T2 unlimited burst feature
      - **Recommended by AWS going forward**
