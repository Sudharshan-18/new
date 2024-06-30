#!/bin/bash

{
  echo "Running system_monitor.sh at $(date)"

  # Get Disk Usage
  disk_usage=$(df -h /)

  # Get Memory Usage
  memory_usage=$(free -h | grep "Mem:")

  # Get Top 3 Processes by CPU usage
  top_processes_cpu=$(ps -eo pid,%cpu,cmd --sort=-%cpu | head -n 4)

  # Get Top 3 Processes by Memory usage
  top_processes_mem=$(ps -eo pid,%mem,cmd --sort=-%mem | head -n 4)

  # Compose the email content with a subject
  email_subject="System Monitor Report for $(date '+%Y-%m-%d %H:%M:%S')"
  email_to="sudharshanreddy1823@gmail.com"
  email_from="sudharshanreddy1823@gmail.com"

  email_content=$(cat <<EOF
Subject: $email_subject
From: $email_from
To: $email_to

Disk Usage:
$disk_usage

Memory Usage:
$memory_usage

Top 3 Processes by CPU Usage:
$top_processes_cpu

Top 3 Processes by Memory Usage:
$top_processes_mem
EOF
  )

  # Send the email using msmtp
  echo "$email_content" | msmtp --debug -a default "$email_to"
} >> /home/sudharshan/var/www/pg-st33/cron-job/system_monitor.log 2>&1

