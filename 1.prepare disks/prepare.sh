#!/bin/bash

# --- 1. DETECT SYSTEM DISK (Improved for LVM) ---
SYSTEM_DISK=$(lsblk -no PKNAME $(lsblk -no PKNAME $(findmnt -nvo SOURCE /)) | head -n1)
if [[ -z "$SYSTEM_DISK" ]]; then
    SYSTEM_DISK=$(lsblk -rno NAME,MOUNTPOINT | grep ' /$' | awk '{print $1}' | sed 's/[0-9]*//g' | sed 's/p[0-9]*//g')
fi

# --- 2. DISPLAY DISK INFO ---
echo "Current Disk Configuration:"
lsblk -o NAME,SIZE,TYPE,MOUNTPOINTS
echo "----------------------------------------------------------"
echo "SYSTEM WARNING: The OS is installed on: /dev/$SYSTEM_DISK"
echo "----------------------------------------------------------"

# --- 3. INTERACTIVE USER VARIABLES ---
read -p "Enter your notification email: " EMAIL
read -p "Enter the FIRST disk (e.g., sdb): " DISK_A_RAW
read -p "Enter the SECOND disk for Mirror (Leave empty if none): " DISK_B_RAW
read -p "Enter the name for your new ZFS Pool: " POOL_NAME

# --- 4. SAFETY & LOGIC CHECKS ---
if [[ "$DISK_A_RAW" == "$SYSTEM_DISK" || "$DISK_B_RAW" == "$SYSTEM_DISK" ]]; then
    echo "ERROR: Critical Safety Stop! You cannot use the system disk ($SYSTEM_DISK)."
    exit 1
fi

if [[ -z "$DISK_B_RAW" ]]; then
    MODE="SINGLE"
    DISK_A="/dev/$DISK_A_RAW"
    echo "Mode selected: SINGLE DISK on $DISK_A"
elif [[ "$DISK_A_RAW" == "$DISK_B_RAW" ]]; then
    echo "ERROR: You cannot mirror a disk to itself."
    exit 1
else
    MODE="MIRROR"
    DISK_A="/dev/$DISK_A_RAW"
    DISK_B="/dev/$DISK_B_RAW"
    echo "Mode selected: ZFS MIRROR on $DISK_A and $DISK_B"
fi

# --- 5. FINAL CONFIRMATION ---
read -p "Proceed with wiping data and creating $POOL_NAME? (y/N): " CONFIRM
if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
    echo "Exiting..."
    exit 1
fi

# --- 6. APPLY CONFIGURATION ---
echo "Configuring Email..."
proxmox-backup-manager user update root@pam --email "$EMAIL"

echo "Wiping disk(s)..."
wipefs -a "$DISK_A"
[[ "$MODE" == "MIRROR" ]] && wipefs -a "$DISK_B"

echo "Creating ZFS Pool ($MODE)..."
if [[ "$MODE" == "MIRROR" ]]; then
    zpool create -f -o ashift=12 "$POOL_NAME" mirror "$DISK_A" "$DISK_B"
else
    zpool create -f -o ashift=12 "$POOL_NAME" "$DISK_A"
fi

zfs set compression=lz4 "$POOL_NAME"
zfs set atime=off "$POOL_NAME"

echo "Registering Datastore..."
proxmox-backup-manager datastore create "$POOL_NAME" "/$POOL_NAME"

# --- 7. VERIFICATION SECTION ---
echo "----------------------------------------------------------"
echo "VERIFYING DEPLOYMENT..."
echo "----------------------------------------------------------"

# Check if the ZFS pool is ONLINE
ZFS_STATUS=$(zpool list -H -o health "$POOL_NAME")
echo "ZFS Pool '$POOL_NAME' Status: $ZFS_STATUS"

# Check if PBS recognizes the datastore
PBS_STATUS=$(proxmox-backup-manager datastore list | grep "$POOL_NAME")
if [[ -n "$PBS_STATUS" ]]; then
    echo "PBS Datastore Registration: SUCCESS"
else
    echo "PBS Datastore Registration: FAILED"
fi

# Show final storage usage
df -h "/$POOL_NAME"

echo "----------------------------------------------------------"
echo "Setup Complete! Pool '$POOL_NAME' is ready."
