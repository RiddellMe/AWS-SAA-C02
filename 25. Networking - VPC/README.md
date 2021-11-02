## Understanding CIDR - IPv4
- Classless Inter-Domain Routing - a method for allocating IP addresses
- Used in Security Groups rule and AWS networking in general
- They help to define an IP address range:
  - WW.XX.YY.ZZ/**32** -> One IP
  - 0.0.0.0/**0** -> All IPs
  - But we can define: 192.168.0.0/**26** -> 192.168.0.0 - 192.168.0.63 (64 IP addresses)
- A CIDR consists of two components
  - Base IP
    - Represents an IP contained in the range (XX.XX.XX.XX)
    - Example: 10.0.0.0, 192.168.00...
  - Subnet Mask
    - Defines how many bits can change in the IP
    - Example: /0, /24, /32
    - Forms:
        - /8 <-> 255.0.0.0
        - /16 <-> 255.255.0.0
        - /24 <-> 255.255.255.0
        - /32 <-> 255.255.255.255

### Understanding CIDR - Subnet Mask
- The subnet mask basically allows part of the underlying IP to get additional next values from the base IP

### Public vs Private IP (IPv4)
- The Internet Assigned Numbers Authority (IANA) established certain blocks of IPv4 addresses for the use of private (LAN) and public (Internet) addresses
- Private IP can only allow certain values:
  - 10.0.0.0 - 10.255.255.255 (10.0.0.0/8) in big networks
  - 172.16.0.0 - 172.31.255.255 (172.16.0.0/12) AWS default VPC in that range
  - 192.168.0.0 - 192.168.255.255 (192.168.0.0/16) e.g. home networks
- All the rest of the IP addresses on the internet are public

## Default VPC Walkthrough
- All new AWS accounts have a default VPC
- New EC2 instances are launched into the default VPC if no subnet is specified
- Default VPC has internet connectivity and all EC2 instances inside it have public IPv4 addresses
- We also get public and a private IPv4 DNS names
- Best practice to create your own VPC

## VPC in AWS - IPv4
- VPC = Virtual Private Cloud
- You can have multiple VPCs in an AWS region (max 5 per region - soft limit)
- Max CIDR per VPC is 5, for each CIDR:
  - Min size is /28 (16 IP addresses)
  - Max size is /16 (65536 IP addresses)
- Because VPC is private, only the private IPv4 ranges are allowed:
  - 10.0.0.0 - 10.255.255.255 (10.0.0.0/8)
  - 172.16.0.0 - 172.31.255.255 (172.16.0.0/12)
  - 192.168.0.0 - 192.168.255.255 (192.168.0.0/16)
- Your VPC CIDR should NOT overlap with your other networks (e.g. corporate)

## VPC - Subnet (IPv4)
- AWS reserves 5 IP addresses (first 4 and last 1) in each subnet
- These 5 IP addresses are not available for use and can't be assigned to an EC2 instance
- Example: if CIDR block 10.0.0.0/24, then reserved IP addresses are:
  - 10.0.0.0 - Network Address
  - 10.0.0.1 - reserved by AWS for the VPC router
  - 10.0.0.2 - reserved by AWS for mapping to Amazon-provided DNS
  - 10.0.0.3 - reserved by AWS for future use
  - 10.0.0.255 - Network Broadcast Address. AWS does not support broadcast in a VPC, therefore the address is reserved
- If you need 29 IP addresses for EC2 instances:
  - You can't choose a subnet of size /27 (32 IP addresses, 32-5 = 27)
  - You need to choose a subnet of size /26 (64 IP addresses, 64-5 = 59)

## Internet Gateway (IGW)
- Allows resources (e.g. EC2 instances) in a VPC connect to the internet
- It scales horizontally and is highly available and redundant
- Must be created from a VPC
- One VPC can only be attached to one IGW and vice versa
- Internet Gateways on their own do not allow internet access
- Route tables must also be edited!

## Bastion Hosts
- We can use a Bastion Host to SSH into our private EC2 instances
- The bastion is in the public subnet which is then connected to all other private subnets
- Bastion Host security group must be tightened
- Make sure the bastion host only has port 22 traffic from the IP address you need, not from the security groups of your other EC2 instances

## NAT Instance (outdated)
- NAT = Network Address Translation
- Allows EC2 instances in private subnets to connect to the internet
- Must be launched in a public subnet
- Must disable EC2 setting: Source/destination Check
- Must have Elastic IP (or ENI?) attached to it
- Route tables must be configured to route traffic from private subnets to the NAT Instance
- Pre-configured Amazon Linux AMI is available
  - Reached the end of standard support on December 31, 2020
- Not highly available/resilient setup out of the box
  - You need to create in ASG in multi-AZ + resilient user-data script
- Internet traffic bandwidth depends on EC2 instance type
- You must manage Security Groups & rules:
  - Inbound:
    - Allow HTTP/HTTPS traffic coming from Private Subnets
    - Allow SSH from your home network (access is provided through Internet Gateway)
  - Outbound:
    - Allow HTTP/HTTPS traffic to the internet

## NAT Gateway 
- AWS managed NAT, higher bandwidth, high availability, no administration
- Pay per hour for usage and bandwidth
- NATGW is created in a specific Availability Zone, uses an Elastic IP (or ENI?)
- Can't be used by EC2 instance in the same subnet (only from other subnets)
- Requires an IGW (Private Subnet -> NATGW -> IGW)
- 5 GBPS of bandwidth with automatic scaling up to 45 GBPS
- No Security Groups required to manage

### NAT Gateway with High Availability
- NAT Gateway is resilient within a single Availability Zone
- Must create multiple NAT Gateways in multiple AZs for fault-tolerance
- There is no cross-AZ failover needed because in an AZ goes down, it doesn't need NAT (the EC2 instances are down, so how can they communicate outside their AZ)

## DNS Resolution in VPC
- DNS Resolution (enableDnsSupport)
  - Decides if DNS resolution from Route 53 Resolver server is supported for the VPC
  - True (default): it queries the Amazon Provider DNS Server at 169.254.169.253 or the reserved IP address at the base of the VPC IPv4 network range plus two (.2)
- DNS Hostnames (enableDnsHostnames)
  - By default:
    - True -> default VPC
    - False -> newly created VPC
    - Won't do anything unless enableDnsSupport=true
    - If true, assigns public hostname to EC2 instance if it has a public IPv4
- If you use custom DNS domain names in a Private Hosted Zone in Route 53, you must set both these attributes (enableDnsSupport & enableDnsHostname) to true

## Security Groups & NACLs (Network ACLs)
- NACL are stateless
- NACL are like a firewall which control traffic from and to **subnets**
- One NACL per subnet, new subnets are assigned the Default NACL
- You define NACL rules:
  - Rules have a number (1-32766), higher precedence with a lower number
  - First rule match will drive the decision
  - Example: If you define #100 ALLOW 10.0.0.10/32 and #200 DENY 10.0.0.10/32, the IP address will be allowed because 100 has a higher precedence than 200
  - The last rule is an asterisk (*) and denies a request in case of no rule match
  - AWS recommends adding rules by increment of 100
- Newly created NACLs will deny everything
- NACL are a great way of blocking a specific IP address at the subnet level

### Default NACL
- Accepts everything inbound/outbound with the subnets it's associated with
- Do NOT modify the Default NACL, instead create custom NACLs

### Ephemeral Ports
- For any two endpoints to establish a connection, they must use ports
- Clients connect to a **defined port**, and expect a response on an **ephemeral port**
- Different OS use different port ranges, examples:
  - IANA & MS Windows 10 -> 49152 - 65535
  - Many Linux Kernels -> 32768-60999

## VPC - Reachability Analyzer
- A network diagnostics tool that troubleshoots network connectivity between two endpoints in your VPC(s)
- It builds a model of the network configuration, then checks the reachability based on these configurations (it doesn't send packets)
- When the destination is
  - Reachable - it produces hop-by-hop details of the virtual network path
  - Not reachable - it identifies the blocking component(s) - e.g. configuration issues in SGs, NACLs, Route Tables...
- Use cases: troubleshoot connectivity issues, ensure network configuration is as intended...

## VPC Peering
- Privately connect two VPCs using AWS' network
- Make them behave as if they were in the same network
- Must not have overlapping CIDRs
- VPC Peering connection is NOT transitive (must be established for each VPC that need to communicate with one another)
- You must update route tables in **each VPC's subnets** to ensure EC2 instances can communicate with each other
- You can create VPC Peering connection between VPCs in different AWS accounts/regions
- You can reference a security group in a peered VPC (works cross accounts - same region)

## VPC Endpoints (AWS PrivateLink)
- Every AWS service is publicly exposed (public URL)
- VPC Endpoints (powered by AWS PrivateLink) allows you to connect to AWS services using a private network instead of using the public internet
- They're redundant and scale horizontally
- They remove the need of IGW, NATGW... etc, to access AWS services
- In case of issues:
  - Check DNS setting resolution in your VPC
  - Check Route Tables
- Types of Endpoints:
  - Interface Endpoints
    - Provisions an ENI (private IP address) as an entry point (must attach a Security Group)
    - Supports most AWS services
  - Gateway Endpoints
    - Provisions a gateway and must be used as a target in a route table
    - Supports both S3 and DynamoDB

## VPC Flow Logs
- Capture information about IP traffic going into your interfaces:
  - VPC Flow Logs
  - Subnet Flow Logs
  - Elastic Network Interface (ENI) Flow Logs
- Helps to monitor & troubleshoot connectivity issues
- Flow logs data can go to S3/CloudWatch Logs
- Captures network information from AWS managed interfaced too: ELB, RDS, ElastiCache, Redshift, WorkSpaces, NATGW, Transit Gateway

### VPC Flow Logs Syntax
- srcaddr & dstaddr - help identify problematic IP
- srcport & dstport - helps identify problematic port
- Action - success or failure of the request due to Security Group/NACL
- Can be used for analytics on usage patterns, or malicious behaviour
- Query VPC flow logs using Athena on S3 or CloudWatch Logs Insight

### Troubleshoot SG & NACL issues
- Incoming Requests
  - Inbound REJECT -> NACL or SG
  - Inbound ACCEPT, Outbound REJECT -> NACL (as SG is stateful)
- Outgoing Requests
  - Outbound REJECT -> NACL or SG
  - Outbound ACCEPT, Inbound REJECT -> NACL

## AWS Site-to-Site VPN
- Virtual Private Gateway (VPW)
  - VPN concentrator on the AWS side of the VPN connection
  - VGW is created and attached to the VPC from which you want to create the Site-to-Site connection
  - Possibility to customize the ASN (Autonomous System Number)
- Customer Gateway (CGW)
  - Software application or physical device on customer side of the VPN connection

### Site-to-Site VPN Connections
- Customer Gateway Device (on-premises)
  - What IP address to use?
    - Public Internet-routable IP address for your Customer Gateway Device
    - If it's behind a NAT device that's enabled for NAT traversal (NAT-T), use the public IP address of the NAT device
- Important step: enable **Route Propagation** for the Virtual Private Gateway in the route table that is associated with your subnets
- If you need to ping your EC2 instances from on-premises, make sure you add the ICMP protocol on the inbound of your security groups

### AWS VPN CloudHub
- Provide secure communication between multiple sites, if you have multiple VPN connections
- Low-cost hub-and-spoke model for primary or secondary network connectivity between different locations (VPN only)

## Direct Connect (DX)
- Provides a dedicated private connection from a remote network to your VPC
- Dedicated connection must be setup between your DC and AWS Direct Connect locations
- You need to setup a Virtual private Gateway on your VPC
- Access public resources (S3) and private (EC2) on the same connection
- Use cases:
  - Increase bandwidth throughput - working with large data sets - lower cost
  - Most consistent network experience - applications using real-time data feeds
  - Hybrid Environments (on prem + cloud)
- Supports both IPv4 and IPv6

### Direct Connect Gateway
- If you want to setup a Direct Connect to one or more VPC in many different regions (same account), you must use a Direct Connect Gateway

### Direct Connect - Connection Types
- Dedicated Connections: 1Gbps and 10Gbps capacity
  - Physical ethernet port dedicated to a customer
  - Request made to AWS first, then completed by AWS Direct Connect Partners
- Hosted Connections: 50Mbps, 500Mbps, to 10Gbps,
  - Connection requests are made via AWS Direct Connect Partners
  - Capacity can be added or removed on demand
  - 1,2,5,10 Gbps available at select AWS Direct Connect Partners
- Lead times are often longer than 1 month to establish a new connection

### Direct Connect - Encryption
- Data in transit is not encrypted but it is private
- AWS Direct Connect + VPN provides an IPsec-encrypted private connection
- Good for an extra level of security, but slightly more complex to put in place

## Exposing services in your VPC to other VPC
- Option 1: Make it public
  - Goes through the public www
  - Tough to manage access
- Option 2: VPC peering
  - Must create many peering relations
  - Opens the whole network

### AWS PrivateLink (VPC Endpoint Services)
- Most secure & scalable to expose a service to 1000s of VPC (own or other accounts)
- Does not require VPC peering, internet gateway, NAT, route tables
- Requires a network load balancer (Service VPC) and ENI (Customer VPC) or GWLB
- If the NLB is in multiple AZ, and the ENIs in multiple AZ, the solution is fault tolerant

## AWS Classic & AWS ClassicLink (deprecated)
- EC2-Classic: instances run in a single network shared with other customers
- Amazon VPC: your instances run logically isolated to your AWS account
- ClassicLink allows you to link EC2-Classic instances to a VPC in your account
  - Must associate a security group
  - Enabled communication using private IPv4 addresses
  - Removes the need to make use of public IPv4 addresses or Elastic IP addresses

## Transit Gateway
- For having transitive peering between thousands of VPC and on-premises, hub-and-spoke (star) connection
- Regional resource, can work cross-region
- Share cross-account using Resource Access Manager (RAM)
- You can peer Transit Gateways across regions
- Route Tables: limit which VPC can talk with other VPC
- Works with Direct Connect Gateway, VPN connections
- Supports IP Multicast (not supported by any other AWS service)

### Transit Gateway: Site-to-Site VPN ECMP
- ECMP = Equal-cost multi-path routing
- Routing strategy to allow to forward a packet over multiple best path
- Use case: create multiple Site-to-Site VPN connections to increase the bandwidth of your connections to AWS
- VPN to virtual private gateway:
  - 1 connection to 1 VPC at 1.25Gbps
  - VPN is made up of 2 tunnels
- VPN to transit gateway:
  - 1 connection to many VPC at 2.5Gbps (ECMP) - 2 tunnels used
  - Can add more connections to double/triple throughput via ECMP

## VPC - Traffic Mirroring
- Allows you to capture and inspect network traffic in your VPC
- Route the traffic to security appliances that you manage
- Capture the traffic
  - From (Source) - ENIs
  - To (Targets) - an ENI or a Network Load Balancer
- Captures all packets or capture the packets of your interest (optionally, truncate packets)
- Source and Target can be in the same VPC or different VPCs (VPC Peering)
- Use cases: Content inspection, threat monitoring, troubleshooting

## IPv6 for VPC
- What is IPv6?
  - IPv4 designed to provide 4.3 billion addresses (they'll be exhausted soon)
  - IPv6 is the successor of IPv4
  - IPv6 is designed to provide 3.4*10^38 unique IP addresses
  - Every IPv6 address is public and internet-routable (no private range)
  - Format xx.xx.xx.xx.xx.xx.xx.xx (x is hexadecimal, range can be from 0000 to ffff)
- IPv4 cannot be disabled for your VPC and subnets
- You can enable IPv6 (they're public IP addresses) to operate in dual-stack mode
- Your EC2 instances will get at least a private internal IPv4 and a public IPv6
- They can communicate using either IPv4 or IPv6 to the internet through an Internet Gateway

## Egress-only Internet Gateway
- Used for IPv6 only
- Similar to a NAT Gateway but for IPv6
- Allows instances in your VPC outbound connections over IPv6 while preventing the internet to initiate an IPv6 connection to your instances
- You must update the Route Tables

## VPC Summary
- CIDR - IP Range
- VPC - Virtual Private CLoud -> we define a list of IPv4 & IPv6 CIDR
- Subnets - tire dto an AZ, we define a CIDR
- Internet Gateway - at the VPC level, provide IPv4 & IPv6 Internet Access
- Route Tables - must be edited to add routes form subnets to the IGW, VPC Peering Connections, VPC Endpoints...
- Bastion Host - public EC2 instance to SSH into, that has SSH connectivity to EC2 instances in private subnets
- NAT Instances - gives internet access to EC2 instances in private subnets. Old, mut be setup in a public subnet, disable Source/Destination check flag
- NAT Gateway - managed by AWS, provides scalable internet access to private EC2 instances, IPv4 only
- Private DNS + Route 53 - enable DNS Resolution + DNS Hostnames (VPC)
- NACL - stateless, subnet rules for inbound and outbound, don't forget Ephemeral Ports
- Security Groups - stateful, operate at the EC2 instance level
- Reachability Analyzer - perform network connectivity testing between AWS resources
- VPC Peering - connect two VPCs with non overlapping CIDR, non-transitive
- VPC Endpoints - provide private access to AWS Services (S3, DynamoDB, CloudFormation, SSM) within a VPC
- VPC Flow Logs - can be setup at the VPC/Subnet/ENI level, for ACCEPT and REJECT traffic, helps identifying attacks, analyze using Athena or CloudWatch Logs Insights
- Site-to-Site VPN - setup a Customer Gateway on DC, a Virtual Private Gateway on VPC, and site-to-site VPN over public internet
- AWS VPN CloudHub - hub-and-spoke VPN model to connect your sites
- Direct Connect - setup a Virtual Private Gateway on VPC, and establish a direct private connection to an AWS Direct Connect Location
- Direct Connect Gateway - setup a Direct Connect to many VPCs in different AWS regions
- AWS PrivateLink/VPC Endpoint Services:
  - Connect services privately from your service VPC to customers VPC
  - Doesn't need VPC Peering, public internet, NAT gateway, Route Tables,
  - Must be used with Network Load Balancer & ENI
- ClassicLink - connect EC2-Classic EC2 instances privately to your VPC
- Transit Gateway - transitive peering connections for VPC, VPN & DX
- Traffic Mirroring - copy network traffic from ENIs for further analysis
- Egress-only Internet Gateway - like a NAT Gateway, but for IPv6

## Networking Costs in AWS per GB
- Incoming traffic into EC2 is free
- Traffic between EC2 in same AZ is free if using private IP
- $0.02 if using Public IP / Elastic IP for EC2 to EC2 communication in different AZ. If using private IP, $0.01
- Inter-region EC2 to EC2 is $0.02
- Use private IP instead of public IP for good savings and better network performance
- Use same AZ for maximum savings (at the cost of high availability)

### Minimizing egress traffic network cost
- Egress traffic: outbound traffic (from AWS to outside)
- Ingress traffic: inbound traffic - frm outside to AWS (typically free)
- Try to keep as much internet traffic within AWS to minimize costs
- Direct Connect location that are co-located in the same AWS Region result in lower cost for egress network

### S3 Data Transfer Pricing (USA)
- S3 ingress: free
- S3 to Internet: $0.09 per GB
- S3 Transfer Acceleration:
  - Faster transfer times (50% to 500% faster)
  - Additional cost on top of Data Transfer Pricing: +$0.04 to $0.08 per GB
- S3 to CloudFront: $0.00 per GB
- CloudFront to Internet: $0.085 per GB (slightly cheaper than S3)
  - Caching capability (lower latency)
  - Reduce costs associated with S3 Requests Pricing (7x cheaper with CloudFront)
- S3 Cross Region Replication: $0.02 per GB

