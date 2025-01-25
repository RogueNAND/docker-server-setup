# Copy script
cp /tmp/docker-server/import_github_keys.sh /usr/local/bin/import_github_keys.sh
chmod +x /usr/local/bin/import_github_keys.sh
sudo -u "$USERNAME" mkdir -p /home/"$USERNAME"/.ssh

apt install -y ssh-import-id

# Add cron entry
CRON_LINE="0 0 * * * /usr/local/bin/import_github_keys.sh"
CURRENT_CRON="$(crontab -l 2>/dev/null || true)"

# Run an initial import right away
echo -e "Importing keys"
/usr/local/bin/import_github_keys.sh

# update SSH config
echo -e "Updating SSH config"
{
  echo "PermitRootLogin prohibit-password"
  echo "PubkeyAuthentication yes"
  echo "PasswordAuthentication no"
  echo "X11Forwarding no"
} >> /etc/ssh/sshd_config
