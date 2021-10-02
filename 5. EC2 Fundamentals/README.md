# Amazon EC2
- EC2 is infrastructure as a service:
  - Rent virtual machines (EC2 instances)
  - Store data on virtual drives (EBS)
  - Distribute load across machines (ELB)
  - Scale services using an auto-scaling group (ASG)

## Sizing & configuration
- Operating systems: Linux, Windows, or Mac OS
- CPU
- RAM
- Storage space:
  - Network-attached (EBS & EFS)
  - Hardware (EC2 instance store)
- Network card: speed, public IP address
- Firewall rules: <b>security group</b>
- Bootstrap script (configure at first launch): EC2 User Data

## EC2 User Data
- Bootstrap our instances using an <b>EC2 User data</b> script
- <b>Bootstrapping</b> means launching commands when a machine starts
- The script is only run once at the instance first start
- EC2 user data is used to automate boot tasks such as:
  - Install updates
  - Install software
  - Download common files from the internet
  - etc
- EC2 User Data script runs with the root user

## EC2 Instance Types
- example: m5.2xlarge
  - m: instance class
  - 5: generation (AWS improves them over time)
  - 2xlarge: size within the instance class
- General purpose:
  - Great for diversity of workloads, such as web servers or code repos
  - Balance between:
    - Compute
    - Memory
    - Networking
  - t2.micro is a general purpose EC2 instance
- Compute optimized:
  - Great for compute-intensive tasks that require high performance processors:
    - Batch processing workloads
    - Media transcoding
    - High performance web servers
    - High performance computing (HPC)
    - Machine learning
    - Dedicated gaming server
- Memory optimized:
  - Fast performance for workloads that process large data sets in memory
  - Used for:
    - High performance, relational/non-relational databases (in-memory databases)
    - Distributed web scale cache stores (elasticache etc)
    - In-memory databases optimised for BI
    - Applications performing real-time processing of big unstructured data
- Storage optimized:
  - Great for storage-intensive tasks that require high, sequential read and write access to large datasets on local storage
  - Use cases:
    - High frequency online transaction processing (OLTP) systems
    - Relational and NoSQL databases
    - Cache for in-memory databases (Redis etc)
    - Data warehousing apps
    - Distributed file systems

## Security Groups
- Security groups are the fundamental of network security in AWS
- They control how traffic is allowed into or out of our EC@ instances
- Security groups only contain <b>allow</b> rules
- Reference by IP or by security group
- Security groups act as a 'firewall' on our EC2 instances
- They regulate:
  - Access to ports
  - Authorised IP ranges - IPv4 and IPv6
  - Control of inbound network
  - Control of outbound network
- Can be attached to multiple instances
- Locked down to a region/VPC combination
- lives 'outside' the EC2 - if traffic is blocked the EC2 instance won't see it
- It's good to maintain one separate security group for SSH access
- If your application is not accessible (timeout), then it's a security group issue
- If you receive a 'connection refused' error, then it's an application error or it's not launched
- All inbound traffic is blocked by default
- All outbound traffic is authorized  by default
- Ports to know:
  - 22 = SSH - log into a linux instance
  - 21 = FTP - upload files
  - 22 = SFTP - upload files using SSH
  - 80 = HTTP - access unsecured websites
  - 443 = HTTPS - access secured websites
  - 3389 = RDP (Remote desktop protocol) - log into a windows instance
  
## EC2 Instance Purchasing Options
- On-Demand Instances: short workload, predictable pricing
- Reserved: (MINIMUM 1 year)
  - Reserved instances: long workloads
  - Convertible reserved instances: long workloads with flexible instances
  - Scheduled reserved instances: example - every Thursday between 3 and 6 pm (DEPRECATED)
- Spot Instances: short workloads, cheap, can lose instances (less reliable)
- Dedicated Hosts: book an entire physical server, control instance placement

### EC2 On Demand
- Pay for what you use:
  - Linux - billing per second, after first minute
  - All other OS - billed per hour
- Has the highest cost but no upfront payment
- No long-term commitment
- Recommended for short-term and uninterrupted workloads, where you can't predict how the application will behave

### EC2 Reserved Instances
- Up to 75% discount compared to on-demand
- Reservation period: 1 year = + discount | 3 years = +++ discount
- Purchasing options: no upfront | partial upfront = + discount | All upfront = ++ discount
- Reserve a specific instance type
- Recommended for steady-state usage applications (database etc)
- Types:
  - Convertible Reserved Instance
    - can change the EC2 instance type
    - up to 54% discount
  - Scheduled reserved instances (DEPRECATED)
    - launch within time window you reserve
    - when you require a fraction of day/week/month
    - Still commitment over 1 to 3 years

### EC2 Spot Instances
- Can get a discount of up to 90% compared to On-demand
- Instances that you can 'lose' at any point of time if your max price is less than the current spot price
- The most cost-efficient instances in AWS
- <b>Useful for workloads that are resilient to failure</b>
- Useful for:
  - Batch jobs
  - Data analysis
  - Image processing
  - Any <b>distributed</b> workloads
  - Workloads with flexible start and end time
- Not suitable for critical jobs or databases

### EC2 Dedicated Hosts
- An Amazon EC2 Dedicated Host is a physical server with EC2 instance capacity fully dedicated to your use. Dedicated Hosts can help you address **compliance requirements** and reduce costs by allowing you to use your **existing server-bound software licenses**.
- Allocated for your account for a 3-year period reservation
- More Expensive
- Useful for software that have complicated licensing models (BYOL - Bring Your Own License)
- Or for companies that have strong regulatory or compliance needs
- Gives access to underlying hardware

### EC2 Dedicated Instances
- Instances running on hardware that's dedicated to you
- May share hardware with other instances in same account
- No control over instance placement (can move hardware after Stop/Start)
- Gives access to instance, as opposed to hardware

## EC2 Spot Instance Requests
- Define **max spot price** and get the instance while **current spot price < max**
  - The hourly spot price varies based on offer and capacity
  - If the current spot price > your max, you can choose to **stop** or **terminate** your instance with a 2 minute grace period
- Other strategy: **Spot Block**
  - 'block' spot instance during a specified time frame (1 to 6 hours) without interruptions
  - In rare situations, the instance may be reclaimed
- **Cancelling a spot request does not terminate instances**. You must first cancel a Spot Request, then terminate the associated spot instances
- You can only cancel spot instance requests that are **open, active, or disabled**.

### Spot Fleets
- Spot fleets = set of spot instances + (optional) on-demand instances
- The spot fleet will try to meet the target capacity with price constraints
  - Define possible launch pools: instance type (m5.large), OS, Availability Zone
  - Can have multiple launch pools, so that the fleet can choose
  - Spot fleets stop launching instances when reaching capacity or max cost
- Strategies to allocate spot instances:
  - lowestPrice: from the pool with the lowest price (cost optimization, short workload)
  - diversified: distributed across all pools (great for availability, long workloads)
  - capacityOptimized: pool with the optimal capacity for the number of instances
