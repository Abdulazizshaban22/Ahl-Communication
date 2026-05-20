
#!/usr/bin/env bash
set -euo pipefail
REGION=${1:-me-central-1}
PROFILE=${2:-default}
DOMAIN=${3:-ahla.com}

echo "Verifying SES domain identity..."
aws --region $REGION --profile $PROFILE ses verify-domain-identity --domain $DOMAIN

echo "Creating SMTP IAM user..."
aws --region $REGION --profile $PROFILE iam create-user --user-name ahla-ses-smtp || true
AKID=$(aws --profile $PROFILE iam create-access-key --user-name ahla-ses-smtp --query 'AccessKey.AccessKeyId' --output text)
SK=$(aws --profile $PROFILE iam list-access-keys --user-name ahla-ses-smtp --query 'AccessKeyMetadata[0].AccessKeyId' --output text)
echo "Remember to convert IAM keys to SES SMTP credentials per AWS docs."
