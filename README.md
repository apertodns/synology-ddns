# ApertoDNS DDNS Provider for Synology DSM

Official ApertoDNS DDNS provider integration for Synology NAS devices running DSM.

## Quick Install

SSH into your Synology NAS as root and run:

```bash
curl -sSL https://raw.githubusercontent.com/apertodns/synology-ddns/main/install.sh | sudo bash
```

## Manual Installation

### Method 1: Native DDNS Provider (Recommended)

1. **Download the provider script:**
   ```bash
   sudo curl -sSL https://raw.githubusercontent.com/apertodns/synology-ddns/main/apertodns.php \
       -o /usr/syno/bin/ddns/apertodns.php
   sudo chmod 755 /usr/syno/bin/ddns/apertodns.php
   ```

2. **Add provider configuration:**
   ```bash
   sudo cat >> /etc/ddns_provider.conf << 'EOF'

   [ApertoDNS - Token]
       modulepath=/usr/syno/bin/ddns/apertodns.php
       queryurl=https://api.apertodns.com/nic/update

   [ApertoDNS - Email]
       modulepath=/usr/syno/bin/ddns/apertodns.php
       queryurl=https://api.apertodns.com/nic/update
   EOF
   ```

3. **Configure in DSM:**
   - Go to **Control Panel > External Access > DDNS**
   - Click **Add**
   - Select **ApertoDNS - Token** or **ApertoDNS - Email**
   - Enter your credentials (see below)
   - Click **Test Connection**

### Method 2: Task Scheduler Script

If you prefer using DSM's Task Scheduler:

1. **Download the update script:**
   ```bash
   curl -sSL https://raw.githubusercontent.com/apertodns/synology-ddns/main/update-apertodns.sh \
       -o /volume1/scripts/update-apertodns.sh
   chmod +x /volume1/scripts/update-apertodns.sh
   ```

2. **Edit the script** and set your credentials:
   ```bash
   DDNS_TOKEN="YOUR_DDNS_TOKEN_HERE"
   HOSTNAME="yourhost.apertodns.com"
   ```

3. **Create a scheduled task:**
   - Go to **Control Panel > Task Scheduler**
   - Create a new **User-defined script** task
   - Set it to run every 5-10 minutes
   - Command: `/volume1/scripts/update-apertodns.sh`

## Authentication Methods

### Token Authentication (Recommended)
- **Username:** Your DDNS Token (64 hex characters)
- **Password:** Your DDNS Token (same as username)

### Email Authentication
- **Username:** Your ApertoDNS account email
- **Password:** Your ApertoDNS account password

## Where to Find Your DDNS Token

1. Log in to [ApertoDNS Dashboard](https://www.apertodns.com)
2. Go to **Domains** section
3. Select your domain
4. Find the **DDNS Token** field (64 character hex string)

## Troubleshooting

### Test the provider manually:
```bash
php /usr/syno/bin/ddns/apertodns.php yourhost.apertodns.com TOKEN TOKEN 1.2.3.4
```

### Expected responses:
- `good` - Update successful
- `nochg` - IP unchanged (no update needed)
- `badauth` - Authentication failed (check credentials)
- `notfqdn` - Domain not found
- `911` - Server error

### Check logs:
```bash
# For Task Scheduler method
cat /var/log/apertodns-ddns.log
```

### Test with curl:
```bash
curl -u "TOKEN:TOKEN" "https://api.apertodns.com/nic/update?hostname=yourhost.apertodns.com&myip=$(curl -s https://api.ipify.org)"
```

## Files Included

| File | Description |
|------|-------------|
| `apertodns.php` | Main DDNS provider script for DSM |
| `ddns_provider.conf.add` | Provider configuration snippet |
| `update-apertodns.sh` | Alternative script for Task Scheduler |
| `install.sh` | Automatic installer script |

## Requirements

- Synology DSM 6.x or 7.x
- SSH access (for installation)
- ApertoDNS account with at least one domain

## Support

- **Documentation:** https://www.apertodns.com/docs#rn-synology
- **Email:** support@apertodns.com
- **Website:** https://www.apertodns.com

## License

MIT License - Copyright (c) 2024 ApertoDNS

## Author

Andrea Ferro <support@apertodns.com>
