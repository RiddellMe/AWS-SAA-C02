# Databases
- Questions to choose the right database based on your architecture:
  - Read-heavy, write-heavy, or balanced workload? Throughput needs? Will it change, does it need to scale or fluctuate during the day?
  - How much data to store and for how long? Will it grow? Average object size? How are they accessed?
  - Data durability? Source of truth for the data?
  - Latency requirements? Concurrent users?
  - Data model? How will you query the data? Joins? Structured? Semi-Structured?
  - Strong schema? More flexibility? Reporting? Search? RDBMS/NoSQL?
  - License costs? Switch to Cloud Native DB such as Aurora?

### Database Types
- RDBMS (SQL / OLTP): RDS, Aurora - great for joins
- NoSQL: DynamoDB (~JSON), ElastiCache (key/value pairs), Neptune (graphs) - no joins, no SQL
- Object Store: S3 (for big objects) / Glacier (for backups / archives)
- Data Warehouse (SQL Analytics/BI): Redshift (OLAP), Athena
- ElasticSearch (JSON) - free text, unstructured searches
- Graphs: Neptune - displays relationship between data

## RDS
- Managed PostgreSQL / MySQL / Oracle / SQL Server
- Must provision an EC2 instance & EBS Volume type and size (behind the scenes)
- Support for read replicas and Multi-AZ
- Security through IAM, security groups, KMS, SSL in transit
- Backup/Snapshot/Point in time restore feature
- managed and scheduled maintenance
- Monitoring through CloudWatch
- Use case: Store relational datasets (RDBMS/OLTP), perform SQL queries, transactional inserts/update/deletes available
- RDS for Solutions Architect
  - Operations: small downtime when failover happens, when maintenance happens, scaling in read replicas/ec2 instance/restore EBS implies manual intervention, application changes
  - Security: AWS responsible for OS security, we are responsible for setting up KMS, security groups, IAM policies, authorizing users in DB, using SSL
  - Reliability: Multi-AZ feature, failover in case of failures
  - Performance: depends on EC2 instance type, EBS volume type, ability to add read replicas. Storage auto-scaling and manual scaling of instances
  - Cost: pay per hour based on provisioned EC2 and EBS

## Aurora
- Compatible API for PostgreSQL/MySQL
- Data is held in 6 replicas, across 3 AZ
- Auto healing capability
- Multi AZ, Auto scaling read replicas
- Read replicas can be global
- Aurora database can be Global for DR or latency purposes
- Auto scaling of storage from 10GB to 128TB
- Define EC2 instance type for aurora instances
- Same security/monitoring/maintenance features as RDS
- Aurora Serverless - for unpredictable/intermittent workloads
- Aurora Multi-Master - for continuous writes failover
- Use case: Same as RDS, but with less maintenance/more flexibility/more performance
Aurora for Solutions Architect
  - Operations: less operations, auto scaling storage
  - Security: AWS responsible for OS security, we are responsible for setting up KMS, security groups, IAM policies, authorizing users in DB, using SSL
  - Reliability: Mutli AZ, highly available, possibly more than RDS, Aurora Serverless option, Aurora Multi-Master option
  - Performance: 5x performance (according to AWS) due to architectural optimisations. Up to 15 read replicas (only 5 for RDS)
  - Cost: Pay per hour based on EC2 and storage usage. Possibly lower costs compared to enterprise grade databases such as Oracle

## ElastiCache
- Managed Redis/Memcached (similar offering as RDS, but for caches)
- In-memory data store, sub-millisecond latency
- Must provision an EC2 instance type
- Support for clustering (Multi AZ) (Redis), as well as read replicas (sharding)
- Security through IAM, security groups, KMS, Redis Auth
- Backup/Snapshot/Point in time restore feature
- Managed and scheduled maintenance
- Monitoring through CloudWatch
- Use case: Key/Value store, frequent reads, less writes, cache results for DB queries, store session data for websites, cannot use SQL
- ElastiCache for Solutions Architect
  - Operations: same as RDS
  - Security: AWS responsible for OS security, we are responsible for setting up KMS, security groups, IAM policies, users (Redis Auth), using SSL
  - Reliability: Clustering, Multi AZ
  - Performance:Sub-millisecond performance, in memory, read replicas for sharding, very popular cache option
  - Cost: Pay per hour based on EC2 and storage usage

## DynamoDB
- AWS proprietary technology, managed NoSQL database
- Serverless, provisioned/on demand capacity, auto scaling
- Can replace ElastiCache as a key/value store (storing session data for example)
- Single digit millisecond performance
- Highly available, Multi AZ by default, read and writes are decoupled, DAX for read cache
- Reads can be eventually consistent or strongly consistent
- Security, authentication and authorization is done through IAM
- DynamoDB Streams to integrate with AWS Lambda
- Backup/Restore feature, Global Table feature
- Monitoring through CloudWatch
- Can only query on primary key, sort key, or indices
- Use case: Serverless application development (small documents - 100s of KB), distributed serverless cache, doesn't have SQL query language available, has transactions capability
- DynamoDB for Solutions Architect
  - Operations: no operations needed, auto scaling capability, serverless
  - Security: full security through IAM policies, KMS encryption, SSL in flight
  - Reliability: Multi AZ, Backups
  - Performance: single digit millisecond performance, DAX for caching reads, performance doesn't degrade if your application scales
  - Cost: Pay per provisioned capacity and storage usage (no need to guess in advance any capacity - can use auto scaling)

## S3
- S3 is a... key (file path)/value (file) store of objects
- Great for big objects, not so great for small objects
- Serverless, scales infinitely, max object size is 5TB
- Strong consistency
- Tiers: S3 standard, S3 IA, S3 One Zone IA, Glacier for backups
- Features: Versioning, Encryption, Cross region replication etc...
- Security: IAM, Bucket policies, ACL
- Encryption: SSE-S3, SSE-KMS, SSE-C, client side encryption, SSL in transit
- Use case: Static files, key value store for big files, website hosting
- S3 for Solutions Architect
  - Operations: no operations needed
  - Security: IAM, Bucket policies, ACL, Encryption (Server/Client), SSL
  - Reliability: 99.999999999% durability/99.99% availability, Multi AZ, CRR
  - Performance: scales to thousands of read/writes per second, transfer acceleration/multi-part for big files
  - Cost: pay per storage usage, network cost, requests number

## Athena
- SQL layer on top of S3
- Fully serverless database with SQL capability
- Used to query data in S3
- Pay per query
- Output results back to S3
- Secured through IAM
- Use case: one time SQL queries, serverless queries on S3, log analytics
- Athena for Solutions Architect
  - Operations: no operations needed, serverless
  - Security: IAM + S3 security
  - Reliability: managed service, uses Presto engine, highly available
  - Performance: queries scale based on data size
  - Cost: pay per query/per TB of data scanned, serverless

## Redshift
- Redshift is based on PostgreSQL, but **it's not used for OLTP**
- It's OLAP - online analytical processing (analytics and data warehousing)
- 10x better performance than other data warehouses, scales to PBs of data
- **Columnar** storage of data (instead of row based)
- Massively Parallel Query Execution (MPP) engine
- Pay as you go based on the instances provisioned
- Has a SQL interface for performing the queries
- BI tools such as AWS Quicksight or Tableau integrate with it
- Data is loaded from S3, DynamoDB, DMS, other DBs...
- From 1 node to 128 nodes, up to 128TB of space per node
- Leader node: for query planning, results aggregation
- Compute node: for performing the queries, send results to leader
- Redshift Spectrum: perform queries directly against S3 (no need to load)
- Backup and Restore, Security VPC/IAM/KMS, Monitoring
- Redshift Enhanced VPC Routing: COPY/UNLOAD goes through VPC

### Redshift - Snapshots & DR
- Redshift has no Multi-AZ mode
- Snapshots are point-in-time backups of a cluster, stored internally in S3
- Snapshots are incremental (only what has changed is saved)
- You can restore a snapshot into a **new cluster**
- Automated: every 8 hours, every 5GB, or on a schedule. Set retention for snapshots
- Manual: snapshot is retained until you delete it
- You can configure Amazon Redshift to automatically copy snapshots (automated or manual) of a cluster to another AWS region

### Redshift Spectrum
- Query data that is already in S3 without loading it
- Must have a Redshift cluster available to start the query
- The query is then submitted to thousands of Redshift Spectrum nodes

### Redshift for Solutions Architect
- Operations: like RDS
- Security: IAM, VPC, KMS, SSL (like RDS)
- Reliability: Auto healing features, cross-region snapshot copy
- Performance: 10x performance vs other data warehousing, compression
- Cost: pay per node provisioned, 1/10th of the cost vs other warehouses
- vs Athena: faster queries/joins/aggregations thanks to indices
- Remember: Redshift = Analytics/BI/Data Warehouse

## AWS Glue
- Managed **extract, transform, and load (ETL)** service
- Useful to prepare and transform data for analytics
- Fully serverless service
- Glue Data Catalog
  - Catalog of datasets (metadata)

## Neptune
- Fully managed **graph** database
- When do we use Graphs?
  - High relationship data
  - Social Networking: Users are friends with other users, replies to comments on posts of users, and likes other comments
  - Knowledge graphs (Wikipedia)
- Highly available across 3 AZ, with up to 15 read replicas
- Point-in-time recovery, continuous backup to Amazon S3
- Support for KMS encryption at rest + HTTPS
- Neptune for Solutions Architect
  - Operations: similar to RDS
  - Security: IAM, VPC, KMS, SSL (similar to RDS) + IAM Authentication
  - Reliability: Multi-AZ, clustering
  - Performance: best suited for graphs, clustering to improve performance
  - Cost: pay per node provisioned (similar to RDS)
- Remember: Neptune = Graphs

## ElasticSearch
- Open source tech
- Example: In DynamoDB, you can only find data by primary key or indices
- With ElasticSearch, you can **search any field**, even partial matches
- It's common to use ElasticSearch as a complement to another database
- ElasticSearch also has some usage for Big Data applications
- You can provision a cluster of instances
- Built-in integrations: Amazon Kinesis Data Firehose, AWS IoT, and Amazon CloudWatch Logs for data ingestion
- Security through Cognito & IAM, KMS encryption, SSL, & VPC
- Comes with Kibana (visualisation) & Logstash (log ingestion) - ELK stack
- ElasticSearch for Solutions Architect
  - Operations: similar to RDS
  - Security: Cognito, IAM, VPC, KMS, SSL
  - Reliability: Multi-AZ, clustering
  - Performance: based on ElasticSearch project (open source), petabyte scale
  - Cost: pay per node provisioned (similar to RDS)
- Remember: ElasticSearch = Search/Indexing

