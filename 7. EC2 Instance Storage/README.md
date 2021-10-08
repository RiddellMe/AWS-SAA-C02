## What's an EBS Volume
- An EBS (Elastic Block Store) is a **network drive** you can attach to your instances while they run
- It allows your instances to persist data, even after their termination
- **They can only be mounted to one instance at a time** (at the CCP level)
- Bound to a specific AZ
- Think of them as 'network USB sticks'
- Free tier: 30 GB of free EBS storage of type General Purpose (SSD) or Magnetic per month

## EBS Volume
- It is a **network drive**, not a physical drive
- It uses the network to communicate with the instance, which means there might be a bit of latency
- It can be detached from an EC2 instance and attached to another one quickly
- It's locked to an AZ
  - An EBS Volume in us-east-1a cannot be attached to us-east-1b
  - To move a volume across, you first need to snapshot it
- Has a provisioned capacity (size in GBs, and IOPS)
  - You get billed for all the provisioned capacity
  - You can increase the capacity of the drive over time

## EBS - Delete on Termination attribute
- Controls the EBS behaviour when an EC2 instance terminates
  - By default, the root EBS volume is deleted (attribute enabled)
  - By default, any other attached EBS volume is not deleted (attribute disabled)
- This can be controlled by the AWS console / AWS CLI
- **Use case: preserve root volume when instance is terminated**

## EBS Snapshots
- Make a backup (snapshot) of your EBS volume at a point in time
- Not necessary to detach volume to do snapshot, but recommended
- Cap copy snapshots across AZ or Region

## AMI Overview
- AMI = Amazon Machine Image
- AMI are a customization of an EC2 instance
  - You add your own software, configuration, OS, monitoring...
  - Faster boot/configuration time because all your software is pre-packaged
- AMI are built for a **specific region** (and can be copied across regions)
- You can launch EC2 instances from:
  - A public AMI: AWS provided
  - Your own AMI: you make and maintain them yourself
  - An AWS marketplace AMI: an AMI someone else made (and potentially sells)

### AMI Process (from an EC2 instance)
- Start an EC2 instance and customize it
- Stop the instance (for data integrity)
- Build an AMI - this will also create EBS snapshots
- Launch instances from other AMIs

## EC2 Instance Store
- EBS volume are **network drives** with good but "limited" performance
- If you need a high-performance hardware disk, use EC2 Instance Store
- Better I/O performance
- EC2 Instance Store lose their storage if they're stopped (ephemeral)
- Good for buffer/cache/scratch data/temporary content
- Risk of data loss if hardware fails
- Backups and Replication are your responsibility

## EBS Volume Types
- EBS Volumes come in 6 types
  - gp2/gp3 (SSD): General purpose SSD volume that balances price and performance for a wide variety of workloads
  - io1/io2 (SSD): Highest-performance SSD volume for mission-critical low-latency or high-throughput workloads
  - st1 (HDD): Low cost HDD volume designed for frequently accessed, throughput-intensive workloads
  - sc1 (HDD): Lowest cost HDD volume designed for less frequently accessed workloads
- EBS Volumes are characterized in Size | Throughput | IOPS (I/O Ops per sec)
- Only gp2/gp3 and io1/io2 can be used as boot volumes (where the root os is running)
-General purpose SSD:
  - Cost effective storage, low-latency
  - System boot volumes, virtual desktops, development and test environments
  - 1GiB - 16 TiB
  - gp3:
    - Baseline of 3000 IOPS and throughput of 125 MiB/s
    - Can increase IOPS up to 16,000 and throughput up to 1000 MiB/s independently
  - gp2:
    - Small gp2 volumes can burst IOPS to 3000
    - Size of the volume and IOPS are linked, max IOPS is 16000
    - 3 IOPS per GB, means at 5334 GB we are at the max IOPS
- Provisioned IOPS (PIOPS) SSD:
  - Critical business applications with sustained IOPS performance
  - Applications that need more than 16000 IOPS
  - Great for **database workloads** (sensitive to storage performance and consistency)
  - io1/io2 (4GiB - 16TiB):
    - Max PIOPS: 64000 for Nitro EC2 instances and 32000 for other
    - Can increase PIOPS independently of storage size
    - io2 have more durability and more IOPS per GiB (at the same price as io1)
  - io2 Block Express (4GiB - 64TiB):
    - Sub-millisecond latency
    - Max PIOS: 256000 with an IOPS:GiB ratio of 1000:1
  - Supports EBS Multi-attach
- Hard Disk Drives (HDD):
  - Cannot be a boot volume
  - 125 MiB to 16TiB
  - Throughput Optimized HDD (st1):
    - Big data, data warehouses, log processing
    - Max throughput 500MiB/s - max IOPS 500
  - Cold HDD (sc1):
    - For data that is infrequently accessed
    - Scenario where lowest cost is important
    - Max throughput 250 MiB/s - max IOPS 250

## EBS Multi-attach - io1/io2 family
- Attach the same EBS volume to multiple EC2 instances in the same AZ
- Each instance has full read and write permissions to the volume
- Use case:
  - Achieve higher application availability in clustered Linux applications (ex: Teradata)
  - Applications must manage concurrent write operations
  - Must use a file system that's cluster-aware (not XFS, EC4, etc)

## EBS Encryption
- When you create an encrypted EBS volume, you get the following:
  - Data at rest is encrypted inside the volume
  - All the data in flight moving between the instance and the volume is encrypted
  - All snapshots are encrypted
  - All volumes created from the snapshot are encrypted
- Encryption and decryption are handled transparently (you have nothing to do)
- Encryption has a minimal impact on latency
- EBS Encryption leverages keys from KMS (AES-256)
- Copying an unencrypted snapshot allows encryption
- Snapshots of encrypted volumes are encrypted
- Encryption: encrypt an unencrypted EBS volume
  - Create an EBS snapshot of the volume
  - Encrypt the EBS snapshot (using the copy)
  - Create new EBS volume from the snapshot (the volume will also be encrypted)
  - Now you can attach the encrypted volume to the original instance

## EFS - Elastic File System
- Managed NFS (network file system) that can be mounted on many EC2
- EFS works with EC2 instances in multi-AZ
- Highly available, scalable, expensive (3x gp2), pay per use
- Use cases: content management, web serving, data sharing, Wordpress
- Uses NFSv4.1 protocol
- Uses security group to control access to EFS
- **Compatible with Linux based AMI (not Windows)**
- Encryption at rest using KMS
- POSIX file system (~Linux) that has a standard file API
- File system scales automatically, pay-per-use, no capacity planning

### EFS - Performance & Storage Classes
- EFS Scale
  - 1000s of concurrent NFS clients, 10 GB+/s throughput
  - Grow to petabyte-scale network file system, automatically
- Performance mode (set at EFS creation time)
  - General purpose (default): latency-sensitive use cases (web server, CMS, etc...)
  - Max I/O - higher latency, throughput, highly parallel (big data, media processing)
- Throughput Mode
  - Bursting (1TB = 50MiB/s + burst of up to 100MiB/s)
  - Provisioned: set your throughput regardless of storage size, ex: 1 GiB/s for 1 TB storage
- Storage Tiers (lifecycle management feature - move file after N days)
  - Standard: for frequently accessed files
  - Infrequent access (EFS-IA): cost to retrieve files, lower price to store

## EBS vs EFS
- EBS volumes
  - can only be attached to one instance at a time
  - are locked at the AZ level
  - gp2: IO increases if disk size increases
  - io1: can increase IO independently
- To migrate an EBS volume across AZ
  - take a snapshot
  - restore the snapshot to another AZ
  - EBS backups use IO and you shouldn't run them while your application is handling a lot of traffic
- Root EBS volumes of instances get terminated by default if the EC2 instance gets terminated (you can disable that)
- EFS volumes
  - Mounting 100s of instances across AZ
  - EFS share website files (WordPress)
  - Only for Linux instances (POSIX)
  - EFS has a higher price point than EBS
  - Can leverage EFS-IA for cost savings (infrequent access)
  - EFS is billed for use
