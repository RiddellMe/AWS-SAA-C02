#!/bin/bash

yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Hello World from $(hostname -f) (loaded using [ec2-user-data.sh])</h1>" > /var/www/html/index.html
