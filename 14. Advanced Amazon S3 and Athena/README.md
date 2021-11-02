## S3 MFA-Delete
- MFA (multi factor authentication) forces users to generate a code on a device (usually a mobile phone or hardware) before doing important operations on S3
- To use MFA-Delete, enable Versioning on the S3 bucket
- You will need MFA to:
  - Permanently delete an object version
  - suspend versioning on the bucket
- You won't need MFA for
  - enabling versioning
  - listing deleted versions
- Only the bucket owner (root account) can enable/disable MFA-Delete
- MFA-Delete currently can only be enabled using the CLI

## S3 Default Encryption vs Bucket Policies
- One way to 'force encryption' is to use a bucket policy and refuse any API call to PUT an S3 object without encryption headers:
- Another way is to use the 'default encryption' option in S3
- Note: Bucket policies are evaluated before 'default encryption'

## S3 Access Logs
- For audit purposes, you may want to log all access to S3 buckets
- Any request made to S3, from any account, authorized or denied, will be logged into another S3 bucket
- That data can be analyzed using data analysis tools...
- Or Amazon Athena!
- Warning:
  - Do not set your logging bucket to be the monitored bucket
  - It will create a recursive logging loop

## S3 Replication (CRR & SRR)
- Must enable versioning in source and destination buckets
- Cross Region Replication (CRR)
- Same Region Replication (SRR)
- Buckets can be in different accounts
- Copying is async
- Must give proper IAM permissions to S3
- CRR - Use cases: compliance, lower latency access, replication across accounts
- SRR - Use cases: log aggregation, live replication between production and test accounts
- After activating, only new objects are replication (not retroactive)
- For DELETE operations:
  - Can replicate delete markers form source to target (optional setting)
  - Deletions with a version ID are not replicated (to avoid malicious deletes)
- There is no 'chaining' of replication
  - If bucket 1 has replication into bucket 2, which has replication into bucket 3
  - Then objects created in bucket 1 are not replicated into bucket 3

## S3 pre-signed URLs
- Can generate pre-signed URLs using SDK or CLI
  - For downloads (easy, can use the CLI)
  - For uploads (harder, must use the SDK)
- Valid for a default of 3600 seconds, can change timeout with --expires-in [TIME_BY_SECONDS] argument
- Users given a pre-signed URL inherit the permissions of the person who generated the URL for GET/PUT
- Examples:
  - Allow only logged-in users to download a premium video on your S3 bucket
  - Allow an ever-changing list of users to download files by generating URLs dynamically
  - Allow temporarily a user to upload a file to a precise location in our bucket

## Storage Classes
- Amazon S3 Standard - General purpose
- Amazon S3 Standard-Infrequent Access (IA)
- Amazon S3 One Zone-Infrequent Access
- Amazon S3 Intelligent Tiering
- Amazon Glacier
- Amazon Glacier Deep Archive
- Amazon S3 Reduced Redundancy Storage (deprecated)

### General Purpose
- High durability (99.999999999%) of objects across multiple AZ
- 99.99% availability over a given year
- Sustain 2 concurrent facility failures
- Use cases: Big data analytics, mobile and gaming applications, content distribution

### Standard - Infrequent Access (IA)
- Suitable for data that is less frequently accessed, but required rapic access when needed
- High durability (99.999999999%) of objects across multiple AZs
- 99.9% availability
- Low cost compared to Amazon S3 Standard
- Sustain 2 concurrent facility failures
- Use cases: As a data store for disaster recovery, backups..

### One Zone - Infrequent Access
- Same as IA but data is stored in a single AZ
- High durability (99.999999999%) of objects in a single AZ; data is lost when AZ is destroyed
- 99.5% Availability
- Low latency and high throughput performance
- Supports SSL for data at transit and encryption at rest
- Low cost compared to IA (by 20%)
- Use cases: Storing secondary backup copies of on-premises data, or storing data you can recreate

### Intelligent Tiering
- Same low latency and high throughput performance of S3 standard
- Small monthly monitoring and auto-tiering fee
- Automatically moves objects between two access tiers based on changing access patterns
- Designed for durability of 99.99999999% of objects across multiple AZ
- Resilient against events that impact an entire AZ
- Designed for 99.9% availability over a given year

### Amazon Glacier
- Low cost object storage meant for archiving/backup
- Data is retained for the longer term (10s of years)
- Alternative to on-premises magnetic tape storage
- Average annual durability is 99.999999999%
- Cost per storage per month ($0.004/GB) + retrieval cost
- Each item in Glacier is called "Archive" (up to 40TB)
- Archives are stored in "Vaults"

### Amazon Glacier & Glacier Deep Archive
- Amazon Glacier - 3 retrieval options:
  - Expedited (1 to 5 minutes)
  - Standard (3 to 5 hours)
  - Bulk (5 to 12 hours)
  - Minimum storage duration of 90 days
- Amazon Glacier Deep Archive - for long term storage - cheaper:
  - Standard (12 hours)
  - Bulk (48 hours)
  - Minimum storage duration of 180 days

## Moving between storage classes
- You can transition objects between storage classes
- For infrequently accessed object, move them to STANDARD_IA
- For archive objects you don't need in real-time, GLACIER or DEEP_ARCHIVE
- Moving objects can be automated using a **lifecycle configuration**

### Lifecycle Rules
- Transition actions: It defines when objects are transitioned to another storage class
  - Move objects to Standard IA class 60 days after creation
  - Move to Glacier for archiving after 6 months
- Expiration Actions: configure objects to expire (delete) after some time
  - Access log files can be set to delete after 365 days
  - Can be used to delete old versions of files (if versioning is enabled)
  - Can be used to delete incomplete multi-part uploads
- Rules can be created for a certain prefix (ex - s3://mybucket/mp3/*)
- Ruels can be created for certian object tags (ex - Department: Finance)

## Storage Class Analysis
- You can setup S3 Analytics to help determine when to transition objects from Standard to Standard_IA
- Does not work for ONEZONE_IA or GLACIER
- Report is updated daily
- Takes about 24h to 48h to first start
- Good first step to put together Lifecycle Rules (or improve them)

### Baseline Performance
- Amazon S3 automatically scales to high request rates, latency 100-200ms
- Your application can achieve at least 3500 PUT/COPY/POST/DELETE and 5500 GET/HEAD requests per second, per prefix in a bucket
- There are no limits to the number of prefixes in a bucket
- If you spread reads across four prefixes evenly, you can achieve 22000 requests per second for GET and HEAD

### KMS Limitations
- If you use SSE-KMS, you may be impacted by KMS limits
- When you upload, it calls the GenerateDataKey KMS API
- When you download, it calls the Decrypt KMS API
- Count towards the KMS quota per second (5500, 10000, 30000 req/s based on region)
- You can request a quota increase using the Service Quotas Console

### S3 Performance
- Multi-Part upload
  - recommended for files > 100MB, must be used for files > 5GB
  - Can help parallelize uploads (speed up transfers)
- S3 Transfer Acceleration
  - Increase transfer speed by transferring file to an AWS edge location which will forward the data to the S3 bucket in the target region
  - Compatible with multi-part upload
- S3 Byte-Range Fetches
  - Parallelize GETs by requesting specific byte ranges
  - Better resilience in case of failures
  - Can be used to speed up downloads
  - Can be used to retrieve only partial data (for example the head of a file)

## S3 Select & Glacier Select
- Retrieve less data using SQL by performing server side filtering
- Can filter by rows & columns (simple SQL statements)
- Less network transfer, less CPU cost client-side
- Up to 400% faster
- Up to 80% cheaper

## S3 Event Notifications
- S3:ObjectCreated, S3:ObjectRemoved, S3:ObjectRestore, S3:Replication...
- React to events such as above
- Object name filtering possible (*.jpg)
- Use case: generate thumbnails of images uploaded to S3
- Targets:
  - SNS
  - SQS
  - Lambda Function
- Can create as many "S3 events" as desired
- S3 event notifications typically deliver events in seconds but can sometimes take a minute or longer
- If two writes are made to a single non-versioned object at the same time, it is possible that only a single event notification will be sent
- If you want to ensure that an event notification is sent for every successful write, you can enable versioning on your bucket

## Requester Pays
- In general, bucket owners pay for all Amazon S3 storage and data transfer costs associated with their bucket
- With requester pays buckets, the requester instead of the bucket owner pays the cost of the request and the data downloaded from the bucket
- Helpful when you want to share large datasets with other accounts
- The requester must be authenticated in AWS (cannot be anonymous)

## Athena
- Serverless query service to perform analytics against S3 objects
- Uses standard SQL language to query the files
- Supports CSV, JSON, ORC, Avro, and Parquet (built on Presto)
- Pricing: $5.00 per TB of data scanned
- Use compressed or columnar data for cost-savings (less scan)
- Use cases: Business intelligence/analytics/reporting, analyze and query VPC flow logs, ELB logs, CloudTrail trails, etc...
- Analyze data in S3 using serverless SQL, use Athena

## Glacier Vault Lock
- Adopt a WORM (Write Once Read Many) model
- Lock the policy for future edits (can no longer be changed)
- Helpful for compliance and data retention

## S3 Object Lock (versioning must be enabled)
- Adopt a WORM (Write Once Read Many) model
- Block an object version deletion for a specified amount of time
- Object retention:
  - Retention period: specifies a fixed period
  - Legal hold: Same protection, no expiry date
- Modes:
  - Governance mode: Users can't overwrite or delete an object version or alter its lock setting unless they have special permissions
  - Compliance mode: A protected object version can't be overwritten or deleted by any user, including the root user in your AWS account. When an object is locked in compliance mode, its retention mode can't be changed, and its retention period can't be shortened.

