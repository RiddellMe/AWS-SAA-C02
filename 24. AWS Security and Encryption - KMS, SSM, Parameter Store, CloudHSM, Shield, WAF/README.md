## Encryption in flight (SSL)
- Data is encrypted before sending and encrypted after receiving
- SSL certificates help with encryption (HTTPS)
- Encryption in flight ensures no MITM (man in the middle attack) can happen

## Server side encryption at rest
- Data is encrypted after being received by the server
- Data is decrypted before being sent back to client
- It is stored in an encrypted form thanks to a key (usually a data key)
- The encryption/decryption keys must be managed somewhere and the server must have access to it

## Client side encryption
- Data is encrypted by the client (us) and never decrypted by the server
- Data will be decrypted by a receiving client
- The serer should NOT be able to decrypt the data
- Could leverage Envelope Encryption

## KMS (Key Management Service)
- Anytime you hear 'encryption' for an AWS service, it's most likely KMS
- Easy way to control access to your data, AWS manages keys for us
- Fully integrated with IAM for authorization
- Seamlessly integrated into:
  - Amazon EBS: encrypt volumes
  - Amazon S3: Server side encryption of objects
  - Amazon Redshift: encryption of data
  - Amazon RDS: encryption of data
  - Amazon SSM: Parameter store
  - etc...
- You can also use the CLI/SDK to leverage KMS
- Customer Master Key (CMK) Types
  - Symmetric (AES-256 keys)
    - First offering of KMS, single encryption key that is used to encrypt AND decrypt
    - AWS services that are integrated with KMS use Symmetric CMKs
    - Necessary for envelope encryption
    - You never get access to the key unencrypted (must call KMS API to use)
  - Asymmetric (RSA & ECC key pairs)
    - Public (encrypt) and private key (decrypt) pair
    - Used for encrypt/decrypt, or sign/verify operations
    - The public key is downloadable, but you can't access the private key unencrypted
    - Use case: encryption outside of AWS by users who can't call the KMS API

### AWS KMS
- Able to fully manage the keys & policies:
  - Create
  - Rotation policies
  - Disable
  - Enable
- Able to audit key usage (using CloudTrail)
- Three types of Customer Master Keys (CMK):
  - AWS Managed Service Default CMK: free
  - User Keys created in KMS: $1/month
  - User Keys imported (must be 256-bit symmetric key): $1/months
- ...and pay for API call to KMS ($0.03/10000 calls)

### AWS KMS 101
- Anytime you need to share sensitive information... use KMS
  - Database passwords
  - Credentials to external service
  - Private Key of SSL certificates
- The value in KMS is that the CMK used to encrypt data can never be retrieved by the user, and the CMK can be rotated for extra security
- Never ever store your secrets in plaintext, especially in your code
- Encrypted secrets can be stored in the code/environment variables
- KMS can only help in encrypting up to 4KB of data per call
- If data > 4KB, use envelope encryption
- To give access to KMS to someone:
  - Make sure the Key Policy allows the user
  - Make sure the IAM Policy allows the API calls

### KMS Key Policies
- Control access to KMS keys, "similar" to S3 bucket policies
- Difference: cannot control access without them
- Default KMS Key Policy:
  - Created if you don't provide a specific KMS Key Policy
  - Complete access to the key to the root user = entire AWS account
  - Give access to the IAM policies to the KMS key
- Custom KMS Key Policy:
  - Define users, roles that can access the KMS key
  - Define who can administer the key
  - Useful for cross-account access of your KMS key

### Copying Snapshots across accounts
1. Create a Snapshot, encrypted with your own CMK
2. Attach a KMS Key Policy to authorize cross-account access
3. Share the encrypted snapshot
4. (in target) Create a copy of the snapshot, encrypt it with a KMS key in your account
5. Create a volume from the snapshot

## KMS Automatic Key Rotation
- For Customer-managed CMK (not AWS managed CMK)
- If enabled: automatic key rotations happens **every 1 year**
- Previous key is kept active so you can decrypt old data
- New key has the same CMK ID (only the backing key is changed)

### KMS Manual Key Rotation
- When you want to rotate key every 90 days, 180 days etc...
- New key has a different CMK ID
- Keep the previous key active so you can decrypt old data
- Better to use aliases in this case (to hide the change of key for the application)
- Good solution to rotate CMK that are not eligible for automatic rotation (like asymmetric CMK)

## SSM Parameter Store
- Secure storage for configuration and secrets
- Optional Seamless Encryption using KMS
- Serverless, scalable, durable, easy SDK
- Version tracking of configurations/secrets
- Configuration management using path & IAM
- Notification with CloudWatch Events
- Integration with CloudFormation

### Parameters Policies (for advanced parameters)
- Allow to assign a TTL to a parameter (expiration date) to force updating or deleting sensitive data such as passwords
- Can assign multiple policies at a time

## AWS Secrets Manager
- Newer service, meant for storing secrets
- Capability to force rotation of secrets every X days
- Automate generation of secrets on rotation (uses Lambda)
- Integration with Amazon RDS (MySQL, PostgreSQL, Aurora)
- Secrets are encrypted using KMS
- Mostly meant for RDS integration

## CloudHSM
- KMS -> AWS manages the software for encryption
- CloudHSM -> AWS provisions encryption hardware
- Dedicated Hardware (HSM = Hardware Security Module)
- You manage your own encryption keys entirely (not AWS)
- HSM device is tamper resistant, FIPS 140-2 Level 3 compliance
- Supports both symmetric and asymmetric encryption (SSL/TLS keys)
- No free tier available
- Must use the CloudHSM client software
- Redshift supports CloudHSM for database encryption and key management
- Good option to use with SSE-C encryption
- IAM permissions:
  - CRUD an HSM Cluster
- CloudHSM Software:
  - Manage the keys
  - Manage the users
- High Availability
  - CloudHSM clusters are spread across Multi AZ (HA)
  - Great for availability and durability

## Shield - DDoS Protection
- AWS Shield Standard:
  - Free service that is activated for every AWS customer
  - Provides protection from attacks such as SYN/UDP Floods, Reflection attacks, and other layer 3/layer 4 attacks
- AWS Shield Advanced:
  - Optional DDoS mitigation service ($3,000 per month per organization)
  - Protect against more sophisticated attack on Amazon EC2, Elastic Load Balancing (ELB), Amazon CloudFront, AWS Global Accelerator, and Route 53
  - 24/7 access to AWS DDoS response team (DRP)
  - Protect against higher fees during usage spikes due to DDoS

## AWS WAF - Web Application Firewall
- Protects your web application from common web exploits (Layer 7)
- Layer 7 is HTTP (vs Layer 4, which is TCP)
- Deploy on **Application Load Balancer, API Gateway, CloudFront**
- Define Web ACL (Web Access Control List):
  - Rules can include: IP addresses, HTTP headers, HTTP body, or URI strings
  - Protects from common attack - SQL injection and Cross-Site Scripting (XSS)
  - Size constraints (on queries)
  - Geo-match (block countries)
  - Rate-based rules (to count occurrences of events) - for DDoS protection

### AWS Firewall Manager
- Manage rules in all accounts of an AWS Organization
- Common set of security rules
- WAF rules (Application Load Balancer, API Gateways, CloudFront)
- AWS Shield Advanced (ALB, CLB, Elastic IP, CloudFront)
- Security Groups for EC2 and ENI resources in VPC

## Amazon GuardDuty
- Intelligent threat discovery to protect AWS account
- Uses machine learning algorithms, anomaly detection, 3rd party data
- One click to enable (30 days trial), no need to install software
- Input data includes:
  - CloudTrail logs: unusual API calls, unauthorized deployments
  - VPC Flow Logs: unusual internal traffic, unusual IP addresses
  - DNS Logs: compromised EC2 instances sending encoded data within DNS queries
- Can set up CloudWatch Event rules to be notified in case of findings
- CloudWatch Events rules can target AWS Lambda or SNS
- Can protect against CryptoCurrency attacks (has a dedicated 'finding' for it)

## Amazon Inspector
- Automated Security Assessments for EC2 instances
- Analyze the running OS against known vulnerabilities
- Analyze against unintended network accessibility
- AWS Inspector Agent must be installed on OS in EC2 instances
- After the assessment, you get a report with a list of vulnerabilities
- Possibility to send notifications to SNS

### What does AWS Inspector evaluate
- Remember: only for EC2 instances
- For Network assessments: (agentless)
  - Network reachability
- For Host assessments: (with agent)
  - Common vulnerabilities and exposures
  - Center for Internet Security (CIS) Benchmarks
  - Security best practices

## Amazon Macie
- Amazon Macie is a fully managed data security and data privacy service that uses machine learning and pattern matching to discover and protect your sensitive data in AWS
- Macie helps identify and alert you to sensitive data, such as personally identifiable information (PII)

## Security & Compliance 
- AWS Shared Responsibility Model
  - AWS Responsibility - Security **of** the Cloud
    - Protecting infrastructure (hardware, software, facilities, and networking) that runs all the AWS services
    - Managed services like S3, DynamoDB, RDS, etc...
  - Customer responsibility - Security **in** the cloud
    - For EC2 instance, customer is responsible for management of the guest OS (including security patches and updates), firewall, and network configuration, IAM
    - Encrypting application data
  - Shared controls:
    - Patch management, configuration management, awareness & training

### RDS Example
- AWS responsibility:
  - Manage the underlying EC2 instance, disable SSH access
  - Automated DB patching
  - Automated OS patching
  - Audit the underlying instance and disks & guarantee it functions
- Your responsibility:
  - Check the ports/IP/security group inbound rules in DB's SG
  - In-database user creation and permissions
  - Creating a database with or without public access
  - Ensure parameter groups in DB is configured to only allow SSL connections
  - Database encryption setting

### S3 Example
- AWS responsibility:
  - Guarantee unlimited storage
  - Guarantee encryption
  - Ensure separation of the data between different customers
  - Ensure AWS employees can't access your data
- Your responsibility:
  - Bucket configuration
  - Bucket policy/public setting
  - IAM user and roles
  - Enabling encryption
  - 
