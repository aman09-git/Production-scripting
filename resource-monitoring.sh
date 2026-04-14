#!/bin/bash

# ==========================================================
# Server Resource Monitoring Script
# ==========================================================
# PURPOSE:
# - Monitor server resources (CPU, Memory, Disk usage)
# - Compare usage against defined thresholds
# - Alert/log if any resource crosses threshold
#
# INPUT:
#   $1 → CPU_THRESHOLD (%)       (e.g., 80)
#   $2 → MEMORY_THRESHOLD (%)    (e.g., 80)
#   $3 → DISK_THRESHOLD (%)      (e.g., 80)
#
# OUTPUT:
# - Displays current CPU, Memory, Disk usage
# - Alerts if any resource exceeds threshold
# - Logs critical alerts for tracking
# ==========================================================


CPU_THRESHOLD=$1
MEMORY_THRESHOLD=$2
DISK_THRESHOLD=$3

# Validate input
if [ -z "$CPU_THRESHOLD" ] || [ -z "$MEMORY_THRESHOLD" ] || [ -z "$DISK_THRESHOLD" ]; then
  echo "Usage: $0 <cpu_threshold> <memory_threshold> <disk_threshold>"
  exit 1
fi


echo "Starting Server Resource Monitoring..."


# ----------------------------------------------------------
# Get CPU Usage
# ----------------------------------------------------------
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')


# ----------------------------------------------------------
# Get Memory Usage
# ----------------------------------------------------------
MEMORY_USAGE=$(free | awk '/Mem:/ {printf("%.0f"), $3/$2 * 100}')


# ----------------------------------------------------------
# Get Disk Usage (root partition)
# ----------------------------------------------------------
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')


echo "CPU Usage: $CPU_USAGE%"
echo "Memory Usage: $MEMORY_USAGE%"
echo "Disk Usage: $DISK_USAGE%"


# ----------------------------------------------------------
# Alert Logic
# ----------------------------------------------------------

ALERT=false

if (( $(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc -l) )); then
  echo "ALERT ❌: CPU usage exceeded threshold ($CPU_THRESHOLD%)"
  ALERT=true
fi

if [ "$MEMORY_USAGE" -gt "$MEMORY_THRESHOLD" ]; then
  echo "ALERT ❌: Memory usage exceeded threshold ($MEMORY_THRESHOLD%)"
  ALERT=true
fi

if [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
  echo "ALERT ❌: Disk usage exceeded threshold ($DISK_THRESHOLD%)"
  ALERT=true
fi


# ----------------------------------------------------------
# Logging
# ----------------------------------------------------------
if [ "$ALERT" = true ]; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') - High resource usage detected" >> resource-monitor.log
else
  echo "All resources are within limits ✅"
fi



######################## Execution Example ########################
#./resource-monitor.sh 80 80 80

# 80 is threshold for CPU, Memory, and Disk usage respectively

######################## Output########################

#Normal Case 
: << 'COMMENT'

Starting Server Resource Monitoring...
CPU Usage: 35%
Memory Usage: 45%
Disk Usage: 50%
All resources are within limits ✅
COMMENT

#❌ Alert Case

: << 'COMMENT'
Starting Server Resource Monitoring...
CPU Usage: 85%
Memory Usage: 70%
Disk Usage: 90%

ALERT ❌: CPU usage exceeded threshold (80%)
ALERT ❌: Disk usage exceeded threshold (80%)
COMMENT