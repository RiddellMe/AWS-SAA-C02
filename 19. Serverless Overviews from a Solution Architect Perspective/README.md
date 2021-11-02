## Serverless
- Serverless is a new paradigm in which the developers don't have to manage servers anymore...
- They just deploy code
- Initially, serverless meant FaaS (Function as a Service)
- Serverless was pioneered by AWS Lambda but now also includes anything that's managed.
  - Databases
  - Messaging
  - Storage
  - etc
- Serverless does **not** mean there are no servers, it just means you don't manage/provision/see them

## Serverless in AWS
- AWS Lambda
- DynamoDB
- AWS Cognito
- AWS API Gateway
- Amazon S3
- AWS SNS & SQS
- AWS Kinesis Data Firehose
- Aurora Serverless
- Step Functions
- Fargate

## Lambda
- EC2:
  - Virtual Servers in the Cloud
  - Limited by RAM and CPU
  - Continuously running
  - Scaling means intervention to add/remove servers
- Lambda:
  - Virtual **functions** - no servers to manage
  - Limited by time - **short executions** (up to 15 minutes)
  - Run **on-demand**
  - **Scaling is automated**
- Benefits of Lambda:
  - Easy pricing:
    - Pay per request and compute time
    - Free tier of 1,000,000 AWS Lambda requests and 400,000 GB-seconds of compute time (if a function is allocated 1GB and it runs for 10s, it consumes 1GB/s and thus was 10GB-seconds)
  - Integrated with the whole AWS suite of services
  - Integrated with many programming languages
  - Easy monitoring through AWS CloudWatch
  - Easy to get more resources per functions (up to 10GB of RAM)
  - Increasing RAM will also improve CPU and network
- Language support:
  - Node.js (JavaScript)
  - Python
  - Java (Java 8/11 compatible)
  - C# (.NET Core)
  - Golang
  - C#/Powershell
  - Ruby
  - Custom Runtime API (community supported, example Rust)
  - Lambda Container Image
    - The container image must implement the Lambda Runtime API
    - ECS/Fargate is preferred for running arbitrary Docker images

### Lambda Integrations
- Main ones
  - API Gateway
  - Kinesis
  - DynamoDB
  - S3
  - CloudFront
  - CloudWatch Events EventBridge
  - CloudWatch Logs
  - SNS
  - SQS
  - Cognito

## AWS Lambda Pricing
- Pay per calls:
  - First 1000000 requests are free
  - %0.20 per 1 million requests thereafter ($0.0000002 per request)
- Pay per duration: (in increments of 1ms)
  - 400,000 GB-seconds of compute time per month FREE
  - == 400,000 seconds if function is 1GB RAM
  - == 3,200,000 seconds if function is 128 MB RAM
  - After that, %1 for 600,000 GB-seconds
- It is usually very cheap to run AWS Lambda so it's very popular

## Lambda Limits to know - per region
- Execution:
  - Memory allocation: 128MB - 10GB (1 MB increments)
  - Maximum execution time: 15 minutes
  - Environment variables (4KB)
  - Disk capacity in the 'function container' (in /tmp): 512MB
  - Concurrent executions: 1000 (can be increased)
- Deployment:
  - Lambda function deployment size (compressed .zip): 50MB
  - Size of uncompressed deployment (code + dependencies): 250MB
  - Can use the /tmp directory to load other files at startup
  - Size of environment variables: 4KB

## Lambda@Edge
- You have deployed a CDN using CloudFront
- What if you wanted to run a global AWS Lambda alongside?
- Or, how to implement request filtering before reaching your application?
- For this, you can use Lambda@Edge:
  - deploy Lambda functions alongside your CloudFront CDN
    - Build more responsive applications
    - You don't manage servers, Lambda is deployed globally
    - Customize the CDN content
    - Pay only for what you use
- You can use Lambda to change CloudFront requests and responses:
  - After CloudFront receives a request from a viewer (viewer request)
  - Before CloudFront forwards the request to the origin (origin request)
  - After CloudFront receives the response from the origin (origin response)
  - Before CloudFront forwards the response to the viewer (viewer response)
- You can also generate responses to viewers without ever sending the request to the origin
- Use cases:
  - Website security and privacy
  - Dynamic Web Application at the edge
  - Search Engine Optimization (SEO)
  - Intelligently route across origins and data centers 
  - Bot mitigation at the edge
  - Real-time image transformation
  - A/B testing
  - User authentication and authorization
  - User prioritization
  - User tracking and analytics

## AWS DynamoDB
- Fully managed, highly available with replication across multiple AZs
- NoSQL database - not a relational database
- Scales to massive workloads, distributed database
- Millions of requests per seconds, trillions of rows, 100s of TB of storage
- Fast and consistent in performance (low latency on retrieval)
- Integrated with IAM for security, authorization, and administration
- Enables event driven programming with DynamoDB streams
- Low cost and auto-scaling capabilities
- Basics:
  - DynamoDB is made of Tables
  - Each table has a **primary key** (must be decided at creation time)
  - Each table can have an infinite number of items (rows)
  - Each item has **attributes** (can be added over time - can be null)
  - Maximum size of an item is **400KB**
  - Data types supported are:
  - Scalar types - String, Number, Binary, Boolean, Null
  - Document types - List, Map
  - Set types - String set, Number set, Binary set
- Primary Key can be made up of 1 or 2 columns (Partition key, Sort key)
- Read/Write Capacity Modes
  - Control how you manage your table's capacity (read/write throughput)
  - Provisioned Mode (default)
    - You specify the number of read/writes per second
    - You need to plan capacity beforehand
    - Pay for **provisioned** Read Capacity Units (RCU) & Write Capacity Units (WCU)
    - Possible to add **auto-scaling** mode for RCU & WCU
  - On-Demand Mode
    - Read/writes automatically scale up/down with your workloads
    - No capacity planning needed
    - Pay for what you use, more expensive
    - Great for **unpredictable** workloads

## DynamoDB Accelerator (DAX)
- Fully managed, highly available, seamless in-memory cache for DynamoDB
- **Help solve read congestion by caching**
- Microseconds latency for cached data
- Doesn't require application logic modifications (compatible with existing DynamoDB APIs)
- 5 minutes TTL for cache (default)

### DAX vs ElastiCache
- DAX:
  - Individual object cache
  - Query and Scan cache
- ElastiCache:
  - Store aggregation result (e.g. after computation)

### DynamoDB Streams
- Ordered stream of item-level modifications (create/update/delete) in a table
- Stream records can be:
  - Sent to Kinesis Data Streams
  - Read by AWS Lambda
  - Read by Kinesis Client Library applications
- Data retention for up to 24 hours
- Use cases:
  - React to changes in real-time (welcome email to users)
  - Analytics
  - Insert into derivative tables
  - Insert into ElasticSearch
  - Implement cross-region replication

### DynamoDB - Global Tables
- Make a DynamoDB table accessible with **low latency** in multiple regions
- Active-Active replications
- Applications can read and write to the table in any region
- Must enable DynamoDB Streams as a pre-requisite

### DynamoDB - Time To Live (TTL)
- Automatically delete items after an expiry timestamp
- Use cases: reduce stored data by keeping only current items, adhere to regulatory obligations...

### DynamoDB - Indexes
- Global Secondary Indexes (GSI) & Local Secondary Indexes (LSI)
- High level: allow to **query** on attributes other than the Primary Key

### DynamoDB - Transactions
- Update two tables **simultaneously**
- A transaction is written to both tables, or none

## AWS API Gateway
- AWS Lambda + API Gateway: No infrastructure to manage
- Support for WebSocket protocol
- Handle API versioning (v1, v2...)
- Handle different environments (dev, test, prod)
- Handle security (Authentication and Authorization)
- Create API keys, handle request throttling
- Swagger/OpenAPI import to quickly define APIs
- Transform and validate requests and responses
- Generate SDK and API specifications
- Cache API responses

### API Gateway - Integrations (high level)
- Lambda function
  - Invoke Lambda function
  - Easy way to expose REST API backed by AWS Lambda
- HTTP
  - Expose HTTP endpoints in the backend
  - Example: internal HTTP API on premises, Application Load Balancer...
  - Why? Add rate limiting, caching, user authentications, API keys, etc...
- AWS Service
  - Expose any AWS API through the API Gateway
  - Example: Start an AWS Step Function workflow, post a message to SQS
  - Why? Add authentication, deploy publicly, rate control...

### API Gateway - Endpoint Types
- Edge-Optimized (default):
  - For global clients
  - Requests are routed through the CloudFront Edge locations (improves latency)
  - The API Gateway still lives in only one region
- Regional:
  - For clients within the same region
  - Could manually combine with CloudFront (more control over the caching strategies and the distribution)
- Private:
  - Can only be accessed from your VPC using an interface VPC endpoint (ENI)
  - Use a resource policy to define access

## Api Gateway - Security
- IAM Permissions
  - Create an IAM policy authorization and attach to User/Role
  - API Gateway verifies IAM permissions passed by the calling application
  - Good to provide access within your own infrastructure
  - Leverages "Sig v4" capability where IAM credentials are in headers
- Lambda Authorizer (formerly Custom Authorizers)
  - Uses AWS Lambda to validate the token in header being passed
  - Option to cache result of authentication
  - Helps to use OAuth/SAML/3rd party type of authentication
  - Lambda must return an IAM policy for the user
- Cognito User Pools
  - Cognito fully manages user lifecycle
  - API Gateway verifies identity automatically from AWS Cognito
  - No custom implementation required
  - Cognito only helps with authentication, not authorization
- Summary
  - IAM:
    - Great for users/roles already within your AWS account
    - Handle authentication + authorization
    - Leverages Sig v4
  - Lambda Authorizer:
    - Great for 3rd party tokens
    - Very flexible in terms of what IAM policy is returned
    - Handle Authentication + Authorization
    - Pay per Lambda invocation
  - Cognito User Pool:
    - You manage your own user pool (can be backed by Facebook, Google login etc)
    - No need to write any custom code
    - Must implement authorization in the backend

## AWS Cognito
- We want to give our users an identity so that they can interact with our application
- Cognito User Pools:
  - Sign in functionality for app users
  - Integrate with API Gateway
- Cognito Identity Pools (Federated Identity):
  - Provide AWS credentials to users, so they can access AWS resources directly
  - Integrate with Cognito User Pools as an identity provider
- Cognito Sync:
  - Synchronize data from device to Cognito
  - May be deprecated and replaced by AppSync

### AWS Cognito User Pools (CUP)
- Create a serverless database of users for your mobile apps
- Simple login: username (or email)/password combination
- Possibility to verify emails/phone numbers and add MFA
- Can enable Federated Identities (Facebook, Google, SAML...)
- Sends back a JSON Web Token (JWT)
- Can be integrated with API Gateway for authentication

### Federated Identity Pools
- Goal:
  - Provide direct access to AWS Resources from the client side
- How:
  - Log in to federated identity provider - or remain anonymous
  - Get temporary AWS credentials back from the Federated Identity Pool
  - These credentials come with a pre-defined IAM policy stating their permissions
- Example:
  - provide (temporary) access to write to S3 bucket using Facebook Login

### AWS AppSync
- AWS Cognito Sync is deprecated, so use AppSync
- Store preferences, configuration, and state of the app
- Cross device synchronization (any platform - iOS, Android etc)
- Offline capability (synchronization when back online)
- Store data in datasets (up to 1MB)

### AWS SAM - Serverless Application Model
- Framework for developing and deploying serverless applications
- All the configuration is YAML code
  - Lambda Functions
  - DynamoDB tables
  - API Gateway
  - Cognito User Pools
- SAM can help you to run Lambda, API Gateway, DynamoDB locally
- SAM can use CodeDeploy to deploy Lambda functions
- 
