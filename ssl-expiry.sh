#!/bin/bash

# ==========================================================
# SSL Certificate Expiry Checker Script
# ==========================================================
# PURPOSE:
# - Check SSL certificate expiry for a given domain
# - Calculate remaining days before expiration
# - Alert if certificate is close to expiry
#
# INPUT:
#   $1 → DOMAIN (e.g., example.com)
#   $2 → PORT (default: 443)
#   $3 → THRESHOLD_DAYS (alert if expiry within these days)
#
# OUTPUT:
# - Displays certificate expiry date
# - Shows remaining days
# - Alerts if certificate is expiring soon
# ==========================================================


DOMAIN=$1
PORT=${2:-443}          # Default port 443 if not provided
THRESHOLD_DAYS=$3

# Validate input
if [ -z "$DOMAIN" ] || [ -z "$THRESHOLD_DAYS" ]; then
  echo "Usage: $0 <domain> [port] <threshold_days>"
  exit 1
fi


echo "Checking SSL certificate for: $DOMAIN:$PORT"


# ----------------------------------------------------------
# Get SSL certificate expiry date
# ----------------------------------------------------------
EXPIRY_DATE=$(echo | openssl s_client -servername "$DOMAIN" -connect "$DOMAIN:$PORT" 2>/dev/null \
  | openssl x509 -noout -enddate | cut -d= -f2)


if [ -z "$EXPIRY_DATE" ]; then
  echo "Failed to fetch certificate"
  exit 1
fi


# Convert expiry date to seconds
EXPIRY_SECONDS=$(date -d "$EXPIRY_DATE" +%s 2>/dev/null)

# Current time in seconds
CURRENT_SECONDS=$(date +%s)

# Calculate remaining days
DAYS_LEFT=$(( (EXPIRY_SECONDS - CURRENT_SECONDS) / 86400 ))


echo "Certificate Expiry Date: $EXPIRY_DATE"
echo "Days Remaining: $DAYS_LEFT"


# ----------------------------------------------------------
# Alert logic
# ----------------------------------------------------------
if [ "$DAYS_LEFT" -le "$THRESHOLD_DAYS" ]; then
  echo "ALERT ❌: SSL certificate expiring within $THRESHOLD_DAYS days!"

  # Log example
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $DOMAIN SSL expiring in $DAYS_LEFT days" >> ssl-check.log

else
  echo "SSL certificate is valid ✅"
fi



######################## Execution Example ########################

#./ssl-check.sh example.com 443 10

######################## Output########################

# ✅ Healthy Certificate
Checking SSL certificate for: example.com:443
Certificate Expiry Date: Dec 20 12:00:00 2026 GMT
Days Remaining: 120
SSL certificate is valid ✅

# ❌ Expiring Soon
Checking SSL certificate for: example.com:443
Certificate Expiry Date: Apr 25 12:00:00 2026 GMT
Days Remaining: 5
ALERT ❌: SSL certificate expiring within 10 days!