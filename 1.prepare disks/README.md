Script Overview (prepare.sh): Automated ZFS Pool & PBS Datastore Creator:

This script streamlines the post-installation storage setup for Proxmox Backup Server. It detects the system disk to prevent accidental wipes, configures ZFS (Single or Mirror), and integrates the new storage directly into the PBS management system.

Script detecta y muestra los discos fisicos disponibles en PBS, permite crear un RAID 1 por software con los discos que indiques, creara un ZFS datastore (lugar donde se guardaran los respaldos). Las variables que debe agregar el usuario son:

EMAIL: The email address where Proxmox Backup Server (PBS) will send alerts
DISK_A_RAW: The identifier of the first physical disk you want to use.
DISK_B_RAW The identifier of the second disk (only if creating a Mirror).
POOL_NAME: A custom name for your new ZFS storage pool and PBS datastore.


Pantallas:
1) Muestra los discos fisicos disponibles.

 <img width="576" height="240" alt="image" src="https://github.com/user-attachments/assets/3f83d1ed-9d16-4df8-a5fe-bc8860eea372" />

 2) Solicita las variables:

EMAIL: The email address where Proxmox Backup Server (PBS) will send alerts
DISK_A_RAW: The identifier of the first physical disk you want to use.
DISK_B_RAW The identifier of the second disk (only if creating a Mirror).
POOL_NAME: A custom name for your new ZFS storage pool and PBS datastore.

<img width="649" height="333" alt="image" src="https://github.com/user-attachments/assets/99cede99-7303-443e-9109-e6b02d58f254" />


Nota: Al escoger un solo disco por ejemplo sda


Key Features:

Intelligent OS Detection: Uses lsblk and findmnt to identify the physical disk hosting the root partition (even on LVM) to ensure it is never formatted by mistake.

Flexible Redundancy: Supports both Single Disk (no redundancy) and Mirror (RAID 1) configurations based on user input.

Proxmox Integration: Automatically updates the root user's email and registers the new ZFS pool as a PBS Datastore using the proxmox-backup-manager CLI.

ZFS Optimization: Applies best-practice settings, including lz4 compression and atime=off for improved performance.

Workflow Logic
System Identification: It finds the /dev/ path of the OS drive (obtiene los discos fisicos disponibles en el PBS).

User Input: Prompts for notification email, disk identifiers (e.g., sdb, sdc), and the desired pool name.

Safety Validation: Blocks the script if the user selects the OS drive or tries to mirror a disk to itself.

Disk Preparation: Uses wipefs to clear existing signatures/partitions.

Creation & Tuning: Creates the ZFS pool with ashift=12 (standard for modern 4K sector drives).

Verification: Checks the health of the pool and confirms registration within the PBS environment.
