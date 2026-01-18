#!/bin/bash

LOG_FILE="s3_https_enforcement.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

HTTPS_POLICY='{
  "Sid": "httpsenforces3",
  "Effect": "Deny",
  "Principal": "*",
  "Action": "s3:*",
  "Resource": [
    "arn:aws:s3:::BUCKET_NAME",
    "arn:aws:s3:::BUCKET_NAME/*"
  ],
  "Condition": {
    "Bool": {
      "aws:SecureTransport": "false"
    }
  }
}'

log_action() {
  echo "[$DATE] $1" | tee -a "$LOG_FILE"
}

apply_policy() {
  aws s3api put-bucket-policy --bucket "$1" --policy "$2"
  if [ $? -eq 0 ]; then
    log_action "✅ Applied policy to bucket: $1"
  else
    log_action "❌ Failed to apply policy to bucket: $1"
  fi
}

# ✅ FIXED LINE
buckets=$(aws s3api list-buckets --query "Buckets[].Name" --output text)

for bucket in $buckets; do
  echo "Checking bucket: $bucket"

  # Check Block Public Access
  block_status=$(aws s3api get-bucket-policy-status --bucket "$bucket" \
    --query "PolicyStatus.IsPublic" --output text 2>/dev/null)

  if [ "$block_status" == "false" ]; then
    log_action "Bucket $bucket has Block Public Access enabled. Skipping..."
    continue
  fi

  # Get existing policy
  policy=$(aws s3api get-bucket-policy --bucket "$bucket" \
    --query "Policy" --output text 2>/dev/null)

  if [ -z "$policy" ]; then
    log_action "No policy found for $bucket. Creating new policy."

    new_policy=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    $(echo "$HTTPS_POLICY" | sed "s/BUCKET_NAME/$bucket/g")
  ]
}
EOF
)

    apply_policy "$bucket" "$new_policy"

  else
    sid_exists=$(echo "$policy" | jq -r '.Statement[].Sid' | grep -w "httpsenforces3")

    if [ -n "$sid_exists" ]; then
      log_action "HTTPS enforcement already exists for $bucket. Skipping."
    else
      log_action "Adding HTTPS enforcement to existing policy for $bucket."

      updated_policy=$(echo "$policy" | jq \
        '.Statement += [$(echo "'"$HTTPS_POLICY"'" | sed "s/BUCKET_NAME/'"$bucket"'/g")]')

      apply_policy "$bucket" "$updated_policy"
    fi
  fi
done
