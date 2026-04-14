#!/bin/bash

# ==============================
# EC2 Backup Script (Reusable)
# ==============================

# Usage: ./ec2-backup.sh <region> <instance-id>

REGION=$1
INSTANCE_ID=$2
DATE=$(date +%Y-%m-%d_%H-%M-%S)

# Validate input
if [ -z "$REGION" ] || [ -z "$INSTANCE_ID" ]; then
  echo "Usage: $0 <region> <instance-id>"
  exit 1
fi

echo "Starting backup for Instance: $INSTANCE_ID in Region: $REGION"

# Get all volume IDs attached to the instance
VOLUME_IDS=$(aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \
  --region $REGION \
  --query "Reservations[].Instances[].BlockDeviceMappings[].Ebs.VolumeId" \
  --output text)

# Check if volumes exist
if [ -z "$VOLUME_IDS" ]; then
  echo "No volumes found for instance $INSTANCE_ID"
  exit 1
fi

# Loop through volumes and create snapshots
for VOLUME_ID in $VOLUME_IDS; do
  echo "Creating snapshot for Volume: $VOLUME_ID"

  SNAPSHOT_ID=$(aws ec2 create-snapshot \
    --volume-id $VOLUME_ID \
    --description "Backup of $VOLUME_ID from $INSTANCE_ID on $DATE" \
    --region $REGION \
    --query SnapshotId \
    --output text)

  # Tag the snapshot
  aws ec2 create-tags \
    --resources $SNAPSHOT_ID \
    --tags Key=Name,Value="Backup-$INSTANCE_ID-$DATE" \
           Key=InstanceId,Value=$INSTANCE_ID \
           Key=VolumeId,Value=$VOLUME_ID \
    --region $REGION

  echo "Snapshot Created: $SNAPSHOT_ID"
done

echo "Backup completed successfully!"