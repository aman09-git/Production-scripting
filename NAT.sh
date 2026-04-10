#!/bin/bash

# Check input
check_args() {
  if [ $# -eq 0 ]; then
    echo "Usage: $0 <region>"
    exit 1
  fi
}

# Fetch NAT Gateway data
fetch_nat_data() {
  aws ec2 describe-nat-gateways --region "$1"
}

# Show NAT Gateways in use (costing money)
show_in_use_nat() {
  echo "########## NAT GATEWAYS IN USE (COSTING MONEY) ##########"

  echo "$1" | jq -r '
  .NatGateways[] | select(.State=="available") |
  "NAT_ID: \(.NatGatewayId) | SUBNET: \(.SubnetId) | VPC: \(.VpcId)"
  '

  COUNT=$(echo "$1" | jq '[.NatGateways[] | select(.State=="available")] | length')

  echo "------------------------------------------------------"
  echo "Total NAT Gateways IN USE: $COUNT"
  echo
}

# Show unused NAT Gateways
show_unused_nat() {
  echo "########## UNUSED / DELETED NAT GATEWAYS ##########"

  echo "$1" | jq -r '
  .NatGateways[] | select(.State!="available") |
  "NAT_ID: \(.NatGatewayId) | STATE: \(.State)"
  '

  COUNT=$(echo "$1" | jq '[.NatGateways[] | select(.State!="available")] | length')

  echo "------------------------------------------------------"
  echo "Total UNUSED NAT Gateways: $COUNT"
  echo
}

# Delete unused NAT Gateways (after confirmation)
delete_unused_nat() {
  read -p "Do you want to delete UNUSED NAT Gateways? (yes/no): " CONFIRM

  if [[ "$CONFIRM" == "yes" ]]; then
    echo "Deleting UNUSED NAT Gateways..."

    echo "$1" | jq -r '
    .NatGateways[] | select(.State!="available") | .NatGatewayId
    ' | while read NAT_ID
    do
      echo "Deleting NAT Gateway: $NAT_ID"
      aws ec2 delete-nat-gateway --nat-gateway-id "$NAT_ID" --region "$2"
    done

    echo "Deletion process triggered."
  else
    echo "Skipping deletion. Review completed."
  fi
}

# ---------------- MAIN ----------------

check_args "$@"

REGION=$1

echo "Fetching NAT Gateway details for region: $REGION"
echo "======================================================"

NAT_DATA=$(fetch_nat_data "$REGION")

show_in_use_nat "$NAT_DATA"
show_unused_nat "$NAT_DATA"

echo "######################################################"
echo "⚠️  Review the above NAT Gateways before deletion"
echo "######################################################"

delete_unused_nat "$NAT_DATA" "$REGION"