#!/bin/bash

echo "----------------------------------------------------------"
echo "PROXMOX BACKUP SERVER: CREATE SERVICE ACCOUNT"
echo "----------------------------------------------------------"

# --- 1. INTERACTIVE INPUTS ---
read -p "Enter the NEW Username (e.g., pve-backup): " NEW_USER
read -p "Enter the Target Datastore Name (e.g., ZFSgalacpool): " DATASTORE
read -s -p "Enter the Password for $NEW_USER: " NEW_PASS
echo ""

# --- 2. EXECUTION ---
echo "Creating user $NEW_USER@pbs..."

# Create the user in the internal PBS realm
proxmox-backup-manager user create "$NEW_USER@pbs" --password "$NEW_PASS"

if [ $? -eq 0 ]; then
    echo "User created successfully."
    
    echo "Assigning 'DatastoreBackup' role to $NEW_USER@pbs on /$DATASTORE..."
    
    # Assign the Role: /datastore/<name> is the path required by PBS
    proxmox-backup-manager acl update "/datastore/$DATASTORE" DatastoreBackup --auth-id "$NEW_USER@pbs"
    
    echo "----------------------------------------------------------"
    echo "SUCCESS: User $NEW_USER@pbs is ready to use!"
    echo "Path: /datastore/$DATASTORE"
    echo "Role: DatastoreBackup"
else
    echo "----------------------------------------------------------"
    echo "ERROR: Failed to create user. Perhaps it already exists?"
fi
