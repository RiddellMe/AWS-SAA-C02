## AWS Snow Family
- Highly secure, portable devices to collect and process data at the edge, and/or migrate data in and out of AWS
- Data migration:
  - Snowcone
  - Snowball Edge
  - Snowmobile
- Edge computing:
  - Snowcone
  - Snowball Edge

## Data Migrations with AWS Snow Family
- Challenges over normal network:
  - Limited connectivity
  - Limited bandwidth
  - High network cost
  - Shared bandwidth (can't maximize the line)
  - Connection stability
- AWS Snow Family: offline devices to perform data migrations
- If it takes more than a week to transfer over the network, use Snowball devices

### Snowball Edge (for data transfers)
- Physical data transport solution: move TBs or PBs of data in or out of AWS
- Alternative to moving data over the network (and paying network fees)
- Pay per data transfer job
- Provide block storage and Amazon S3-compatible object storage
- **Snowball Edge Storage Optimized**
  - 80TB of HDD capacity for block volume and S3 compatible object storage
- **Snowball Edge Compute Optimized**
  - 42TB of HDD capacity for block volume and S3 compatible object storage
- Use cases: large data cloud migrations, DC decommission, disaster recovery

### AWS Snowcone
- Small, portable computing, anywhere, rugged and secure, withstands harsh environments
- Light (2.1kg)
- Device used for edge computing, storage, and data transfer
- 8 TBs of usable storage
- Use Snowcone where Snowball does not fit (space-constrained environment)
- Must provide your own battery/cables
- Can be sent back to AWS offline, or connect it to internet and use AWS DataSync to send data

### AWS Snowmobile
- It is an actual truck
- Transfer exabytes of data (1 EB = 1000PB = 1000000TBs)
- Each Snowmobile has 100PB of capacity (use multiple in parallel)
- High security: temperature controlled, GPS, 24/7 video surveillance 
- Better than Snowball if you transfer more than 10 PB

###Snow Family - Usage Process
1. Request Snowball devices from the AWS console for delivery
2. Install the snowball client/AWS OpsHub on your servers
3. Connect the snowball to your servers and copy files using the client
4. Ship back the device when you're done (goes to the right AWS facility)
5. Data will be loaded into an S3 bucket
6. Snowball is completely wiped

### What is Edge Computing?
- Process data while it's being created on **an edge location**
  - Edge locations: A truck on the road, a ship on the sea, a mining station underground...
- These locations may have
  - Limited/no internet access
  - Limited/no easy access to computing power
- We setup a Snowball Edge/Snowcone device to do edge computing
- Use cases of Edge Computing:
  - Preprocess data
  - Machine learning at the edge
  - Transcoding media streams
- Eventually (if need be) we can ship back the device to AWS (for transferring data for example)
- Snowcone (smaller)
  - 2 CPUs, 4 GB of memory, wired or wireless access
  - USB-C power using a cord or the optional battery
- Snowball Edge - Compute Optimized
  - 52 vCPUs, 208 GiB of RAM
  - Optional GPU (useful for video processing or machine learning)
  - 42 TB usable storage
- Snowball Edge - Storage Optimized
  - Up to 40 vCPUs, 80 GiB of RAM
  - Object storage clustering available
- All: Can run EC2 Instances and AWS Lambda functions (using AWS IoT Greengrass)
- Long-term deployment options: 1 and 3 years discounted pricing

### AWS OpsHub
- Historically, to use Snow Family devices, you needed a CLI
- Today, you can use AWS OpsHub (software you install on your computer) to manage your Snow Family Device
  - Unlocking and configuring single or clustered devices
  - Transferring files
  - Launching and managing instances running on Snow Family Devices
  - Monitor device metrics (storage capacity, active instances on your device)
  - Launch compatible AWS services on your devices (ex: Amazon EC2 instances, AWS DataSync, Network FIle System (NFS))

## Snowball into Glacier
- Snowball cannot import to Glacier directly
- You must use Amazon S3 first, in combination with an S3 lifecycle policy

## Hybrid Cloud for Storage
- AWS is pushing for 'hybrid cloud'
  - Part of your infrastructure is on the cloud
  - Part of your infrastructure is on-premises
- This can be due to
  - Long cloud migrations
  - Security requirements
  - Compliance requirements
  - IT strategy
- S3 is a proprietary storage technology (unlike EFS/NFS), so how do you expose the S3 data on-premises?
- AWS Storage Gateway is the answer

### AWS Storage Gateway
- Bridge between on-premises data and cloud data in S3
- Use cases: disaster recovery, backup and restore, tiered storage
- 3 types of Storage Gateway:
  - File Gateway
  - Volume Gateway
  - Tape Gateway

### File Gateway
- Configured S3 buckets are accessible using the NFS and SMB protocol
- Supports S3 standard, S3 IA, S3 One Zone IA
- Bucket access using IAM roles for each File Gateway
- Most recently used data is cached in the file gateway
- Can be mounted on many servers
- Integrated with Active Directory (AD) for user authentication

### Volume Gateway
- Block storage using iSCSI protocol backed by S3
- Backed by EBS snapshots which can help restore on-premises volumes
- **Cached volumes:** low latency access to most recent data
- **Stored volumes:** entire dataset is on premises, scheduled backups to S3

### Tape Gateway
- Some companies have backup processes using physical tapes
- With Tape Gateway, companies use the same process but in the cloud
- Virtual Tape Library (VTL) backed by Amazon S3 and Glacier
- Back up data using existing tape-based processes (and iSCSI interface)
- Works with leading backup software vendors

### Storage Gateway - Hardware appliance
- Using Storage Gateway means you need on-premises virtualization
- Otherwise, you can use a Storage Gateway Hardware Appliance
- You can buy it on amazon.com
- Works with File Gateway, Volume Gateway, and Tape Gateway
- Has the required CPU, memory, network, and SSD cache resources
- Helpful for daily NFS backups in small data centers

## Amazon FSx for Windows (File Server)
- EFS is a shared POSIX system for Linux systems
- FSx for Windows is a fully managed Windows file system share drive
- Supports SMB protocol and Windows NTFS
- Microsoft Active Directory integration, ACLs, user quotas
- Built on SSD, scale up to 10s of GB/s, millions of IOPS, 100s PB of data
- Can be accessed from your on-premises infrastructure
- Can be configured to be Multi-AZ (high availability)
- Data is backed-up daily to S3

### Amazon FSx for Lustre
- Lustre is a type of parallel distributed file system, for large-scale computing
- The name Lustre is derived from 'Linux' and 'cluster'
- Machine learning, High Performance Computing (HPC)
- Video Processing, Financial Modelling, Electronic Design Automation
- Scales up to 100s GB/s, millions of IOPS, sub-ms latencies
- Seamless integration with S3
  - Can 'read S3' as a file system (through FSx)
  - Can write the output of the computations back to S3 (through FSx)
- Can be used from on-premises servers

### FSx File System Deployment Options
- Scratch File System
  - Temporary Storage
  - Data is not replicated (doesn't persist if file server fails)
  - High burst (6x faster, 200MBps per TiB)
  - Usage: short-term processing, optimize costs
- Persistent File System
  - Long-term Storage
  - Data is replicated within same AZ
  - Replace failed files within minutes
  - Usage: long-term processing, sensitive data

## AWS Transfer Family
- A fully-managed service for file transfers into and out of Amazon S3 or Amazon EFS using the FTP protocol
- Supported Protocols
  - AWS Transfer for FTP (File Transfer Protocol)
  - AWS Transfer for FTPS (File Transfer Protocol over SSL)
  - AWS Transfer for SFTP (Secure File Transfer Protocol)
- Managed infrastructure, Scalable, Reliable, Highly Available (multi-AZ)
- Pay per provisioned endpoint per hour + data transfers in GB
- Store and manage users' credentials within the service
- Integrate with existing authentication systems (Microsoft Active Directory, LDAP, Okta, Amazon Cognito, custom)
- Usage: sharing files, public datasets, CRM, ERP...

## Storage Comparison
- S3: Object Storage (serverless)
- Glacier: Object Archival
- EFS: Network File System for Linux instances, POSIX filesystem (shared, across AZ)
- FSx for Windows: Network File System for Windows servers (EFS for windows)
- FSx for Lustre: High Performance Computing Linux file system
- EBS volumes: Network storage for one EC2 instance at a time (single AZ)
- Instance Storage: Physical storage for your EC2 instance (high IOPS, higher than network drives)
- Storage Gateway: File Gateway, Volume Gateway (cached and stored), Tape Gateway
- Snowball/Snowmobile: to move large amount of data to the cloud, physically
- Database: for specific workloads, usually with indexing and querying
