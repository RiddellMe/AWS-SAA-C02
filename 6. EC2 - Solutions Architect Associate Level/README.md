## Placement Groups
- Control over the EC2 Instance placement strategy
- Defined using placement groups:
  - Cluster - clusters instances into a low-latency group in a single Availability Zone
  - Spread - spreads instances across underlying hardware (max 7 instances per group per AZ) - critical applications
  - Partition - spreads instances across many different partitions (which rely on different sets of racks) within an AZ. Scales to 100s of EC2 instances per group (Hadoop, Cassandra, Kafka)

### Cluster
- Same rack (same hardware), Same AZ
- Pros:
  - Great network (10Gbps bandwidth between instances as they are on the same hardware)
- Cons:
  - If the rack fails, all instances fail at the same time
- Use case:
  - Big data job that needs to complete fast
  - Application that needs extremely low latency and high network throughput

### Spread
- Spread across DIFFERENT hardware, as well as AZ
- Pros:
  - Span across AZ
  - Reduced risk of simultaneous failure
  - EC2 Instances are on different physical hardware
- Cons:
  - Limited to 7 instances per AZ per placement group
- Use case:
  - Application that needs to maximise high availability
  - Critical applications where each instance must be isolated from failure from each other

### Partition
- Instances are spread across different hardware (partitions/racks), as well as AZ
- A rack may have **multiple** instances
- Up to 7 partitions (racks) per AZ 
- Can span across multiple AZs in the same region
- Up to 100s of EC2 instances
- The instances in a partition do not share racks with the instances in other partitions
- Each partition is ISOLATED
- A partition failure can affect many EC2 but won't affect other partitions
- EC2 instances get access to the partition information as metadata
- Use cases: HDFS, HBase, Cassandra, Kafka

## Elastic Network Interfaces (ENI)
- Logical component in a VPC that represents a **virtual network card**
- The ENI can have the following attributes:
  - Primary private IPv4; one or more secondary IPv4
  - One Elastic IP (IPv4) per private IPv4
  - One public IPv4
  - One or more security groups
  - A MAC address
- You can create ENI independently and attach them on the fly (move them) on EC2 instances for failover
- Bound to a specific availability zone (AZ)

## EC2 Hibernate
- We can stop and terminate instances
  - Stop: Data on disk (EBS) is kept intact for the next start
  - Terminate: any EBS volumes (root) also set-up to be destroyed (alongside our instances) is lost. (secondary EBS are obviously kept)
- On start:
  - First start: OS boots and EC2 User Data script is run
  - Following starts: OS boots, application starts and caches are warmed up (this can take time)
- Introducing EC2 Hibernate:
  - The in-memory (RAM) state is preserved
  - The instance boots much faster! OS has not been stopped or restarted
  - the state is 'frozen'
  - Under the hood: the RAM state is written to a file in the root EBS volume
  - The root EBS volume must be encrypted
- Use cases:
  - long-running processing
  - save RAM state
  - services that take time to initialize
- Good to knows:
  - Does not support all instances
  - Instance RAM size must be less than 150GB
  - Not supported for bare metal instances (instance size)
  - AMIs: Amazon Linux 2, Linux AMI, Ubuntu... and Windows
  - Root volume: Must be EBS (and large enough to store what is in RAM), as well as encrypted. Cannot be an instance store
  - Available for on-demand and reserves instances
  - An instance cannot be hibernated for more than 60 days

## EC2 Nitro
- Underlying platform for the next generation of EC2 instances
- New virtualization technology
- Allows for better performance:
  - Better networking options (enhanced networking, HPC, IPv6)
  - Higher speed EBS (Nitro is necessary for 64,000 EBS IOPS - max 32,000 on non-Nitro)
- Better underlying security

## EC2 - Understanding vCPU
- Multiple threads can run on one CPU (multithreading)
- Each thread is represented as a virtual CPU (vCPU)
- Example: m5.2xlarge
  - 4 CPU
  - 2 threads per CPU
  - 8 vCPU in total (4*2)

### Optimizing CPU options
- EC2 instances come with a combination of RAM and vCPU
- In some cases, you may want to change vCPU options:
  - **number of CPU cores:** you can decrease it (helpful if you need high RAm and low numbers of CPU) - to decrease licensing costs
  - **number of threads per core:** disable multithreading to have 1 thread per CPU - helpful for high performance computing (HPC) workloads
- Only specified during instance launch

### Capacity reservations
- Ensure you have EC2 capacity when needed
- Manual or planned end-date for reservation
- No need for 1 or 3 year commitment
- Capacity access is immediate, you get billed as soon as it starts
- Specify:
  - The AZ in which to reserve the capacity (only one)
  - The number of instances for which to reserve capacity
  - The instance attributes, including instance type, tenancy, platform/OS
- Combine with Reserved Instances and Savings Plans to do cost saving
