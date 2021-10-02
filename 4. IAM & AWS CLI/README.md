# IAM: Users, Groups & Policies
- Global service
- Groups can only contain users
- Users can belong to 0 to many groups
- Users or Groups can be assigned JSON documents called policies
- Policies define permissions of the users
- Apply <b>least privilege principle</b>
- One AWS account can have many users

## Policies
- Version: Policy language version
- Id: identifier for the policy (optional)
- Statements
  - Sid: identifier for the statement (optional)
  - Effect: whether statement allows or denies (Allow, Deny)
  - Principal: Account/user/role to which this policy is applied to
  - Action: List of API calls the policy allows or denies
  - Resource: List of resource to which the actions apply to
  - Condition: Conditions for when this policy is in effect (optional)

## Password Policy
- Provides mechanisms to change password policy such as minimum password length, include numbers, special characters, uppercase etc

## MFA
- Users have access to the AWS account and can potentially change configurations and delete resources in the AWS account
- You want to protect your root account and IAM users
- MFA = password + security device
- MFA devices:
  - Virtual MFA device (google authenticator, authy)
  - Universal 2nd Factor (U2F) security key (physical key, such as YubiKey)
  - Hardware key fob MFA device (such as Gemalto, SurePassID)

## AWS IAM Roles (for services)
- Some AWS service will need to perform actions on your behalf
- To do this, we assign permissions to AWS services with <b>IAM Roles</b>
- IAM Roles are like users for AWS services
- EC2 instance (virtual server) may want to perform some action on AWS. We must give permissions to our EC2 instance.
- Common roles:
  - EC2 instance roles
  - Lambda function roles
  - Roles for CloudFormation

## IAM Security Tools
- IAM Credentials Report (account-level)
  - Report that lists all your account's users and the status of their various credentials
- IAM Access Advisor (user-level)
  - Shows the service permissions granted to a user and when those services were last accessed
  - Can use this information to revise policies (least privilege principle)

## IAM Best practices
- Do not use the root account except for AWS account setup
- One physical user = One AWS user (do not share creds)
- Assign users to groups and assign permissions to groups
- Strong password policy
- Use and enforce MFA
- Create and use roles for AWS service permissions
- Use access keys for programmatic access (using CLI or SDK)
- Audit permissions of your account with the IAM Credentials Report
