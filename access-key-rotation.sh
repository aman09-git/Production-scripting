#!/bin/bash

# ==========================================================
# IAM Access Key Rotation Script
# ==========================================================
# PURPOSE:
# - Identify IAM users with old access keys
# - Rotate access keys safely (create new + deactivate old)
# - Improve security by enforcing key rotation policy
#
# INPUT:
#   $1 → MAX_AGE_DAYS (e.g., 90)
#   $2 → MODE (dry-run | rotate)
#
# OUTPUT:
# - Lists users with old access keys
# - Creates new access key (if rotation mode)
# - Deactivates old access key
# - Displays actions performed
#
# NOTE:
# - Supports dry-run mode for safe preview
# ==========================================================


MAX_AGE_DAYS=$1
MODE=$2   # dry-run or rotate

if [ -z "$MAX_AGE_DAYS" ] || [ -z "$MODE" ]; then
  echo "Usage: $0 <max_age_days> <dry-run|rotate>"
  exit 1
fi


echo "Running IAM Access Key Rotation in $MODE mode (Max Age: $MAX_AGE_DAYS days)"


# ----------------------------------------------------------
# IAM PERMISSIONS REQUIRED
# ----------------------------------------------------------
# iam:ListUsers
# iam:ListAccessKeys
# iam:CreateAccessKey
# iam:UpdateAccessKey
# iam:DeleteAccessKey
# ----------------------------------------------------------


CURRENT_TIME=$(date +%s)


# ----------------------------------------------------------
# Loop through IAM users
# ----------------------------------------------------------
USERS=$(aws iam list-users --query "Users[].UserName" --output text)

for USER in $USERS; do

  echo "Checking user: $USER"

  ACCESS_KEYS=$(aws iam list-access-keys \
    --user-name "$USER" \
    --query "AccessKeyMetadata[].AccessKeyId" \
    --output text)

  for KEY in $ACCESS_KEYS; do

    CREATE_DATE=$(aws iam list-access-keys \
      --user-name "$USER" \
      --query "AccessKeyMetadata[?AccessKeyId=='$KEY'].CreateDate" \
      --output text)

    KEY_TIME=$(date -d "$CREATE_DATE" +%s 2>/dev/null)
    AGE_DAYS=$(( (CURRENT_TIME - KEY_TIME) / 86400 ))

    echo "User: $USER | Key: $KEY | Age: $AGE_DAYS days"


    # ----------------------------------------------------------
    # Check if key exceeds threshold
    # ----------------------------------------------------------
    if [ "$AGE_DAYS" -ge "$MAX_AGE_DAYS" ]; then

      echo "Old key detected for $USER → $KEY"

      if [ "$MODE" = "dry-run" ]; then
        echo "[DRY-RUN] Would rotate key for user: $USER"

      else
        echo "Rotating key for user: $USER"

        # Step 1: Create new key
        NEW_KEY=$(aws iam create-access-key \
          --user-name "$USER" \
          --query "AccessKey.AccessKeyId" \
          --output text)

        echo "New Access Key created: $NEW_KEY"

        # Step 2: Deactivate old key
        aws iam update-access-key \
          --user-name "$USER" \
          --access-key-id "$KEY" \
          --status Inactive

        echo "Old key deactivated: $KEY"

        # Optional: Delete old key
        # aws iam delete-access-key --user-name "$USER" --access-key-id "$KEY"

      fi
    fi

  done

done


echo "IAM key rotation process completed"


##################### Script End #####################


##################### Execution Instructions #####################

#./iam-key-rotation.sh 90 dry-run
#This will list all IAM users with access keys older than 90 days and show what would be done without making changes.

##################### Expected Output #####################

: << 'COMMENT'
Dry Run
Checking user: aman
User: aman | Key: AKIA123 | Age: 120 days
Old key detected for aman → AKIA123
[DRY-RUN] Would rotate key for user: aman


🔐 Rotation Mode
Checking user: aman
User: aman | Key: AKIA123 | Age: 120 days

Rotating key for user: aman
New Access Key created: AKIA456
Old key deactivated: AKIA123
COMMENT