#!/bin/bash

# ==========================================================
# Auto Scaling Health Check Script (Production-Oriented)
# ==========================================================
# INPUT:
#   $1 → REGION
#   $2 → ASG_NAME
#
# OUTPUT:
# - Lists instance health
# - Marks unhealthy instances
# - Waits 5 minutes before taking action
# - Terminates instance (optional controlled action)
# ==========================================================


REGION=$1
ASG_NAME=$2

# Validate input
if [ -z "$REGION" ] || [ -z "$ASG_NAME" ]; then
  echo "Usage: $0 <region> <asg-name>"
  exit 1
fi


# ----------------------------------------------------------
# IAM PERMISSION CHECK (REFERENCE SECTION)
# ----------------------------------------------------------
# Ensure the instance/role running this script has:
#
# autoscaling:DescribeAutoScalingGroups
# autoscaling:DescribeAutoScalingInstances
# autoscaling:TerminateInstanceInAutoScalingGroup
# ec2:DescribeInstances
#
# NOTE:
# - These permissions are usually attached via IAM Role
# - If running from EC2 → check instance profile
# - If running locally → check configured AWS profile
# ----------------------------------------------------------


echo "Checking health for ASG: $ASG_NAME in $REGION"


# Get instances in ASG
INSTANCE_IDS=$(aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names "$ASG_NAME" \
  --region "$REGION" \
  --query "AutoScalingGroups[].Instances[].InstanceId" \
  --output text)


if [ -z "$INSTANCE_IDS" ]; then
  echo "No instances found in ASG"
  exit 1
fi


# Loop through instances
for INSTANCE_ID in $INSTANCE_IDS; do

  STATE=$(aws ec2 describe-instances \
    --instance-ids "$INSTANCE_ID" \
    --region "$REGION" \
    --query "Reservations[].Instances[].State.Name" \
    --output text)

  HEALTH=$(aws autoscaling describe-auto-scaling-instances \
    --instance-ids "$INSTANCE_ID" \
    --region "$REGION" \
    --query "AutoScalingInstances[].HealthStatus" \
    --output text)

  echo "Instance: $INSTANCE_ID | State: $STATE | Health: $HEALTH"


  # ----------------------------------------------------------
  # STEP 1: MARK INSTANCE IF UNHEALTHY
  # ----------------------------------------------------------
  if [ "$STATE" != "running" ] || [ "$HEALTH" != "Healthy" ]; then

    echo "Marking instance as unhealthy candidate: $INSTANCE_ID"

    # Tag instance as candidate (for tracking)
    aws ec2 create-tags \
      --resources "$INSTANCE_ID" \
      --tags Key=HealthCheck,Value=Pending \
      --region "$REGION"


    # ----------------------------------------------------------
    # STEP 2: WAIT 5 MINUTES (GRACE PERIOD)
    # ----------------------------------------------------------
    echo "Waiting 5 minutes before re-check..."
    sleep 300


    # ----------------------------------------------------------
    # STEP 3: RE-CHECK STATUS
    # ----------------------------------------------------------
    NEW_STATE=$(aws ec2 describe-instances \
      --instance-ids "$INSTANCE_ID" \
      --region "$REGION" \
      --query "Reservations[].Instances[].State.Name" \
      --output text)

    NEW_HEALTH=$(aws autoscaling describe-auto-scaling-instances \
      --instance-ids "$INSTANCE_ID" \
      --region "$REGION" \
      --query "AutoScalingInstances[].HealthStatus" \
      --output text)

    echo "Re-check → State: $NEW_STATE | Health: $NEW_HEALTH"


    # ----------------------------------------------------------
    # STEP 4: TAKE ACTION ONLY IF STILL UNHEALTHY
    # ----------------------------------------------------------
    if [ "$NEW_STATE" != "running" ] || [ "$NEW_HEALTH" != "Healthy" ]; then

      echo "Instance still unhealthy → proceeding with termination: $INSTANCE_ID"

      aws autoscaling terminate-instance-in-auto-scaling-group \
        --instance-id "$INSTANCE_ID" \
        --no-should-decrement-desired-capacity \
        --region "$REGION"

    else
      echo "Instance recovered → no action needed: $INSTANCE_ID"

      # Update tag
      aws ec2 create-tags \
        --resources "$INSTANCE_ID" \
        --tags Key=HealthCheck,Value=Recovered \
        --region "$REGION"
    fi

  fi

done


echo "Health check process completed"




####################################################################################################

#chmod +x ASG-heathcheck.sh
#./ASG-heathcheck.sh us-east-1 my-auto-scaling-group

############# Expected Output #############

: << 'COMMENT'
Checking health for ASG: my-asg in ap-south-1

Instance: i-123 | State: running | Health: Healthy
Instance: i-456 | State: stopped | Health: Unhealthy

Marking instance as unhealthy candidate: i-456
Waiting 5 minutes before re-check...

Re-check → State: stopped | Health: Unhealthy
Instance still unhealthy → proceeding with termination: i-456

Health check process completed
COMMENT