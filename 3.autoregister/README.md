Script Description: Proxmox VE to PBS Linker
This script automates the process of connecting a Proxmox Virtual Environment (PVE) node to a Proxmox Backup Server (PBS). Instead of manually navigating the Web GUI, this script uses the pvesm (Proxmox External Storage Manager) command-line tool to establish a secure link between the two systems.

Variables:

PBS_IP: Captures the network address of the destination server. (PBS) Tells PVE where to find the Backup Server on the network.
STORE:  Defines the specific target folder on the PBS. Points PVE to the correct backup destination (Datastore).
FINGERPRINT: Provides the SHA-256 SSL certificate string. Ensures the connection is secure and encrypted (Certificate Pinning).
PBS_USER: Identifies the service account being used, Authenticates the connection (usually user@pbs).
PASS: Stores the account's password securely, Grants access to the Datastore for writing/reading backups.
STORAGE_ID: Hardcoded as "Servidor-PBS",Sets the Local Name that will appear in the Proxmox VE "Storage" list.

Key Functionalities
Interactive Configuration: Prompts the user for the PBS IP, Datastore name, and the unique SSL Fingerprint for a secure handshake.

Credential Security: Uses read -s to capture the password, ensuring it is not printed to the terminal screen during input.

Automated Storage Registration: Executes pvesm add pbs, which handles the backend configuration and creates the storage entry (ID: Servidor-PBS) in PVE.

Status Verification: Runs a post-execution check using pvesm status to confirm the new storage is online and reachable.

Why use this?
Linking a Backup Server is a critical step for Disaster Recovery. This script ensures that all required parameters (especially the long Fingerprint string) are entered correctly, reducing the risk of manual configuration errors.
