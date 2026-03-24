Script: PBS Maintenance Automator (Prune & GC)
This script simplifies the lifecycle management of backup data on a Proxmox Backup Server. It allows administrators to quickly set retention policies and schedule background maintenance tasks to ensure the storage doesn't fill up with obsolete data.

Variable Breakdown for your Docs:
KEEP_LAST: The number of most recent backups to save.

PRUNE_TIME: The time (24h format) when old references are removed.

GC_TIME: The time when the server actually deletes the data from the disk. Note: It is best to schedule GC after Pruning.


Key Features:
Interactive Datastore Detection: Lists active datastores so the user can accurately identify the target storage.

Automated Pruning: Configures or updates a "Prune Job" to automatically remove old backup snapshots based on a "Keep Last" policy.

Garbage Collection (GC) Scheduling: Sets the specific time for the server to perform a deep-clean of the storage chunks, reclaiming physical disk space.

Idempotent Execution: Smartly detects if a Prune Job already exists; it will update the existing job rather than failing with an "already exists" error.

Instant Verification: Finalizes the process by listing the active Prune Jobs to confirm the new settings are active.

Use Case:
Use this script during the initial setup of a new Datastore or when you need to standardize retention policies across multiple PBS instances.
