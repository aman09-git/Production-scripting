#!/bin/bash

# ==========================================================
# Website / API Health Monitoring Script
# ==========================================================
# PURPOSE:
# - Monitor availability of a website or API endpoint
# - Check HTTP response status code
# - Retry after a short interval before marking failure
# - Alert/log if endpoint is unhealthy
#
# INPUT:
#   $1 → URL (website or API endpoint)
#   $2 → EXPECTED_STATUS (e.g., 200)
#   $3 → RETRY_COUNT (number of retries before failure)
#
# OUTPUT:
# - Displays HTTP status of endpoint
# - Confirms if service is healthy
# - Logs failure after retries
# ==========================================================


URL=$1
EXPECTED_STATUS=$2
RETRY_COUNT=$3

# Validate input
if [ -z "$URL" ] || [ -z "$EXPECTED_STATUS" ] || [ -z "$RETRY_COUNT" ]; then
  echo "Usage: $0 <url> <expected_status_code> <retry_count>"
  exit 1
fi


echo "Checking health for: $URL"


# Function to check HTTP status
check_health() {
  STATUS_CODE=$(curl -o /dev/null -s -w "%{http_code}" "$URL")
  echo "$STATUS_CODE"
}


ATTEMPT=1
HEALTHY=false


# ----------------------------------------------------------
# Retry logic
# ----------------------------------------------------------
while [ $ATTEMPT -le $RETRY_COUNT ]; do

  STATUS=$(check_health)

  echo "Attempt $ATTEMPT → HTTP Status: $STATUS"

  if [ "$STATUS" -eq "$EXPECTED_STATUS" ]; then
    echo "Service is healthy ✅"
    HEALTHY=true
    break
  fi

  echo "Service not healthy, retrying in 10 seconds..."
  sleep 10

  ATTEMPT=$((ATTEMPT + 1))

done


# ----------------------------------------------------------
# Final status handling
# ----------------------------------------------------------
if [ "$HEALTHY" = false ]; then
  echo "ALERT ❌: Service is DOWN after $RETRY_COUNT attempts"

  # Example: Log to file
  echo "$(date) - $URL is DOWN" >> health-monitor.log

  # (Optional) You can integrate:
  # - Email alert
  # - Slack webhook
  # - AWS SNS notification
else
  echo "Final Status: Service is UP ✅"
fi







################# Scrpt Execution Example #################

#./script.sh https://example.com 200 3


################ Expected Output Example ################

: << 'COMMENT'
Checking health for: https://example.com
Attempt 1 → HTTP Status: 200
Service is healthy ✅
Final Status: Service is UP ✅

############################ Unhealthy Output Example ################

Checking health for: https://example.com
Attempt 1 → HTTP Status: 500
Retrying...

Attempt 2 → HTTP Status: 500
Retrying...

Attempt 3 → HTTP Status: 500

ALERT ❌: Service is DOWN after 3 attempts
COMMENT