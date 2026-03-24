Script: Proxmox VE Dual Daily Backup Scheduler
This script automates the creation and management of redundant daily backup schedules in a Proxmox VE cluster. It ensures that your Virtual Machines (VMs) or Containers (LXCs) are backed up twice a day at user-defined intervals.

Variables:

STORAGE_ID: The name of the Proxmox storage where the backup files will be saved.
VMIDS: A comma-separated list of IDs. If left blank, the script logic sets all_flag to 1.
TIME1 / TIME2: Expected in 24-hour format (e.g., 23:30)

Key Features:
API Integration: Uses pvesh to communicate directly with the Proxmox Cluster API.

Idempotent Logic: The script checks if a backup job already exists. If it does, it updates the settings; if not, it creates a new one.

Flexible Scheduling: Allows for custom time inputs and handles both specific VM IDs or "All VMs" globally.

Optimized Backups: Automatically sets backup parameters to Snapshot mode (no downtime) and ZSTD compression (high speed/efficiency).

Use Case:
Perfect for environments where you need a "morning" and "evening" backup sync to a specific storage (like a PBS datastore or a NAS) to ensure a low Recovery Point Objective (RPO).
