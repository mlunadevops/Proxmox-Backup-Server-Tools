Script Description: PBS Service Account Creator (este script corre en PBS)
This script automates the creation of a Service Account within Proxmox Backup Server (PBS). It is designed to follow the principle of "least privilege," creating a dedicated user with access only to a specific datastore rather than using the administrative root account.

Este script crea una cuenta de servicio dentro de PBS, creando un usuario dedicado con acceso especifico al datastore creado en el paso 1.

Variables:

NEW_USER: Defines the name of the identity. The script appends @pbs to this to place the user in the internal authentication realm.
DATASTORE Specifies which storage folder the user is allowed to access.
NEW_PASS: Captures the secret string used for authentication. The -s flag ensures the password doesn't leak in the terminal history

Key Functionalities

Identity Management: Creates a new user within the internal PBS realm (@pbs).

Secure Input: Uses the -s flag for the password prompt, ensuring the password is not visible on the screen while the user types it.

ACL (Access Control List) Configuration: Automatically assigns the DatastoreBackup role to the new user.

Path Mapping: Correctly maps the permission to the internal PBS path format: /datastore/DATASTORE_NAME.

Use Case
Use this script when you need to connect a Proxmox VE (PVE) node to your Backup Server. Instead of sharing the master password, you create a unique user for that specific node and its designated storage.
