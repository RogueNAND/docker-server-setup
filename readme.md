## Simple setup script for Debian / Ubuntu servers

Run as root on a fresh installation

```bash
wget -q https://raw.githubusercontent.com/roguenand/docker-server-setup/main/setup.sh -O setup.sh && chmod +x setup.sh && sudo ./setup.sh
```

### Hardens and configures system

- Creates non-root user with sudo and docker privileges.

- Updates packages and enables unattended-upgrades.

- Adds SSH keys from github account.

- Ensures the server is set to your preferred time zone.

- Adds aliases like `dcu` / `dcd` / `dcr` for docker compose up / down / restart.

- Configures network setting (static or DHCP).

## Notes

Debian / Ubuntu derivatives like Raspbian should work but haven't been tested.

If you need to open a port for Wireguard or another service, [allow the port in iptables](https://www.digitalocean.com/community/tutorials/iptables-essentials-common-firewall-rules-and-commands) and run `sudo netfilter-persistent save` to save rules.

### Logs

Nginx Proxy Manager logs are located in `~/server/npm/data/logs/`. You need the ID of the proxy host you want to view, which you can find by clicking the three dots in NPM. These logs are limited to web requests and are rotated weekly.

Example command to view live log: `tail -f ~/server/npm/data/logs/proxy-host-1_access.log`

Example command search log for IP: `grep "0.0.0.0" ~/server/npm/data/logs/proxy-host-1_access.log`
