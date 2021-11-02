## AWS STS - Security Token Service
- Allows you to grant limited and temporary access to AWS resources
- Token is valid for up to one hour (must be refreshed)
- AssumeRole
  - Within your own account: for enhanced security
  - Cross account access: assume role in target account to perform actions there
- AssumeRoleWithSAML
  - return credentials for users logged with SAML
- AssumeRoleWithWebIdentity
  - return creds for users logged with an IdP (Facebook login, Google login, OIDC compatible)
  - AWS recommends against using this, and using Cognito instead
- GetSessionToken
  - For MFA, from a user or AWS account root user

### Using STS to assume a role
- Define an IAM Role within your account or cross-account
- Define which principals can access this IAM Role
- Use AWS STS (Security Token Service) to retrieve credentials and impersonate the IAM Role you have access to (AssumeRole API)
- Temporary credentials can be valid between 15 minutes to 1 hour

## Identity Federation in AWS
- Federation lets users outside of AWS to assume temporary role for accessing AWS resources
- These users assume identity provided access role
- Federations can have many flavors:
  - SAML 2.0
  - Custom Identity Broker
  - Web Identity Federation with Amazon Cognito
  - Web Identity Federation without Amazon Cognito
  - Single Sign On
  - Non-SAML with AWS Microsoft AD
- Using federation, you don't need to create IAM users (user management is outside of AWS)

### SAML 2.0 Federation
- To integration Active Directory/ADFS with AWS (or any SAML 2.0)
- Provides access to AWS Console or CLI (through temporary creds)
- No need to create an IAM user for each of your employees
- Active Directory FS
  - Same process as with any SAML 2.0 compatible IdP
- Needs to set up a trust between AWS IAM and SAML (both ways)
- SAML 2.0 enables web-based, cross domain SSO
- Uses the STS API: AssumeRoleWithSAML
- Note: federation through SAML is the 'old way' of doing things
- Amazon Single Sign On (SSO) Federation is the new managed, and simpler way

### Custom identity Broker Application
- Use only if identity provider is not compatible with SAML 2.0
- The identity broker must determine the appropriate IAM policy
- Uses the STS API: AssumeRole or GetFederationToken

### Web Identity Federation - AssumeRoleWithWebIdentity
- Not recommended by AWS - use Cognito instead (allows for anonymous users, data synchronization, MFA)

### AWS Cognito
- Goal:
  - Provide direct access to AWS resources from the client side (mobile, web app)
- Example:
  - Provide (temporary) access to write to S3 bucket using Facebook Login
- Problem:
  - We don't want to create IAM users for our app users
- How:
  - Log in to federated identity provider - or remain anonymous
  - Get temporary AWS credentials back from the Federated Identity Pool
  - These credentials come with a pre-defined IAM policy stating their permissions

## What is Microsoft Active Directory (AD)
- Found on any Windows Server with AD Domain Services
- Database of objects: User accounts, computers, printers, file shares, security groups
- Centralized security management, create account, assign permissions
- Objects are organized in trees
- A group of trees is a forest

### AWS Directory Services
- AWS Managed Microsoft AD
  - Create your own AD in AWS, manage users locally, supports MFA
  - Establish "trust" connections with your on-premise AD
- AD Connector
  - Directory Gateway (proxy) to redirect to on-premise AD
  - Users are managed on the on-premise AD
- Simple AD
  - AD-compatible managed directory on AWS
  - Cannot be joined with on-premise AD

## AWS Organizations
- Global service
- Allows to manage multiple AWS accounts
- The main account is the master account - you can't change it
- Other accounts are member accounts
- Member accounts can only be part of one organization
- Consolidated billing across all accounts - single payment method
- Pricing benefits from aggregated usage (volume discount for EC2, S3...)
- Beneficial to federate all accounts into one organization to pay less/simplify billing methods
- API is available to automate AWS account creation

### Multi Account Strategies
- Create account per department, per cost center, per dev/test/prod, based on regulatory restrictions (using SCP), for better resource isolation (ex: VPC), to have separate per-account service limits, isolated account for logging
- Multi account vs one account multi VPC
- Use tagging standard for billing purposes
- Enable CloudTrail on all accounts, send logs to central S3 account
- Send CloudWatch logs to central logging account
- Establish cross account roles for admin purposes

### Service Control Policies (SCP)
- Whitelist or blacklist IAM actions
- Applied at the OU or Account level
- Does not apply to the Master Account
- SCP is applied to all the Users and Roles of the account, including Root
- The SCP does not affect service-linked roles
  - Service-linked roles enable other AWS services to integrate with AWS Organization and can't be restricted by SCPs
- SCP must have an explicit Allow (does not allow anything by default)
- Use cases:
  - Restrict access to certain services (for example: can't use EMR)
  - Enforce PCI compliance by explicitly disabling services

### AWS Organization - Moving accounts
- To migrate accounts from one org to another:
  1. Remove the member account from the old org
  2. Send an invite to the new org
  3. Accept the invite to the new org from the member account
- If you want the master account of the old organization to also join the new org, do the following:
  1. Remove the member accounts from the organizations using procedure above
  2. Delete the old org
  3. Repeat the process above to invite the old master account to the new org


## IAM roles vs Resource based policies
- Attach a policy to a resource (example: S3 bucket policy) vs using a role as a proxy to access S3 bucket
- When you assume a role (user, application, or service), you give up your original permissions and take the permissions assigned to the role
- When using a resource based policy, the principal doesn't have to give up their permissions
- Ex: User in account A needs to scan a DynamoDB table in account A, and then dump it in an S3 bucket in account B
  - This is a good use case for a resource based policy
- Resource based policies are supported by: Amazon S3 buckets, SNS topics, SQS queues

## IAM Permission Boundaries
- IAM Permission Boundaries are supported for users and roles (not groups)
- Advanced feature to use a managed policy to set the maximum permissions an IAM entity can get
- Can be used in combinations of AWS Organizations SCP
- Use cases:
  - Delegate responsibilities to non administrators within their permission boundaries, for example to create new IAM users
  - Allow developers to self-assign policies and manage their own permissions, while making sure they can't 'escalate' their privileges (such as make themselves admin)
  - Useful to restrict one specific user (instead of a whole account using Organizations & SCP)

## AWS Resource Access Manager (RAM)
- Share AWS resources that you own with other AWS accounts
- Share with any account or within your Organization
- Avoid resource duplication
- VPC Subnets:
  - allow to have all the resources launched in the same subnets
  - must be from the same AWS Organizations
  - cannot share security groups and default VPC
  - participants can manage their own resources in there
  - participants can't view, modify, or delete resources that belong to other participants or the owner
- AWS Transit Gateway
- Route53 Resolver Rules
- License Manager Configurations

### Resources Access Manager - VPC example
- Each account...
  - is responsible for it's own resources
  - cannot view, modify, or delete other resources in other accounts
- The network is shared, so...
  - Anything deployed in the VPC can talk to other resources in the VPC
  - Applications are accessed easily across accounts, using private ip
  - Security groups from other accounts can be references for maximum security

## AWS Single Sign-On (SSO)
- Centrally manage Single Sign-On to access multiple accounts and 3rd party business applications
- Integrated with AWS Organizations
- Supports SAML 2.0 markup
- Integration with on-premises Active Directory
- Centralized permission management
- Centralized auditing with CloudTrail


