# #!/bin/bash
# # Database credentials
# DB_NAME="connectx"
# DB_USER="postgres"
# DB_HOST="148.72.168.56"   # Change if using a remote database

# BACKUP_PATH="/public/backup/db"
# mkdir $BACKUP_PATH
# # Timestamp
# TIMESTAMP=$(date +"%Y-%m-%d_%H:%M:%S")

# # Backup command
# PGPASSWORD="Postgresql@Rohin@Connectx@1234" pg_dump -U $DB_USER -h $DB_HOST -d $DB_NAME > $BACKUP_PATH/db_backup_$TIMESTAMP.sql

# # Optional: Delete backups older than 2 days
# find $BACKUP_PATH -type f -name "*.sql" -mtime +2 -exec rm {} \;

# echo "Backup completed at $TIMESTAMP"




#!/bin/bash
# Database credentials
DB_NAME="connectx"
DB_USER="postgres"
DB_HOST="148.72.168.56"   # Change if using a remote database

BACKUP_PATH="/public/backup/db"

# Check if the backup directory exists, if not, create it
if [ ! -d "$BACKUP_PATH" ]; then
    mkdir -p "$BACKUP_PATH"
    echo "Created backup directory: $BACKUP_PATH"
else
    echo "Backup directory already exists: $BACKUP_PATH"
fi

# Timestamp
TIMESTAMP=$(date +"%Y-%m-%d_%H:%M:%S")

# Backup command
PGPASSWORD="Postgresql@Rohin@Connectx@1234" pg_dump -U $DB_USER -h $DB_HOST -d $DB_NAME > "$BACKUP_PATH/db_backup_$TIMESTAMP.sql"

# Optional: Delete backups older than 2 days
find "$BACKUP_PATH" -type f -name "*.sql" -mtime +2 -exec rm {} \;

echo "Backup completed at $TIMESTAMP"

