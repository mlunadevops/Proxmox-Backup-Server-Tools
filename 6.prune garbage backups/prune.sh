#!/bin/bash

# --- 1. CONFIGURATION & PRE-FLIGHT ---
echo "----------------------------------------------------------"
echo "AVAILABLE DATASTORES:"
# List datastores so the user knows what to type
proxmox-backup-manager datastore list
echo "----------------------------------------------------------"

# Ask user for variables
read -p "Enter the Datastore name: " DATASTORE_NAME
read -p "Enter number of backups to keep (e.g., 10): " KEEP_LAST
read -p "Enter Prune Job schedule (e.g., 17:00): " PRUNE_TIME
read -p "Enter Garbage Collection schedule (e.g., 18:00): " GC_TIME

echo ""
echo "Processing: $DATASTORE_NAME..."

# --- 2. APPLY MAINTENANCE ---
# Create or Update Prune Job
# The '||' handles the case where the job already exists by switching to 'update'
proxmox-backup-manager prune-job create "job-$DATASTORE_NAME" \
    --store "$DATASTORE_NAME" \
    --schedule "$PRUNE_TIME" \
    --keep-last "$KEEP_LAST" 2>/dev/null || \
proxmox-backup-manager prune-job update "job-$DATASTORE_NAME" \
    --store "$DATASTORE_NAME" \
    --schedule "$PRUNE_TIME" \
    --keep-last "$KEEP_LAST"

# Update GC Schedule
proxmox-backup-manager datastore update "$DATASTORE_NAME" --gc-schedule "$GC_TIME"

echo "Maintenance configuration for '$DATASTORE_NAME' complete."

# --- 3. VERIFICATION ---
echo ""
echo "=========================================================="
echo "                   VERIFYING CONFIGURATION                "
echo "=========================================================="

proxmox-backup-manager prune-job list
