#!/bin/bash
# ============================================================
# bootstrap.sh
# Run this ONCE before the simulation to create:
#   - S3 bucket for Terraform state
#   - DynamoDB table for state locking
# ============================================================

set -e

BUCKET_NAME="terraform-series-state"
TABLE_NAME="terraform-state-lock"
REGION="us-east-1"

echo "▶ Creating S3 bucket..."

aws s3api create-bucket \
  --bucket "$BUCKET_NAME" \
  --region "$REGION" 2>/dev/null || echo "  Bucket already exists, skipping..."

# Enable versioning (important for state recovery)
aws s3api put-bucket-versioning \
  --bucket "$BUCKET_NAME" \
  --versioning-configuration Status=Enabled

# Enable server-side encryption
aws s3api put-bucket-encryption \
  --bucket "$BUCKET_NAME" \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# Block public access
aws s3api put-public-access-block \
  --bucket "$BUCKET_NAME" \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

echo "  ✅ S3 bucket ready: $BUCKET_NAME"

# ── Step 2: Create DynamoDB Table ────────────────────────
echo ""
echo "▶ Creating DynamoDB table for state locking..."

aws dynamodb create-table \
  --table-name "$TABLE_NAME" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region "$REGION" 2>/dev/null || echo "  Table already exists, skipping..."

echo "  ✅ DynamoDB table ready: $TABLE_NAME"
