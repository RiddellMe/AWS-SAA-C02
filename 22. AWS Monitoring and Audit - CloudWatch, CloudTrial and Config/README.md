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
- Alarms can be created  based on CloudWatch Logs Metrics Filters
- To test alarms and notifications, set the alarm state to Alarm using CLI


