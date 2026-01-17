#!/bin/bash
############################################################################
# This script will launch a new EC2 instance using AWS CLI.
aws ec2 run-instances \
  --image-id ami-0ecb62995f68bb549 \
  --instance-type t3.micro \
  --key-name keypair \
  --count 1 \
  --network-interfaces '[
    {
      "DeviceIndex": 0,
      "SubnetId": "subnet-0272e8c86474ba623",
      "AssociatePublicIpAddress": true,
      "Groups": ["sg-046bbdb07b7cb2c21"]
    }
  ]' \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=MyPublicEC2}]'
--region us-east-1