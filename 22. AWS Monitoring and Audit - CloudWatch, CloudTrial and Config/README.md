## AWS CloudWatch Metrics
- CloudWatch provides metrics for **every** service in AWS
- **Metric** is a variable to monitor (CPUUtilization, NetworkIn...)
- Metrics belong to **namespaces**
- **Dimension** is an attribute of a metric (instance id, environment, etc...)
- Up to 10 dimensions per metric
- Metrics have **timestamps**
- Can create CloudWatch dashboards of metrics

### EC2 Detailed Monitoring
- EC2 instance metrics have metrics "every 5 minutes"
- With detailed monitoring (for a cost), you get data "every 1 minute"
- Use detailed monitoring if you want to scale faster for your ASG
- The AWS Free Tier allows us to have 10 detailed monitoring metrics
- Note: EC2 Memory usage is by default not pushed (must be pushed from inside the instance as a custom metric)

## CloudWatch Custom Metrics
- Possibility to define and send your own custom metrics to CloudWatch
- Example: memory (RAM) usage, disk space, number of logged in users...
- Use API call PutMetricData
- Ability to use dimensions (attributes) to segment metrics
  - Instance.id
  - Environment.name
- Metric resolution (StorageResolution API parameter - two possible values):
  - Standard: 1 minute (60 seconds)
  - High Resolution: 1/5/10/30 second(s) - higher cost
- Important: Accepts metric data points two weeks in the past and two hours in the future (make sure to configure your EC2 instance time correctly)

## CloudWatch Dashboards
- Great way to set up custom dashboards for quick access to key metrics and alarms
- **Dashboards are global**
- **Dashboards can include graphs from different AWS accounts and regions**
- You can change the timezone and time range of the dashboards
- You can set up automatic refresh (10s, 1m, 2m, 5m, 15m)
- Dashboards can be shared with people who don't have an AWS account (public, email address, 3rd party SSO provider through Amazon Cognito)
- Pricing:
  - 3 dashboards (up to 50 metrics) for free
  - $3/dashboard/month afterwards

## AWS CloudWatch Logs
- Applications can send logs to CloudWatch using the SDK
- CloudWatch can collect log from:
  - Elastic Beanstalk: collection of logs from application
  - ECS: collection from containers
  - AWS Lambda: collection from function logs
  - VPC Flow Logs: VPC specific logs
  - API Gateway
  - CloudTrail based on filter
  - CloudWatch log agents: for example on EC2 machines
  - Route53: Log DNS queries
- CloudWatch logs can go to:
  - Batch exporter to S3 for archival
  - Stream to ElasticSearch cluster for further analytics
- Log storage architecture:
  - Log groups: arbitrary name, usually representing an application
  - Log stream: instances within application/log files/containers
- Can define log expiration policies (never expire, 30 days, etc...)
- Have to pay for data retention
- Using the AWS CLI we can tail CloudWatch logs
- To send logs to CloudWatch, make sure IAM permissions are correct
- Security: encryption of logs using KMS at the Group Level

### CloudWatch Logs Metric Filter & Insights
- CloudWatch Logs can use filter expressions
  - For example, find a specific IP inside of a log
  - Metric filters can be used to trigger alarms
- CloudWatch Logs Insights can be used to query logs and add queries to CloudWatch Dashboards

## CloudWatch Logs for EC2
- By default, no logs from your EC2 machine will go to CloudWatch
- You need to run a CloudWatch agent on EC2 to push the log files you want
- Make sure IAM permissions are correct
- The CloudWatch log agent can be set up on-premises too

## CloudWatch Logs Agent & Unified Agent
- For virtual servers (EC2 instances, on premises servers)
- CloudWatch Logs Agent
  - Old version of the agent
  - Can only send to CloudWatch Logs
- CloudWatch Unified Agent
  - Collect additional system-level metrics such as RAM, processes, etc
  - Collect logs to send to CloudWatch Logs
  - Centralized configuration using SSM Parameter Store

### CloudWatch Unified Agent - Metrics
- Collected directly on your Linux server/EC2 instance
- CPU (active, guest, idle, system, user, steal)
- Disk metrics (free, used, total), Disk IO (writes, reads, bytes, iops)
- RAM (free, inactive, used, total, cached)
- Netstat (number of TCP and UDP connections, net packets, bytes)
- Processes (total, dead, blocked, idle, running, sleep)
- Swap Space (free, used, used %)
- Reminder: out of the box metrics for EC2 - disk, CPU, network (high level).
- CloudWatch Unified Agent provides more granular metrics

## CloudWatch Alarms
- Alarms are used to trigger notifications for any metric
- Various options (sampling, %, max, min, etc)
- Alarm States:
  - OK
  - INSUFFICIENT_DATA
  - ALARM
- Period:
  - Length of time in seconds to evaluate the metric
  - High resolution custom metrics: 10 sec, 30 sec, or multiples of 60 sec

### CloudWatch Alarm Targets
- Stop, Terminate, Reboot, or Recover an EC2 instance
- Trigger Auto Scaling action
- Send notification to SNS (from which you can do pretty much anything)

### EC2 Instance Recovery
- Status Check:
  - Instance status = check the EC2 VM
  - System status = check the underlying hardware
- Recovery: Same private, public, elastic IP, metadata, placement group

### CLoudWatch Alarm: good to know
- Alarms can be created based on CloudWatch Logs Metrics Filters
- To test alarms and notifications, set the alarm state to Alarm using CLI

## CloudWatch Events
- Event Pattern: Intercept events form AWS services (sources)
  - Example sources: EC2 instance start, CodeBuild failure, S3, Trusted Advisor
  - Can intercept any API call with CloudTrail integration
- Schedule or CRON (e.g. create an event every 4 hours)
- A JSON payload is created from the event and passed to a target...
  - Compute: Lambda, Batch, ECS task
  - Integration: SQS, SNS, Kinesis Data Streams, Kinesis Data Firehose
  - Orchestration: Step Functions, CodePipeline, CodeBuild
  - Maintenance: SSM, EC2 Actions

## EventBridge
- EventBridge is the next evolution of CloudWatch Events
- Default event bus: generated by AWS services (CloudWatch Events)
- Partner event bus: receive events from SaaS service or applications (Zendesk, DataDog, Segment, Auth0...)
- Custom Event buses: for your own applications
- Event buses can be accessed by other AWS accounts
- Rules: how to process the events (similar to CloudWatch Events)

### Amazon EventBridge Schema Registry
- EventBridge can analyze the events in your bus and infer the schema
- The **Schema Registry** allows you to generate code for your application, that will know in advance how data is structured in the event bus
- Schema can be versioned

### Amazon EventBridge vs CloudWatch Events
- Amazon EventBridge builds upon, and extends CloudWatch Events
- It uses the same service API and endpoint, and the same underlying service infrastructure
- EventBridge allows extension to add event buses for your custom application and your third-party SaaS apps
- EventBridge has the Schema Registry capability
- EventBridge has a different name to mark the new capabilities
- Over time, the CloudWatch Events name will be replaced with EventBridge

## CloudTrail
- Provides governance, compliance, and audit for your AWS Account
- CloudTrail is enabled by default
- Get a history of events/API calls made within your AWS account by:
  - Console
  - SDK
  - CLI
  - AWS Services
- Can put logs from CloudTrail into CloudWatch Logs or S3
- A trail can be applied to All Regions (default) or a single Region
- If a resource is deleted in AWS, investigate CloudTrail first

### CloudTrail Events
- Management Events:
  - Operations that are performed on resources in your AWS account
  - Examples:
    - Configuring security (IAM AttachRolePolicy)
    - Configuring rules for routing data (Amazon EC2 CreateSubnet)
    - Setting up logging (AWS CloudTrail CreateTrail)
  - By default, trails are configured to log management events
  - Can separate Read Events (that don't modify resources) from Write Events (that may modify resources)
- Data Events:
  - By default, data events are not logged (because high volume operations)
  - Amazon S3 object-level activity (ex: GetObject, DelegateObject, PutObject): can separate Read and Write events
  - AWS Lambda function execution activity (the Invoke API)
- CloudTrail Insights Events:
  - Enable CloudTrail Insights to detect unusual activity in your account:
    - inaccurate resource provisioning
    - hitting service limits
    - Bursts of AWS IAM actions
    - Gaps in periodic maintenance activity
  - CloudTrail Insights analyzes normal management events to create a baseline
  - And then **continuously analyzes write events to detect unusual patterns**
    - Anomalies appear in the CloudTrail console
    - Event is sent to Amazon S3
    - An EventBridge event is generated (for automation needs)

### CloudTrail Events Retention
- Events are stored for 90 days in CloudTrail
- To keep events beyond this period, log them to S3 and use Athena

## AWS Config
- Helps with auditing and recording **compliance** of your AWS resources
- Helps record configurations and changes over time
- Questions that can be solved by AWS Config:
  - Is there unrestricted SSH access to my security groups?
  - Do my buckets have any public access?
  - How has my ALB configuration changed over time?
- You can receive alert (SNS notifications) for any changes
- AWS Config is a per-region service
- Can be aggregated across regions and accounts
- Possibility of storing the configuration data into S3 (analyzed by Athena)

### Config Rules
- Can be AWS managed config rules (over 75)
- Can make custom config rules (must be defined in AWS Lambda)
  - Ex: evaluate if each EBS disk is of type gp2
  - Ex: evaluate if each EC2 instance is t2.micro
- Rules can be evaluated/triggered:
  - For each config change
  - And/or: at regular time intervals
- AWS Config Rules do not prevent actions from happening (no deny)
- Gives an overview of your config (compliance)
- Pricing: no free tier, $0.003 per configuration item recorded per region, $0.001 per config rule evaluation per region

### AWS Config Resource
- View compliance of a resource over time
- View configuration of a resource over time
- View CloudTrail API calls of a resource over time

### Config Rules - Remediations
- Automate remediation of non-compliant resources using SSM Automation Documents
- Use AWS-Managed Automation Documents or create custom Automation Documents
  - Tip: you can create custom Automation Documents that invokes Lambda function(s)
- You can set Remediation Retries if the resource is still non-compliant after auto-remediation

### Config Rules - Notifications
- Use EventBridge to trigger notifications when AWS resources are non-compliant
- Ability to send configuration changes and compliance state notifications to SNS (all events - use SNS Filtering or filter at client-side)

## CloudTrail vs CloudWatch vs Config
- CloudWatch
  - Performance monitoring (metrics, CPU, network, etc) and dashboards
  - Events & alerting
  - Log aggregation & analysis
- CloudTrail
  - Record API calls made within your Account by everyone
  - Can define trails for specific resources
  - Global service
- Config
  - Record configuration changes
  - Evaluate resources against compliance rules
  - Get timeline of changes and compliance
