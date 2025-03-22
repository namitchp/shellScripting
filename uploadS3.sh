#!/bin/bash
# sudo apt update && sudo apt install awscli -y
# S3 Bucket Name
S3_BUCKET="serverdbbackuprit"

TIME=$(date +"%H")
# File Paths
IMAGE_PATH="/public/backup"
ZIP_PATH="backup_$TIME.zip"

# Check if ZIP file already exists
if [ -f "$ZIP_PATH" ]; then
    echo "Backup already exists: $ZIP_PATH. Skipping compression."
else
    echo "Creating new backup..."
    zip -r "$ZIP_PATH" "$IMAGE_PATH/db"
fi

# S3 Upload Path
S3_KEY="connectx/$ZIP_PATH"

# Upload ZIP file to S3
aws s3 cp "$ZIP_PATH" "s3://$S3_BUCKET/$S3_KEY" --acl public-read

# Check if upload was successful
if [ $? -eq 0 ]; then
    rm -r "$ZIP_PATH"
    rm -r "$IMAGE_PATH/db"
    echo "Backup uploaded successfully: https://$S3_BUCKET.s3.amazonaws.com/$S3_KEY"
else
    echo "Upload failed!"
fi