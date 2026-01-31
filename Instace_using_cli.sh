#!/bin/bash
############################################################################
# This script will launch a new EC2 instance using AWS CLI.
aws ec2 run-instances \
  --image-id ami-04233b5aecce09244 \
  --instance-type t3.micro \
  --key-name keypair \
  --count 1 \
  --network-interfaces '[
    {
      "DeviceIndex": 0,
      "SubnetId": "subnet-079832abdf54fd1f0",
      "AssociatePublicIpAddress": true,
      "Groups": ["sg-00c13574c643564b1"]
    }
  ]' \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=MyPublicEC2}]'
--region us-east-1