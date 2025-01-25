#!/usr/bin/env bash
#
# import_github_keys.sh
#
# Overwrites a specific local user's authorized_keys with all SSH keys
# from the specified GitHub username.

set -e

LOCAL_USER="fleetuser"     # Must match the user you create in setup.sh
GITHUB_USER="roguenand" # Replace with your GitHub username

echo "Importing GitHub keys for user '$LOCAL_USER' from account '$GITHUB_USER'..."

# Overwrite authorized_keys with the latest keys from GitHub
sudo -u "$LOCAL_USER" ssh-import-id gh:"$GITHUB_USER" -o /home/"$LOCAL_USER"/.ssh/authorized_keys

# Fix permissions
sudo chown "$LOCAL_USER":"$LOCAL_USER" /home/"$LOCAL_USER"/.ssh/authorized_keys
sudo chmod 600 /home/"$LOCAL_USER"/.ssh/authorized_keys

echo "Keys updated successfully."

