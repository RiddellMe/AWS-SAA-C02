# Messaging
- When we start deploying multiple applications, they will inevitably need to communicate with one another
- There are two patterns of application communication:
  - Synchronous
  - Asynchronous
- Synchronous between applications can be problematic if there are sudden spikes of traffic
- What if you need to suddenly encode 1000 videos, but usually it's 10?
- In that case, it's better to **decouple** your applications, using:
  - SQS: queue model
  - SNS: pub/sub model
  - Kinesis: real-time streaming model
- These services can scale independently from our application

## Amazon SQS
- What's a queue?
  - Producer(s) send message INTO a queue
  - Consumer(s) poll message queue and does something with messages
- Standard Queue
  - Oldest offering (over 10 years old)
  - Fully managed service, used to **decouple applications**
  - Attributes:
    - Unlimited throughput, unlimited number of messages in queue
    - Default retention of messages: 4 days, maximum of 14 days
    - Low latency (<10 ms on publish and receive)
    - Limitation of 256KB per message sent
    - Can have duplicate messages (at least once delivery, occasionally)
    - Can have out of order messages (best effort ordering)
  - Producing Messages:
    - Produced to SQS using the SDK (SendMessage API)
    - The message is **persisted** in SQS until a consumer deletes it
    - Message retention: default 4 days, up to 14 days
    - Example: send an order to be processed
      - Order ID
      - Customer ID
      - Any attributes you want
    - SQS standard: unlimited throughput
  - Consuming Messages:
    - Consumers (running on EC2 instances, servers, or AWS Lambda)
    - Poll SQS for messages (receive up to 10 messages at a time)
    - Process the messages (example: insert the message into an RDS database)
    - Delete the messages using the DeleteMessage API
  - Multiple EC2 Instance Consumers
    - Consumers receive and process messages in parallel
    - At least once delivery
    - Best-effort message ordering
    - Consumers delete messages after processing them
    - We can scale consumers horizontally to improve throughput of processing
  - SQS with Auto Scaling Groups (ASG)
    - CloudWatch Metric - Queue Length (ApproximateNumberOfMessages)
  - Security
    - Encryption:
      - In-flight encryption using HTTPS API
      - At-rest encryption using KMS keys
      - Client-side encryption if the client wants to perform encryption/decryption itself
    - Access Controls: IAM policies to regulate access to the SQS API
    - SQS Access Policies (similar to S3 bucket policies)
      - Useful for cross-account access to SQS queues
      - Useful for allowing other services (SNS, S3) to write to an SQS queue

## SQS Queue Access Policy
- Cross Account Access
- Publish S3 Event Notifications to SQS Queue

## Message Visibility Timeout
- After a message is polled by a consumer, it becomes **invisible** to other consumers
- By default, the 'message timeout visibility' is 30 seconds
- That means the message has 30 seconds to be processed
- After the message visibility timeout is over, the message is 'visible' in SQS
- If a message is not processed within the visibility timeout, it will be processed **twice**
- A consumer could call the **ChangeMessageVisibility** API to get more time
- If visibility timeout is high (hours), and consumer crashes, re-processing will take time
- If visibility timeout is too low (seconds), we may get duplicates

## Dead Letter Queue
- If a consumer fails to process a message within the VisibilityTimeout... the message goes back into the queue
- We can set a threshold of how many times a message can go back to the queue
- After a **MaximumReceives** threshold is exceeded, the message goes into a dead letter queue (DLQ)
- Useful for **debugging**
- Make sure to process the messages in the DLQ before they expire:
  - Good to set a retention of 14 days in the DLQ

## Request-Response Systems
- To implement this pattern: use the **SQS Temporary Queue Client**
- It leverages virtual queues instead of creating/deleting SQS queues (cost-effective)

## Delay Queue
- Delay a message (consumers don't see it immediately) up to 15 mins
- Default is 0 seconds (message is available right away)
- Can set a default at the queue level
- Can override the default on send using the DelaySeconds parameter

## FIFO Queue
- FIFO = First In First Out (ordering of messages in the queue)
- Limited throughput: 300 msg/s without batching, 3000 msg/s with batching
- Exactly-once send capability (by removing duplicates)
- Messages are processed in order by the consumer

## SQS with Auto Scaling Group (ASG)
- EC2 Instances can push CloudWatch Custom Metric (Queue Length/Number of Instances)
- Set CloudWatch Alarm
- Alarm is assigned to a Scaling Policy to scale the ASG accordingly

## Amazon SNS
- What if you want to send one message to many receivers?
- Pub/Sub pattern
- The 'event producer' only sends message to one SNS topic
- As many 'event receivers' (subscribers) as we want to listen to the SNS topic notifications
- Each subscriber to the topic will get all the messages (note: new features to filter messages)
- Up to 10,000,000 subscriptions per topic
- 100,000 topics limit
- Subscribers can be:
  - SQS
  - HTTP/HTTPS (with delivery retries - how many times)
  - Lambda
  - Email
  - SMS messages
  - Mobile Notifications
- SNS integrates with a lot of AWS services
  - Many AWS services can send data directly to SNS for notifications
  - CloudWatch (for alarms)
  - Auto Scaling Group notifications
  - Amazon S3 (on bucket events)
  - CloudFormation (open state changes -> failed to build, etc)
  - etc...
- How to publish
  - Topic Publish (using the SDK)
    - Create a topic
    - Create a subscription (or many)
    - Publish to the topic
  - Direct Publish (for mobile app SDK)
    - Create a platform application
    - Create a platform endpoint 
    - Publish to the platform endpoint
    - Works with Google GCM, Apple APNS, Amazon ADM...
- Security
  - Encryption:
    - In-flight encryption using HTTPS API
    - At-rest encryption using KMS keys
    - Client-side encryption if the client wants to perform encryption/decryption itself
  - Access Controls: IAM policies to regulate access to the SNS API
  - SNS Access Policies (similar to S3 bucket policies)
    - Useful for cross-account access to SNS topics
    - Useful for allowing other services, such as S3, to write to an SNS topic

## SNS + SQS: Fan Out
- Push once in SNS, receive in all SQS queues that are subscribers
- Fully decoupled, no data loss
- SQS allows for: data persistence, delayed processing and retries of work
- Ability to add more SQS subscribers over time
- Make sure your SQS queue access policy allows for SNS to write
- Application: S3 Events to multiple queues
  - For the same combination of: **event type** (e.g. object create) and **prefix** (e.g. images/) you can only have **one S3 Event rule**
  - If you want to send the same S3 event to many SQS queues, use fan out pattern
- FIFO Topic
  - First In First Out (ordering of messages in the topic)
  - Similar features as SQS FIFO:
    - **Ordering** by Message Group ID (all messages in the same group are ordered)
    - **Deduplication** using a Deduplication ID or Content Based Deduplication
    - Can only have SQS FIFO queues as subscribers
    - Limited throughput (same throughput as SQS FIFO)
- SNS FIFO + SQS FIFO: Fan Out
  - In case you need fan out + ordering + deduplication
- Message Filtering
  - JSON policy used to filter messages sent to SNS topic's subscriptions
  - If a subscription doesn't have a filter policy, it receives every message

## Kinesis
- Makes it easy to **connect, process, and analyze** streaming data in real-time
- Ingest real-time data such as: Application logs, Metrics, Website clickstreams, IoT telemetry data...
- Kinesis Data Streams: Capture, process, and store data streams
- Kinesis Firehose: load data streams into AWS data stores
- Kinesis Data Analytics: analyze data streams with SQL or Apache Flink
- Kinesis Video Streams: capture, process, and store video streams
- Kinesis Data Streams
  - Billing is per shard provisioned, can have as many shards as you want
  - Retention between 1 day (default) to 365 days
  - Ability to reprocess (replay) data
  - Once data is inserted in Kinesis, it can't be deleted (immutability)
  - Data that shares the same partition goes to the same shard (ordering)
  - Producers: AWS SDK, Kinesis Producer Library (KPL), Kinesis Agent
  - Consumers:
    - Write your own: Kinesis Client Library (KCL), AWS SDK
    - Managed: AWS Lambda, Kinesis Data Firehose, Kinesis Data Analytics
- Kinesis Data Firehose
  - AWS Destinations:
    - Amazon S3
    - Amazon Redshift (COPY through S3)
    - Amazon ElasticSearch
  - 3rd party destinations:
    - Splunk
    - New Relic
    - MongoDB
  - Custom Destinations:
    - HTTP Endpoint
  - Can send failed or all data to a backup S3 bucket
  - Fully managed service, no administration, automatic scaling, serverless
  - Pay for the data going through Firehose
  - Near Real-time
    - 60 seconds latency minimum for non-full batches
    - Or minimum 32 MB of data at a time
  - Supports many data formats, conversions, transformations, compression
  - Supports custom data transformations using AWS Lambda


### Kinesis Data Streams vs Firehose
- Kinesis Data Streams:
  - Streaming service to ingest at scale
  - Write custom code (producer/consumer)
  - Real-time (~200 ms)
  - Manage scaling (shard splitting/merging)
  - Data storage for 1 to 365 days
  - Supports replay capability
- Kinesis Data Firehose
  - Load streaming data into S3/Redshift/ES/3rd party/custom HTTP
  - Fully managed
  - Near real-time (bugger time min. 60 seconds)
  - Automatic scaling
  - No data storage
  - Doesn't support replay capability

### Kinesis Data Analytics (SQL application)
- Perform real-time analytics on Kinesis Streams using SQL
- Fully managed, no servers to provision
- Automatic scaling
- Real-time analytics
- Pay for actual consumption rate
- Can create streams out of the real-time queries
- Use cases:
  - Time-series analytics
  - Real-time dashboards
  - Real-time metrics

## Kinesis vs SQS ordering
- Assume 100 trucks, 5 kinesis shards, 1 SQS FIFO
- Kinesis Data Streams:
  - On average you'll have 20 trucks per shard
  - Trucks will have their data ordered within each shard
  - The maximum amount of consumers in parallel we can have is 5
  - Can receive up to 5MB/s of data
- SQS FIFO:
  - You only have one SQS FIFO queue
  - You will have 100 Group ID
  - You can have up to 100 Consumers (due to the 100 Group ID)
  - You have up to 300 messages per second (or 3000 if using batching)

## SQS vs SNS vs Kinesis
- SQS:
  - Consumer 'pull data'
  - Data is deleted after being consumed
  - Can have as many workers (consumers) as we want
  - No need to provision throughput
  - Ordering guarantees only on FIFO queues
  - Individual message delay capability
- SNS:
  - Push data to many subscribers
  - Up to 12,500,000 subscribers
  - Data is not persisted (lost if not delivered)
  - Pub/Sub
  - Up to 100,000 topics
  - No need to provision throughput
  - Integrates with SQS for fan-out architecture pattern
  - FIFO capability for SQS FIFO
- Kinesis:
  - Standard: pull data
    - 2MB/s per shard
  - Enhanced fan out: push data
    - 2MB/s per shard per consumer
  - Possibility to replay data
  - Meant for real-time big data, analytics, and ETL
  - Ordering at the shard level
  - Data expires after X days (1-365)
  - Must provision throughput (via shards)

## Amazon MQ
- SQS and SNS are 'cloud-native' services, and they're using proprietary protocols from AWS.
- Traditional applications running on-premises may use open protocols such as: MQTT, AMQP, STOMP, Openwire, WSS
- When migrating to the cloud, instead of re-engineering the application to use SQS and SNS, we can use Amazon MQ
- Amazon MQ = managed Apache ActiveMQ
- Amazon MQ doesn't scale as much as SQS/SNS
- Amazon MQ runs on a dedicated machine, can run in HA with failover
- Amazon MQ has both queue features (~SQS) and topic features (~SNS)
