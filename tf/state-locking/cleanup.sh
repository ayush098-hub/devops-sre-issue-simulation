#!/bin/bash

BUCKET_NAME="terraform-series-state"
TABLE_NAME="terraform-state-lock"
REGION="us-east-1"

echo "▶ Deleting all S3 object versions and delete markers..."
aws s3api list-object-versions \
  --bucket "$BUCKET_NAME" \
  --region "$REGION" \
  --output text \
  --query 'Versions[*].[Key,VersionId]' | \
while read KEY VERSION; do
  aws s3api delete-object \
    --bucket "$BUCKET_NAME" \
    --key "$KEY" \
    --version-id "$VERSION" \
    --region "$REGION" > /dev/null
  echo "  deleted version: $KEY ($VERSION)"
done

aws s3api list-object-versions \
  --bucket "$BUCKET_NAME" \
  --region "$REGION" \
  --output text \
  --query 'DeleteMarkers[*].[Key,VersionId]' | \
while read KEY VERSION; do
  aws s3api delete-object \
    --bucket "$BUCKET_NAME" \
    --key "$KEY" \
    --version-id "$VERSION" \
    --region "$REGION" > /dev/null
  echo "  deleted marker: $KEY ($VERSION)"
done

echo "▶ Deleting S3 bucket..."
aws s3api delete-bucket --bucket "$BUCKET_NAME" --region "$REGION"
echo "  ✅ Bucket deleted: $BUCKET_NAME"

echo "▶ Deleting DynamoDB table..."
aws dynamodb delete-table --table-name "$TABLE_NAME" --region "$REGION" > /dev/null
echo "  ✅ DynamoDB table deleted: $TABLE_NAME"
