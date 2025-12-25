#!/bin/bash
# ============================================================================
# ApertoDNS DDNS Provider - Synology DSM Installer
#
# This script automatically installs the ApertoDNS DDNS provider on your
# Synology NAS. Run this script via SSH as root.
#
# Usage:
#   curl -sSL https://raw.githubusercontent.com/apertodns/synology-ddns/main/install.sh | sudo bash
#
# Or download and run manually:
#   wget https://raw.githubusercontent.com/apertodns/synology-ddns/main/install.sh
#   chmod +x install.sh
#   sudo ./install.sh
#
# @author Andrea Ferro <support@apertodns.com>
# @version 1.0.0
# @link https://www.apertodns.com
# ============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo ""
echo "=========================================="
echo "  ApertoDNS DDNS Provider for Synology"
echo "=========================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: Please run as root (sudo)${NC}"
    exit 1
fi

# Check if this is a Synology system
if [ ! -d "/usr/syno" ]; then
    echo -e "${RED}Error: This doesn't appear to be a Synology DSM system${NC}"
    exit 1
fi

echo -e "${GREEN}[1/4]${NC} Downloading provider script..."

# Create directory if it doesn't exist
mkdir -p /usr/syno/bin/ddns

# Download the PHP provider script
curl -sSL "https://raw.githubusercontent.com/apertodns/synology-ddns/main/apertodns.php" \
    -o /usr/syno/bin/ddns/apertodns.php

# Set permissions
chmod 755 /usr/syno/bin/ddns/apertodns.php

echo -e "${GREEN}[2/4]${NC} Provider script installed"

echo -e "${GREEN}[3/4]${NC} Adding provider to configuration..."

# Check if provider already exists in config
if grep -q "ApertoDNS" /etc/ddns_provider.conf 2>/dev/null; then
    echo -e "${YELLOW}Note: ApertoDNS provider already exists in configuration${NC}"
else
    # Add provider configuration
    cat >> /etc/ddns_provider.conf << 'EOF'

[ApertoDNS - Token]
    modulepath=/usr/syno/bin/ddns/apertodns.php
    queryurl=https://api.apertodns.com/nic/update

[ApertoDNS - Email]
    modulepath=/usr/syno/bin/ddns/apertodns.php
    queryurl=https://api.apertodns.com/nic/update
EOF
    echo -e "${GREEN}Provider configuration added${NC}"
fi

echo -e "${GREEN}[4/4]${NC} Installation complete!"

echo ""
echo "=========================================="
echo "  Installation Successful!"
echo "=========================================="
echo ""
echo "Next steps:"
echo ""
echo "1. Go to: Control Panel > External Access > DDNS"
echo "2. Click 'Add' and select:"
echo "   - 'ApertoDNS - Token' for DDNS Token authentication"
echo "   - 'ApertoDNS - Email' for email/password authentication"
echo ""
echo "3. For Token auth:"
echo "   - Username: your DDNS token (64 hex characters)"
echo "   - Password: your DDNS token (same as username)"
echo ""
echo "4. For Email auth:"
echo "   - Username: your ApertoDNS email"
echo "   - Password: your ApertoDNS password"
echo ""
echo "5. Hostname: your domain (e.g., myhost.apertodns.com)"
echo ""
echo "6. Click 'Test Connection' to verify"
echo ""
echo "Find your DDNS Token at:"
echo "  Dashboard > Domains > [your domain] > DDNS Token"
echo ""
echo "Documentation: https://www.apertodns.com/docs#rn-synology"
echo "Support: support@apertodns.com"
echo ""
