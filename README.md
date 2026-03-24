# Proxmox-Backup-Server-Tools

Script Overview: Automated ZFS Pool & PBS Datastore Creator
This script streamlines the post-installation storage setup for Proxmox Backup Server. It detects the system disk to prevent accidental wipes, configures ZFS (Single or Mirror), and integrates the new storage directly into the PBS management system.

Key Features
Intelligent OS Detection: Uses lsblk and findmnt to identify the physical disk hosting the root partition (even on LVM) to ensure it is never formatted by mistake.

Flexible Redundancy: Supports both Single Disk (no redundancy) and Mirror (RAID 1) configurations based on user input.

Proxmox Integration: Automatically updates the root user's email and registers the new ZFS pool as a PBS Datastore using the proxmox-backup-manager CLI.

ZFS Optimization: Applies best-practice settings, including lz4 compression and atime=off for improved performance.

Workflow Logic
System Identification: It finds the /dev/ path of the OS drive.

User Input: Prompts for notification email, disk identifiers (e.g., sdb, sdc), and the desired pool name.

Safety Validation: Blocks the script if the user selects the OS drive or tries to mirror a disk to itself.

Disk Preparation: Uses wipefs to clear existing signatures/partitions.

Creation & Tuning: Creates the ZFS pool with ashift=12 (standard for modern 4K sector drives).

Verification: Checks the health of the pool and confirms registration within the PBS environment.
