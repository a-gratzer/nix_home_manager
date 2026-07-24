---
name: linux-admin
description: >-
  Linux server administration — system health checks, systemd service
  management, user account setup, disk cleanup, firewall configuration
  (UFW), SSL/TLS certificates via Let's Encrypt, PostgreSQL backups, SSH
  hardening, and kernel tuning. Use this skill whenever the user needs to
  administer a Linux server: diagnose system health, create systemd services,
  manage users and permissions, clean up disk space, configure firewalls,
  set up SSL certificates, back up databases, harden SSH, or tune kernel
  parameters. Also trigger on phrases like "check server health", "set up
  a service on Linux", "secure my server", "add a user with SSH access",
  "free up disk space on the server", or any system administration task
  on a Linux host.
---

# Linux Administration Skills

This skill covers common Linux server administration tasks. Each section is self-contained — use the one matching the current need. The patterns prioritize safety (dry-run where possible, backup before destructive operations) and follow the principle of least privilege (non-root service users, restricted systemd units, firewall defaults that deny inbound).

## Skill: System Health Check

Run a comprehensive health report:
```bash
#!/bin/bash
set -euo pipefail
echo "=== SYSTEM HEALTH CHECK: $(date) ==="

echo -e "\n--- UPTIME ---"
uptime

echo -e "\n--- MEMORY ---"
free -h

echo -e "\n--- DISK ---"
df -h | grep -v 'tmpfs\|snap\|docker'

echo -e "\n--- CPU LOAD ---"
top -bn1 | head -5

echo -e "\n--- TOP MEMORY PROCESSES ---"
ps aux --sort=-%mem | head -6

echo -e "\n--- TOP CPU PROCESSES ---"
ps aux --sort=-%cpu | head -6

echo -e "\n--- FAILED SYSTEMD UNITS ---"
systemctl --failed

echo -e "\n--- RECENT ERRORS (journalctl) ---"
journalctl -p err -n 20 --no-pager

echo -e "\n--- DISK I/O ---"
iostat -x 1 2 2>/dev/null | tail -n +3 || echo "iostat not available (install sysstat)"

echo -e "\n--- NETWORK ---"
ss -tlnp | head -20

echo -e "\n=== CHECK COMPLETE ==="
```

## Skill: Add a New Systemd Service

```bash
sudo tee /etc/systemd/system/myapp.service << 'EOF'
[Unit]
Description=My Application
After=network.target
Documentation=https://example.com/docs

[Service]
Type=simple
User=appuser
Group=appuser
WorkingDirectory=/opt/myapp
ExecStart=/opt/myapp/bin/server --config /opt/myapp/config.yml
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal
SyslogIdentifier=myapp

# Security hardening
NoNewPrivileges=yes
PrivateTmp=yes
ProtectSystem=full
ProtectHome=yes
ReadOnlyPaths=/opt/myapp/config.yml

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now myapp.service
sudo systemctl status myapp.service
```

## Skill: User Account Setup

```bash
# Create user
sudo useradd -m -s /bin/bash -c "John Doe" jdoe

# Set password
sudo passwd jdoe

# Add to groups
sudo usermod -aG docker,sudo,developers jdoe

# Setup SSH key
sudo mkdir -p /home/jdoe/.ssh
sudo cp /path/to/public_key.pub /home/jdoe/.ssh/authorized_keys
sudo chmod 700 /home/jdoe/.ssh
sudo chmod 600 /home/jdoe/.ssh/authorized_keys
sudo chown -R jdoe:jdoe /home/jdoe/.ssh

# Set password expiry policy
sudo chage -M 90 -W 7 jdoe  # Max 90 days, warn 7 days

# Verify
sudo chage -l jdoe
```

## Skill: Disk Space Cleanup

```bash
# Find largest directories
sudo du -sh /* 2>/dev/null | sort -rh | head -20
ncdu /    # Interactive exploration

# Clean package cache (apt)
sudo apt clean
sudo apt autoremove --purge

# Clean journal logs
sudo journalctl --vacuum-size=500M
sudo journalctl --vacuum-time=7d

# Find and remove old log files
sudo find /var/log -type f -name "*.log" -mtime +30 -ls

# Docker cleanup
docker system prune -af --volumes

# Find large files (>100M)
sudo find / -type f -size +100M -exec ls -lh {} \; 2>/dev/null

# Check deleted-but-open files (restart process to free)
sudo lsof | grep deleted | sort -nrk7 | head -20
```

## Skill: Firewall Setup with UFW

```bash
# Default deny incoming, allow outgoing
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow essential services
sudo ufw allow 22/tcp     # SSH
sudo ufw allow 80/tcp     # HTTP
sudo ufw allow 443/tcp    # HTTPS

# Allow from specific IP/subnet
sudo ufw allow from 10.0.0.0/8 to any port 3306

# Rate limit SSH
sudo ufw limit 22/tcp

# Enable
sudo ufw enable
sudo ufw status verbose
```

## Skill: SSL/TLS Certificate Setup (Let's Encrypt)

```bash
# Install certbot
sudo apt install certbot python3-certbot-nginx  # Nginx
# or: sudo apt install certbot python3-certbot-apache  # Apache

# Obtain certificate
sudo certbot --nginx -d example.com -d www.example.com

# Auto-renewal check
sudo certbot renew --dry-run

# Renewal is automatic via systemd timer:
# systemctl list-timers | grep certbot
```

Manual certificate check:
```bash
echo | openssl s_client -servername example.com -connect example.com:443 2>/dev/null | openssl x509 -noout -dates
```

## Skill: Database Backup (PostgreSQL)

```bash
# Single database
pg_dump -U postgres -d mydb -Fc -f mydb_$(date +%Y%m%d).dump

# All databases
pg_dumpall -U postgres -f all_dbs_$(date +%Y%m%d).sql

# Compressed
pg_dump -U postgres mydb | gzip > mydb_$(date +%Y%m%d).sql.gz

# Restore
pg_restore -U postgres -d mydb mydb.dump
gunzip -c mydb.sql.gz | psql -U postgres mydb
```

Automated backup script:
```bash
#!/bin/bash
set -euo pipefail
BACKUP_DIR="/backup/postgres"
DB="mydb"
RETENTION_DAYS=14
mkdir -p "$BACKUP_DIR"
pg_dump -U postgres -Fc "$DB" -f "$BACKUP_DIR/${DB}_$(date +%Y%m%d).dump"
find "$BACKUP_DIR" -name "${DB}_*.dump" -mtime +$RETENTION_DAYS -delete
```

## Skill: SSH Hardening

Edit `/etc/ssh/sshd_config`:
```
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
MaxAuthTries 3
MaxSessions 5
ClientAliveInterval 300
ClientAliveCountMax 2
X11Forwarding no
AllowUsers admin deploy
```

Apply:
```bash
sudo sshd -t          # Test config
sudo systemctl reload sshd
```

## Skill: Kernel Tuning

Check and apply performance tuning:
```bash
# Check current values
sysctl vm.swappiness
sysctl net.core.somaxconn

# Apply temporarily
sudo sysctl -w vm.swappiness=10
sudo sysctl -w net.core.somaxconn=65535

# Make persistent
sudo tee -a /etc/sysctl.d/99-tune.conf << 'EOF'
vm.swappiness=10
vm.vfs_cache_pressure=50
net.core.somaxconn=65535
net.ipv4.tcp_fastopen=3
fs.file-max=2097152
EOF

sudo sysctl -p /etc/sysctl.d/99-tune.conf
```
