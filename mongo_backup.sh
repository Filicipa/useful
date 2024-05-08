#!/bin/bash
# Backup MongoDB databases
# Remove backups that are older than 3 days

# Set backup directory and file name
BACKUP_DIR="/data/backup_loop_mongo"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_NAME="mongodb_backup_$DATE"

# Run mongodump command to create backup
mongodump --authenticationDatabase=admin --username= --password= --db=admin --out $BACKUP_DIR/$BACKUP_NAME --gzip

# Set the number of backups to keep
num_backups_to_keep=3

# Remove backups
cd $BACKUP_DIR
ls -1t | grep "^mongodb_backup_" | tail -n +$((num_backups_to_keep+1)) | xargs -d '\n' rm -R -f