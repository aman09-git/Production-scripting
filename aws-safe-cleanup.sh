#!/bin/bash

# ==========================================================
# AWS Safe Resource Cleanup Script
# ==========================================================
# PURPOSE:
# - Identify unused AWS resources
# - Perform safe cleanup using tag-based filtering
# - Support dry-run and confirmation before deletion
#
# INPUT:
#   $1 → REGION
#   $2 → MODE (dry-run | delete)
#
# OUTPUT:
# - Lists unused resources (EBS, EIP, Snapshots, AMIs, ENIs)
# - Deletes resources only if confirmed
# - Prevents accidental deletion using tags
#
# NOTE:
# - Only resources with tag Cleanup=true will be deleted
# ==========================================================


REGION=$1
MODE=$2   # dry-run or delete

if [ -z "$REGION" ] || [ -z "$MODE" ]; then
  echo "Usage: $0 <region> <dry-run|delete>"
  exit 1
fi

echo "Running in $MODE mode in region: $REGION"


# ----------------------------------------------------------
# Function to handle deletion with safety
# ----------------------------------------------------------
safe_delete() {
  RESOURCE_TYPE=$1
  RESOURCE_ID=$2

  if [ "$MODE" = "dry-run" ]; then
    echo "[DRY-RUN] Would delete $RESOURCE_TYPE: $RESOURCE_ID"
  else
    read -p "Delete $RESOURCE_TYPE $RESOURCE_ID? (yes/no): " confirm
    if [ "$confirm" = "yes" ]; then
      echo "Deleting $RESOURCE_TYPE: $RESOURCE_ID"
      $3   # actual delete command passed
    else
      echo "Skipped $RESOURCE_TYPE: $RESOURCE_ID"
    fi
  fi
}


# ----------------------------------------------------------
# IAM PERMISSIONS REQUIRED
# ----------------------------------------------------------
# ec2:Describe*
# ec2:DeleteVolume
# ec2:ReleaseAddress
# ec2:DeregisterImage
# ec2:DeleteSnapshot
# ec2:DeleteNetworkInterface
# ----------------------------------------------------------


# ==========================================================
# 1. Unused EBS Volumes
# ==========================================================
echo "Checking unused EBS volumes..."

VOLUMES=$(aws ec2 describe-volumes \
  --region "$REGION" \
  --filters Name=status,Values=available Name=tag:Cleanup,Values=true \
  --query "Volumes[].VolumeId" \
  --output text)

for VOL in $VOLUMES; do
  safe_delete "EBS Volume" "$VOL" \
  "aws ec2 delete-volume --volume-id $VOL --region $REGION"
done


# ==========================================================
# 2. Unused Elastic IPs
# ==========================================================
echo "Checking unused Elastic IPs..."

EIPS=$(aws ec2 describe-addresses \
  --region "$REGION" \
  --query "Addresses[?AssociationId==null && Tags[?Key=='Cleanup' && Value=='true']].AllocationId" \
  --output text)

for EIP in $EIPS; do
  safe_delete "Elastic IP" "$EIP" \
  "aws ec2 release-address --allocation-id $EIP --region $REGION"
done


# ==========================================================
# 3. Old Snapshots (tag-based)
# ==========================================================
echo "Checking old snapshots..."

SNAPSHOTS=$(aws ec2 describe-snapshots \
  --owner-ids self \
  --region "$REGION" \
  --query "Snapshots[?Tags[?Key=='Cleanup' && Value=='true']].SnapshotId" \
  --output text)

for SNAP in $SNAPSHOTS; do
  safe_delete "Snapshot" "$SNAP" \
  "aws ec2 delete-snapshot --snapshot-id $SNAP --region $REGION"
done


# ==========================================================
# 4. Unused AMIs
# ==========================================================
echo "Checking unused AMIs..."

AMIS=$(aws ec2 describe-images \
  --owners self \
  --region "$REGION" \
  --query "Images[?Tags[?Key=='Cleanup' && Value=='true']].ImageId" \
  --output text)

for AMI in $AMIS; do
  safe_delete "AMI" "$AMI" \
  "aws ec2 deregister-image --image-id $AMI --region $REGION"
done


# ==========================================================
# 5. Unused Network Interfaces
# ==========================================================
echo "Checking unused ENIs..."

ENIS=$(aws ec2 describe-network-interfaces \
  --region "$REGION" \
  --query "NetworkInterfaces[?Status=='available' && Tags[?Key=='Cleanup' && Value=='true']].NetworkInterfaceId" \
  --output text)

for ENI in $ENIS; do
  safe_delete "Network Interface" "$ENI" \
  "aws ec2 delete-network-interface --network-interface-id $ENI --region $REGION"
done


echo "Cleanup process completed!"


##################### Script End #####################


##################### Execution Instructions #####################

#./aws-safe-cleanup.sh ap-south-1 dry-run

#This will ask user to confirm deletion of each resource. Only resources tagged with Cleanup=true will be considered for deletion.

##################### Expected Output #####################

: << 'COMMENT'
Dry Run 

[DRY-RUN] Would delete EBS Volume: vol-123
[DRY-RUN] Would delete Elastic IP: eipalloc-456

⚠️ Delete Mode

Delete EBS Volume vol-123? (yes/no): yes
Deleting EBS Volume: vol-123
COMMENT