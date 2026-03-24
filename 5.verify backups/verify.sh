#!/bin/bash

# --- 1. CONFIGURATION & PRE-FLIGHT ---
echo "----------------------------------------------------------"
echo "AVAILABLE DATASTORES:"
proxmox-backup-manager datastore list
echo "----------------------------------------------------------"

# --- 2. INTERACTIVE INPUTS ---
read -p "Enter the Datastore name: " DATASTORE
read -p "Enter your email address for alerts: " EMAIL
LOGFILE="/var/log/pbs_verify.log"

echo "----------------------------------------------------------"
echo "Starting verification for $DATASTORE at $(date)" | tee -a "$LOGFILE"

# --- 3. LOGIC: RUN VERIFICATION ---
# Running verification and capturing output in JSON format
proxmox-backup-manager verify "$DATASTORE" --output-format json > /tmp/verify_result.json 2>&1

# Check the exit code (0 means success)
if [ $? -eq 0 ]; then
    echo "Verification successful!" | tee -a "$LOGFILE"
else
    echo "VERIFICATION FAILED! Sending alert to $EMAIL..." | tee -a "$LOGFILE"
    # Send an email alert if the task fails
    cat /tmp/verify_result.json | mail -s "ALERT: Backup Verification Failed on $DATASTORE" "$EMAIL"
fi
