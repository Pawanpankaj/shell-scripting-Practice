#!/bin/bash
#Author: Pawan Kumar Safi 
#Version: 1.0
#Description: This script enables server-side encryption for an existing SQS queue using a set-queue-attributes command.

#Manullly set the AWS region and SQS queue URL and the set attributes command to enable encryption
REGION="us-east-1"
QURL="https://sqs.us-east-1.amazonaws.com/123456789012/MyQueue"
aws sqs set-queue-attributes \
    --region "$REGION" \
    --queue-url "$QURL" \
     --attributes SqsManagedSseEnabled=true


############################################################################################ 
#For All the Queue for this particular region use the below script within same Account

REGION="us-west-2"
for URL in $(aws sqs list-queues --region "$REGION" --query 'QueueUrls[]' --output text); do
  ATTR=$(aws sqs get-queue-attributes --region "$REGION" --queue-url "$URL" --attribute-names All --query 'Attributes.[SqsManagedSseEnabled,KmsMasterKeyId]' --output text)
  SSE=$(echo "$ATTR" | awk '{print $1}')
  KMS=$(echo "$ATTR" | awk '{print $2}')
  if [[ "$SSE" == "true" || "$KMS" != "None" ]]; then
    echo "[SKIP] $URL already encrypted"
  else
    echo "[APPLY] Enabling SSE-SQS on $URL"
    aws sqs set-queue-attributes --region "$REGION" --queue-url "$URL" --attributes SqsManagedSseEnabled=true
  fi
done
#############################################################################################






#####################################################################################################
# For all the Queue for all the regions within same account use the below script
for R in $(aws ec2 describe-regions --query 'Regions[].RegionName' --output text); do
  echo "Region: $R"
  for URL in $(aws sqs list-queues --region "$R" --query 'QueueUrls[]' --output text 2>/dev/null); do
    ATTR=$(aws sqs get-queue-attributes \
      --region "$R" \
      --queue-url "$URL" \
      --attribute-names All \
      --query 'Attributes.[SqsManagedSseEnabled,KmsMasterKeyId]' \
      --output text 2>/dev/null || true)

    SSE=$(echo "$ATTR" | awk '{print $1}')
    KMS=$(echo "$ATTR" | awk '{print $2}')

    if [[ "$SSE" == "true" || ( "$KMS" != "None" && -n "$KMS" ) ]]; then
      echo "[SKIP] $URL"
    else
      echo "[APPLY] $URL"
      aws sqs set-queue-attributes \
        --region "$R" \
        --queue-url "$URL" \
        --attributes SqsManagedSseEnabled=true
    fi
  done
done
#######################################################################################################

