#!/bin/bash
set -e # Exit immediately if a command fails

# --- 1. DETECT SYSTEM DISK ---
# Finds the physical disk holding the root (/) partition
ROOT_PART=$(findmnt -nvo SOURCE /)
SYSTEM_DISK=$(lsblk -no PKNAME "$ROOT_PART" | head -n1)

# Fallback if PKNAME is empty (e.g., simple partitions)
if [[ -z "$SYSTEM_DISK" ]]; then
    SYSTEM_DISK=$(echo "$ROOT_PART" | sed 's/[0-9]*//g' | sed 's/p[0-9]*//g' | sed 's/\/dev\///g')
fi

# --- 2. DISPLAY DISK INFO ---
echo "----------------------------------------------------------"
echo "Current Disk Configuration:"
lsblk -o NAME,SIZE,TYPE,MOUNTPOINTS
echo "----------------------------------------------------------"
echo "SYSTEM WARNING: OS detected on: /dev/$SYSTEM_DISK"
echo "----------------------------------------------------------"

# --- 3. INTERACTIVE USER VARIABLES ---
read -p "Enter notification email: " EMAIL
read -p "Enter FIRST disk (e.g., sdb): " DISK_A_RAW
read -p "Enter SECOND disk for Mirror (Leave empty for Single): " DISK_B_RAW
read -p "Enter ZFS Pool name: " POOL_NAME

# --- 4. SAFETY & LOGIC CHECKS ---
# Remove /dev/ prefix if user added it manually
DISK_A_RAW=${DISK_A_RAW#/dev/}
DISK_B_RAW=${DISK_B_RAW#/dev/}

if [[ "$DISK_A_RAW" == "$SYSTEM_DISK" || "$DISK_B_RAW" == "$SYSTEM_DISK" ]]; then
    echo "ERROR: Safety Stop! You cannot use the system disk ($SYSTEM_DISK)."
    exit 1
fi

if [[ ! -b "/dev/$DISK_A_RAW" ]]; then
    echo "ERROR: Device /dev/$DISK_A_RAW does not exist."
    exit 1
fi

if [[ -z "$DISK_B_RAW" ]]; then
    MODE="SINGLE"
    DISK_A="/dev/$DISK_A_RAW"
    echo "Mode: SINGLE DISK on $DISK_A"
else
    if [[ "$DISK_A_RAW" == "$DISK_B_RAW" ]]; then
        echo "ERROR: Cannot mirror a disk to itself."
        exit 1
    fi
    MODE="MIRROR"
    DISK_A="/dev/$DISK_A_RAW"
    DISK_B="/dev/$DISK_B_RAW"
    echo "Mode: ZFS MIRROR on $DISK_A and $DISK_B"
fi

# --- 5. FINAL CONFIRMATION ---
read -p "PROCEED WITH WIPING DATA? (y/N): " CONFIRM
case "$CONFIRM" in
    [yY][eE][sS]|[yY]) 
        echo "Starting deployment..."
        ;;
    *)
        echo "Aborted by user."
        exit 1
        ;;
esac

# --- 6. APPLY CONFIGURATION ---
echo "Updating root email to $EMAIL..."
proxmox-backup-manager user update root@pam --email "$EMAIL"

echo "Wiping signatures..."
wipefs -a "$DISK_A"
[[ "$MODE" == "MIRROR" ]] && wipefs -a "$DISK_B"

echo "Creating ZFS Pool..."
if [[ "$MODE" == "MIRROR" ]]; then
    zpool create -f -o ashift=12 "$POOL_NAME" mirror "$DISK_A" "$DISK_B"
else
    zpool create -f -o ashift=12 "$POOL_NAME" "$DISK_A"
fi

# Optimization for Backup Workloads
zfs set compression=lz4 "$POOL_NAME"
zfs set atime=off "$POOL_NAME"
zfs set xattr=sa "$POOL_NAME"

echo "Registering PBS Datastore..."
proxmox-backup-manager datastore create "$POOL_NAME" "/$POOL_NAME"

# --- 7. VERIFICATION ---
echo "----------------------------------------------------------"
echo "VERIFYING DEPLOYMENT..."
zpool list -v "$POOL_NAME"
df -h "/$POOL_NAME"
echo "----------------------------------------------------------"
echo "Setup Complete!"
