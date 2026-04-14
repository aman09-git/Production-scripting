#!/bin/bash

# ==========================================================
# Log Rotation & Cleanup Script
# ==========================================================
# PURPOSE:
# - Rotate a log file when it exceeds a given size
# - Compress the rotated log
# - Cleanup old logs (retention policy)
#
# INPUT (Arguments):
#   $1 → LOG_FILE        (Full path of log file)
#   $2 → MAX_SIZE        (Max size in bytes)
#   $3 → BACKUP_DIR      (Directory to store rotated logs)
#
# OUTPUT:
# - Rotated log file stored in BACKUP_DIR
# - Compressed file (.gz)
# - Old logs deleted based on retention
# - Console/log messages for tracking
# ==========================================================


# -------------------------------
# Assign input arguments to variables
# -------------------------------
LOG_FILE=$1        # Example: /var/log/syslog
MAX_SIZE=$2        # Example: 100000000 (100 MB)
BACKUP_DIR=$3      # Example: /var/log/backups

# Generate timestamp for unique file naming
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")


# -------------------------------
# Input validation
# -------------------------------
# -z checks if variable is empty
if [ -z "$LOG_FILE" ] || [ -z "$MAX_SIZE" ] || [ -z "$BACKUP_DIR" ]; then
  echo "Usage: $0 <log_file> <max_size_bytes> <backup_dir>"
  exit 1   # Exit script with error
fi


# -------------------------------
# Create backup directory if not exists
# -------------------------------
# mkdir -p → creates directory safely (no error if exists)
mkdir -p "$BACKUP_DIR"


# -------------------------------
# Function: rotate_logs
# -------------------------------
rotate_logs() {

    echo "Rotating log file: $LOG_FILE"

    # Copy current log to backup directory
    # cp → ensures original file is not disturbed immediately
    cp "$LOG_FILE" "$BACKUP_DIR/backup_$TIMESTAMP.log"

    # Truncate original log file (clear contents safely)
    # : > file → empties file without deleting it
    : > "$LOG_FILE"

    # Compress rotated log file to save space
    gzip "$BACKUP_DIR/backup_$TIMESTAMP.log"

    echo "Rotation completed: backup_$TIMESTAMP.log.gz"
}


# -------------------------------
# Main Logic
# -------------------------------

# -f checks if file exists
if [ -f "$LOG_FILE" ]; then

    # Get file size in bytes
    # stat -c%s → returns file size
    FILE_SIZE=$(stat -c%s "$LOG_FILE")

    # Check if file size exceeds limit
    # -gt → greater than comparison
    if [ "$FILE_SIZE" -gt "$MAX_SIZE" ]; then
        rotate_logs
    else
        echo "Log size under limit: $FILE_SIZE bytes"
    fi

else
    echo "Log file does not exist"
fi


# -------------------------------
# Cleanup old logs (Retention Policy)
# -------------------------------
# find → search files
# -mtime +7 → files older than 7 days
# -name "*.gz" → only compressed logs
# -delete → remove files
find "$BACKUP_DIR" -type f -mtime +7 -name "*.gz" -delete


echo "Log rotation & cleanup completed successfully!"