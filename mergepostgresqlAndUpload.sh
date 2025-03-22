#!/bin/bash

# Database credentials
DB_NAME="connectx"
DB_USER="postgres"
DB_HOST="148.72.168.56"   # Change if using a remote database
BACKUP_PATH="/public/backup/db"
S3_BUCKET="serverdbbackuprit"

# Ensure backup directory exists
mkdir -p "$BACKUP_PATH"

# Timestamp
TIMESTAMP=$(date +"%H:%M:%S")

# Backup command
PGPASSWORD="Postgresql@Rohin@Connectx@1234" pg_dump -U $DB_USER -h $DB_HOST -d $DB_NAME > "$BACKUP_PATH/db_backup_$TIMESTAMP.sql"
if [ $? -ne 0 ]; then
    echo "Database backup failed!"
    exit 1
fi
echo "Backup completed at $TIMESTAMP"

# Compress backup
ZIP_PATH="backup_$TIMESTAMP.zip"
zip -r "$ZIP_PATH" "$BACKUP_PATH/db_backup_$TIMESTAMP.sql" > /dev/null
if [ $? -ne 0 ]; then
    echo "Compression failed!"
    exit 1
fi
echo "Backup compressed to $ZIP_PATH"

# Upload to S3
S3_KEY="connectx/$ZIP_PATH"
aws s3 cp "$ZIP_PATH" "s3://$S3_BUCKET/$S3_KEY" --acl public-read
if [ $? -eq 0 ]; then
    rm -f "$ZIP_PATH" "$BACKUP_PATH/db_backup_$TIMESTAMP.sql"
    echo "Backup uploaded successfully: https://$S3_BUCKET.s3.amazonaws.com/$S3_KEY"

    # Send email notification
    EMAIL_SUBJECT="Backup Successful: $DB_NAME"
    EMAIL_BODY="The backup file has been successfully uploaded to S3.\n\nS3 URL: https://$S3_BUCKET.s3.amazonaws.com/$S3_KEY"
    echo -e "$EMAIL_BODY" | mail -s "$EMAIL_SUBJECT" recipient@example.com
else
    echo "Upload failed!"
    exit 1
fi