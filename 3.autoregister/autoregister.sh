#!/bin/bash

echo "----------------------------------------------------------"
echo "PROXMOX VE: LINKING TO BACKUP SERVER (PBS)"
echo "----------------------------------------------------------"

# --- 1. INTERACTIVE INPUTS ---
read -p "Enter the PBS IP Address (e.g., 1.1.1.1): " PBS_IP
read -p "Enter the Datastore Name: " STORE
read -p "Enter the Fingerprint: " FINGERPRINT

# Added interactive Username
read -p "Enter the PBS Username (e.g., backup-user@pbs): " PBS_USER

# 'read -s' hides the password for security
read -s -p "Enter the password for $PBS_USER: " PASS
echo "" # Adds a new line after the hidden password

# --- 2. CONFIGURATION ---
STORAGE_ID="Servidor-PBS"

# --- 3. EXECUTION ---
echo "Connecting to $PBS_IP as $PBS_USER..."

pvesm add pbs "$STORAGE_ID" \
    --server "$PBS_IP" \
    --datastore "$STORE" \
    --username "$PBS_USER" \
    --password "$PASS" \
    --fingerprint "$FINGERPRINT"

# --- 4. VERIFICATION ---
if [ $? -eq 0 ]; then
    echo "----------------------------------------------------------"
    echo "SUCCESS: Storage '$STORAGE_ID' added to PVE!"
    pvesm status | grep "$STORAGE_ID"
else
    echo "----------------------------------------------------------"
    echo "ERROR: Failed to add storage. Check your credentials and permissions."
fi
