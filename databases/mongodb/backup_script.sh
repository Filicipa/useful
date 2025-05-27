#!/bin/bash
# Backup MongoDB databases
# Remove backups that are older than 5 days

# Set backup directory and file name
BACKUP_DIR="/data/backup_omomo_mongo"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_NAME="mongodb_backup_$DATE"

# Run mongodump command to create backup
mongodump --authenticationDatabase=admin --username=name \
--password=1234 --db=base --out $BACKUP_DIR/"$BACKUP_NAME" --gzip

# Set the number of backups to keep
num_backups_to_keep=5

# Remove backups more than 5
cd "$BACKUP_DIR" || exit
ls -1t | grep "^mongodb_backup_" | tail -n +$((num_backups_to_keep+1)) \
  | xargs -d '\n' rm -R -f
