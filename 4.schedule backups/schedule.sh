#!/bin/bash

# --- 1. CONFIGURATION & PRE-FLIGHT ---
echo "----------------------------------------------------------"
echo "PROXMOX VE: DUAL DAILY BACKUP SETUP"
echo "----------------------------------------------------------"
echo "Checking available storage..."
pvesm status
echo "----------------------------------------------------------"

# Function to create or update a job
manage_job() {
    local job_id=$1
    local storage=$2
    local time=$3
    local vmid=$4
    local schedule="*-*-* $time:00"
    local all_flag=$( [[ -z "$vmid" ]] && echo 1 || echo 0 )

    # Check if the job already exists in the cluster
    if pvesh get /cluster/backup/"$job_id" >/dev/null 2>&1; then
        echo "Updating existing job: $job_id"
        pvesh set /cluster/backup/"$job_id" --storage "$storage" --schedule "$schedule" --mode snapshot --compress zstd --enabled 1 --all "$all_flag" ${vmid:+--vmid "$vmid"}
    else
        echo "Creating new job: $job_id"
        pvesh create /cluster/backup --id "$job_id" --storage "$storage" --schedule "$schedule" --mode snapshot --compress zstd --enabled 1 --all "$all_flag" ${vmid:+--vmid "$vmid"}
    fi
}

# --- 2. INTERACTIVE INPUTS ---
read -p "Enter the Storage ID (from the list above): " STORAGE_ID
read -p "Which VMs to backup? (e.g., 100,101 or leave empty for ALL): " VMIDS
read -p "First backup time (HH:MM): " TIME1
read -p "Second backup time (HH:MM): " TIME2

# --- 3. EXECUTION ---
manage_job "Daily-Backup-AM" "$STORAGE_ID" "$TIME1" "$VMIDS"
manage_job "Daily-Backup-PM" "$STORAGE_ID" "$TIME2" "$VMIDS"

echo "----------------------------------------------------------"
echo "SUCCESS: Dual daily backup schedule applied."
echo "Verify your jobs in the GUI under Datacenter -> Backup."
