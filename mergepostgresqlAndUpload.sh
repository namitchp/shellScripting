#!/bin/bash

# Database credentials
DB_NAMES=("connectx") # Add all database names here
# DB_NAMES=("connectx" "database2" "database3") # Add all database names here
DB_USER="postgres"
DB_HOST="148.72.168.56"   # Change if using a remote database
BACKUP_PATH="/public/backup/db"
S3_BUCKET="serverdbbackuprit"

# Ensure backup directory exists
mkdir -p "$BACKUP_PATH"

# Timestamp
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FOLDER="$BACKUP_PATH/backup_$TIMESTAMP"
mkdir -p "$BACKUP_FOLDER"

for DB_NAME in "${DB_NAMES[@]}"; do
    echo "Processing database: $DB_NAME"

    # Backup command
    PGPASSWORD="Postgresql@Rohin@Connectx@1234" pg_dump -U $DB_USER -h $DB_HOST -d $DB_NAME > "$BACKUP_FOLDER/db_backup_${DB_NAME}.sql"
    if [ $? -ne 0 ]; then
        echo "Database backup failed for $DB_NAME!"
        continue
    fi
    echo "Backup completed for $DB_NAME"
done

# Compress the entire backup folder
ZIP_PATH="$BACKUP_PATH/all_backups_$TIMESTAMP.zip"
zip -r "$ZIP_PATH" "$BACKUP_FOLDER" > /dev/null
if [ $? -ne 0 ]; then
    echo "Compression failed!"
    exit 1
fi
echo "All backups compressed to $ZIP_PATH"

# Upload to S3
S3_KEY="connectx/all_backups_$TIMESTAMP.zip"
aws s3 cp "$ZIP_PATH" "s3://$S3_BUCKET/$S3_KEY" --acl public-read
if [ $? -eq 0 ]; then
    rm -rf "$ZIP_PATH" "$BACKUP_FOLDER"
    echo "Backup uploaded successfully: https://$S3_BUCKET.s3.amazonaws.com/$S3_KEY"

    # Send email notification
    EMAIL_SUBJECT="Backup Successful: All Databases"
    EMAIL_BODY="The backup files have been successfully uploaded to S3.\n\nS3 URL: https://$S3_BUCKET.s3.amazonaws.com/$S3_KEY"
    echo -e "$EMAIL_BODY" | mail -s "$EMAIL_SUBJECT" recipient@example.com
else
    echo "Upload failed!"
    exit 1
fi