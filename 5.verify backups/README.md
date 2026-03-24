This is a crucial maintenance script for Proxmox Backup Server (PBS). It ensures that your backup chunks are not corrupted by running a verification task and alerting you if a problem is found.

Below is the description for your README.md and the clean, formatted code for your GitHub repository.

📘 README.md Description
Script: Proxmox Backup Server Verification & Alerting
This script automates the integrity checking of backups stored on a Proxmox Backup Server. It verifies that the data chunks on the disk match their original checksums and sends an email notification if any corruption or errors are detected.

Key Features:
Interactive Selection: Displays all available datastores before asking the user which one to verify.

Automated Logging: Saves the output of every verification run to /var/log/pbs_verify.log for future auditing.

Smart Alerting: Uses the mail utility to send the full JSON error report to the administrator only if the verification fails.

Data Integrity: Helps prevent "bit rot" by ensuring your backups are actually recoverable before you need them.

Use Case:
Run this script as a Cron Job or manually once a week to ensure your long-term backup storage remains healthy.
