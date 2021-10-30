## Disaster Recovery
- Any event that has a negative impact on a company's business continuity or finances is a disaster
- Disaster recovery (DR) is about preparing for and recovering from a disaster
- What kind of disaster recovery?
  - On-premises -> On-premises: traditional DR, very expensive
  - On premises -> AWS Cloud: hybrid recovery
  - AWS Cloud Region A -> AWS Cloud Region B
- Need to define two terms:
  - RPO : Recovery Point Objective
  - RTO: Recovery Time Objective

### RPO and RTO
- RPO: Data loss after a disaster - How often we run backups (how back in time can we recover)
- RTO: Downtime after a disaster

### Disaster Recovery Strategies
- Backup and Restore
- Pilot Light
- Warm Standby
- Hot Site/Multi Site Approach

### Pilot Light
- A small version of the app is always running in the cloud
- Useful for the critical core (pilot light)
- Very similar to Backup and Restore
- Faster than Backup and Restore as critical systems are already up

### Warm Standby
- Full system is up and running, but at a minimum size
- Upon disaster, we can scale to production load

### Hot Site/Multi Site Approach
- Very low RTO (minutes or seconds) - very expensive
- Full production scale is running AWS and on premises
- (active-active)

### Disaster Recovery Tips
- Backup
  - EBS Snapshots, RDS automated backups/snapshots etc
  - Regular pushes to S3/S3 IA/Glacier, Lifecycle policy, Cross Region Replication
  - From On-premises: Snowball or Storage Gateway
- High Availability
  - Use Route53 to migrate DNS over from region to region
  - RDS Multi-AZ, ElastiCache Multi-AZ, EFS, S3
  - Site to Site VPN as a recovery from Direct Connect
- Replication
  - RDS Replication (Cross Region), AWS Aurora + Global Databases
  - Database replication from on-premises to RDS
  - Storage Gateway
- Automation
  - CloudFormation/Elastic Beanstalk to re-create a whole new environment
  - Recover/Reboot EC2 instances with CloudWatch if alarms fail
  - AWS Lambda functions for customized automations
- Chaos
  - Netflix has a "simian-army" randomly terminating EC2

## DMS - Database Migration Service
- Quickly and securely migrate databases to AWS, resilient, self-healing
- The source database remains available during the migration
- Supports:
  - Homogeneous migrations, such as Oracle to Oracle
  - Heterogeneous migrations: SQL Server to Aurora
- Continuous Data Replication using CDC (Change Data Capture)
- You must create an EC2 instance to perform the replication tasks

### DMS Sources and Targets
- Sources:
  - On-premises and EC2 instances databases: Oracle, MS SQL Server, MySQL, MariaDB, PostgreSQL, MongoDB, SAP, DB2
  - Azure: Azure SQL Database
  - Amazon RDS: all, including Aurora
  - Amazon S3
- Targets:
  - On-premises and EC2 instances databases: Oracle, MS SQL Server, MySQL, MariaDB, PostgreSQL, MongoDB, SAP
  - Amazon RDS
  - Amazon Redshift
  - Amazon DynamoDB
  - Amazon S3
  - ElasticSearch Service
  - Kinesis Data Streams
  - DocumentDB

### AWS Schema Conversion Tool (SCT)
- Convert your Database's schema from one engine to another
- Ex: OLTP (SQL Server or Oracle) to MySQL, PostgreSQL, Aurora
- Ex: OLAP (Teradata or Oracle) to Amazon Redshift
- You do not need to use SCT if you are migrating the same DB engine (PostgreSQL to PostgreSQL etc)

## On-Premises strategy with AWS
- Ability to download Amazon Linux 2 AMI as a VM (.iso format)
  - VMWare, KVM, VirtualBox (Oracle VM), Microsoft Hyper-V
- VM Import/Export
  - Migrate existing applications into EC2
  - Create a DR repository strategy for your on-premises VMs
  - Can export back the VMs from EC2 to on-premises
- AWS Application Discovery Service
  - Gather information about your on-premises servers to plan a migration
  - Server utilization and dependency mappings
  - Track with AWS Migration Hub
- AWS Database Migration Service (DMS)
  - Replicate on-premises -> AWS, AWS -> AWS, AWS -> On-premises
  - Works with various database technologies
- AWS Server Migration Service (SMS)
  - Incremental replication of on-premises live servers to AWS

## AWS DataSync
- Move large amount of data from on-premises to AWS
- Can synchronize to: Amazon S3 (any storage classes - including Glacier), Amazon EFS, AMazon FSx for Windows
- Move data from your NAS or file system via NFS or SMB
- Replication tasks can be scheduled hourly, daily, weekly
- Leverage the DataSync agent to connect to your systems
- Can setup a bandwidth limit

## AWS Backup
- Fully managed service
- Centrally manage and automate backups across AWS services
- No need to create custom scripts and manual processes
- Supported services:
  - Amazon FSx
  - Amazon EFS
  - Amazon DynamoDB
  - Amazon EC2
  - Amazon EBS
  - Amazon RDS (All DB engines)
  - Amazon Aurora
  - AWS Storage Gateway (Volume Gateway)
- Supports cross-region backups
- Supports cross-account backups
- Supports PITR for supported services (Point in Time Recovery)
- On-Demand and Scheduled backups
- Tag-based backup policies
- You create backup policies known as Backup Plans
  - Backup frequency (every 12 hours, daily ,weekly, monthly, cron expression)
  - Backup window
  - Transition to Cold Storage (never, days, weeks, months, years)
  - Retention Period (always, days, weeks, months, years)
