#!/bin/bash

# Remote Server Details
REMOTE_USER="namit"
REMOTE_HOST="92.204.172.110"
REMOTE_DB_NAME="suzuki_local"
REMOTE_DB_USER="sa"
REMOTE_DB_PASSWORD="sa@1985"

# Backup Storage Path (Local)
LOCAL_BACKUP_PATH="/var/backups/sqlserver"
REMOTE_BACKUP_PATH="/var/remote_sql_backups"
LOG_FILE="/var/log/sqlserver_backup.log"

# Create backup directory if it doesn't exist
mkdir -p $LOCAL_BACKUP_PATH

# Timestamp for backup file
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="${REMOTE_DB_NAME}_backup_$TIMESTAMP.bak"
REMOTE_BACKUP_FILE="$REMOTE_BACKUP_PATH/$BACKUP_FILE"

# Run SQL Server Backup Command on Remote Server
ssh $REMOTE_USER@$REMOTE_HOST "/opt/mssql-tools/bin/sqlcmd -S localhost -U $REMOTE_DB_USER -P $REMOTE_DB_PASSWORD -Q \"BACKUP DATABASE [$REMOTE_DB_NAME] TO DISK = '$REMOTE_BACKUP_FILE' WITH FORMAT, MEDIANAME = 'SQLServerBackups', NAME = 'Full Backup of $REMOTE_DB_NAME';\""

# Check if the backup was successful
if [ $? -eq 0 ]; then
    echo "$(date +"%Y-%m-%d %H:%M:%S") - Remote backup successful: $REMOTE_BACKUP_FILE" >> $LOG_FILE
else
    echo "$(date +"%Y-%m-%d %H:%M:%S") - Remote backup failed!" >> $LOG_FILE
    exit 1
fi

# Copy backup from remote server to local
scp $REMOTE_USER@$REMOTE_HOST:$REMOTE_BACKUP_FILE $LOCAL_BACKUP_PATH/

# Check if the copy was successful
if [ $? -eq 0 ]; then
    echo "$(date +"%Y-%m-%d %H:%M:%S") - Backup copied to local: $LOCAL_BACKUP_PATH/$BACKUP_FILE" >> $LOG_FILE
else
    echo "$(date +"%Y-%m-%d %H:%M:%S") - Failed to copy backup from remote!" >> $LOG_FILE
    exit 1
fi

# Delete backups older than 7 days on local
find $LOCAL_BACKUP_PATH -type f -name "*.bak" -mtime +7 -exec rm {} \;

# Delete backups older than 7 days on remote
ssh $REMOTE_USER@$REMOTE_HOST "find $REMOTE_BACKUP_PATH -type f -name '*.bak' -mtime +7 -exec rm {} \;"

echo "Backup process completed."
