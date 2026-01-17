#!/bin/bash

#############################################################################
# This script will provide the list of all the resources in the AWS account.
# Author: Pawan Kumar Safi
# Version: 1.0
#
# Below  are the AWS resources that will be listed by this script:
# 1. EC2 Instances
# 2. S3 Buckets
# 3. RDS Instances
# 4. Lambda Functions
# 5. VPCs
# 6. EBS
# 7. Route53
# 8. CloudFront 
# 9. IAM Users
# 10. CloudFormation
# 11. SNS Topics
# 12. SQS Queues
# 13. DynamoDB Tables
# 14. CloudWatch 
# 15. Elastic Load Balancers
#
# The script will prompt the user to enter the AWS region and the service for which the resources need to be listed. 
#
# usage: ./aws_resources_automation.sh <aws-region> <aws-service>
# Example: ./aws_resources_automation.sh us-east-1 ec2
############################################################################## 

#check if the required number of arguments are provided 
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <aws-region> <aws-service>"
    exit 1
fi

# Assign the arguments to variables and convert service name to lowercase
aws_region=$1
aws_service=$2
aws_service=$(echo $2 | tr '[:upper:]' '[:lower:]')

# checking for aws cli installation
if ! command -v aws &> /dev/null; then
    echo "AWS CLI could not be found. Please install it to proceed."
    exit 1
fi

# Checking for aws cli configuration
if [ ! -d ~/.aws ]; then 
    echo "AWS CLI is not configured. Please configure it using 'aws configure' command."
    exit 1
fi

# List the resources based on the service
case $aws_service in
    ec2)
        echo "Listing EC2 Instances in $aws_region"
        aws ec2 describe-instances --region $aws_region
        ;;
    rds)
        echo "Listing RDS Instances in $aws_region"
        aws rds describe-db-instances --region $aws_region
        ;;
    s3)
        echo "Listing S3 Buckets in $aws_region"
        aws s3api list-buckets --region $aws_region
        ;;
    cloudfront)
        echo "Listing CloudFront Distributions in $aws_region"
        aws cloudfront list-distributions --region $aws_region
        ;;
    vpc)
        echo "Listing VPCs in $aws_region"
        aws ec2 describe-vpcs --region $aws_region
        ;;
    iam)
        echo "Listing IAM Users in $aws_region"
        aws iam list-users --region $aws_region
        ;;
    route5)
        echo "Listing Route53 Hosted Zones in $aws_region"
        aws route53 list-hosted-zones --region $aws_region
        ;;
    cloudwatch)
        echo "Listing CloudWatch Alarms in $aws_region"
        aws cloudwatch describe-alarms --region $aws_region
        ;;
    cloudformation)
        echo "Listing CloudFormation Stacks in $aws_region"
        aws cloudformation describe-stacks --region $aws_region
        ;;
    lambda)
        echo "Listing Lambda Functions in $aws_region"
        aws lambda list-functions --region $aws_region
        ;;
    sns)
        echo "Listing SNS Topics in $aws_region"
        aws sns list-topics --region $aws_region
        ;;
    sqs)
        echo "Listing SQS Queues in $aws_region"
        aws sqs list-queues --region $aws_region
        ;;
    dynamodb)
        echo "Listing DynamoDB Tables in $aws_region"
        aws dynamodb list-tables --region $aws_region
        ;;
    ebs)
        echo "Listing EBS Volumes in $aws_region"
        aws ec2 describe-volumes --region $aws_region
        ;;
    *)
        echo "Invalid service. Please enter a valid service."
        exit 1
        ;;
esac