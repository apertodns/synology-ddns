#!/bin/bash
# ============================================================================
# ApertoDNS DDNS Update Script for Synology DSM Task Scheduler
#
# This script updates your ApertoDNS domain with your current public IP.
# Use this as an alternative to the native DDNS provider.
#
# Installation:
# 1. Save this script to a location on your NAS (e.g., /volume1/scripts/)
# 2. Make it executable: chmod +x /volume1/scripts/update-apertodns.sh
# 3. Create a scheduled task in Control Panel > Task Scheduler
# 4. Set it to run every 5-10 minutes
#
# Configuration:
# - DDNS_TOKEN: Your DDNS token from ApertoDNS dashboard (64 hex chars)
# - HOSTNAME: Your domain name (e.g., myhost.apertodns.com)
#
# @author Andrea Ferro <support@apertodns.com>
# @version 1.0.0
# @link https://www.apertodns.com
# ============================================================================

# ===== CONFIGURATION - EDIT THESE VALUES =====
DDNS_TOKEN="YOUR_DDNS_TOKEN_HERE"
HOSTNAME="yourhost.apertodns.com"
# ==============================================

# Optional: Log file path (comment out to disable logging)
LOG_FILE="/var/log/apertodns-ddns.log"

# API endpoint
API_URL="https://api.apertodns.com/nic/update"

# Function to log messages
log_message() {
    if [ -n "$LOG_FILE" ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
    fi
}

# Validate configuration
if [ "$DDNS_TOKEN" = "YOUR_DDNS_TOKEN_HERE" ] || [ -z "$DDNS_TOKEN" ]; then
    log_message "ERROR: DDNS_TOKEN not configured"
    echo "Error: Please configure your DDNS token"
    exit 1
fi

if [ "$HOSTNAME" = "yourhost.apertodns.com" ] || [ -z "$HOSTNAME" ]; then
    log_message "ERROR: HOSTNAME not configured"
    echo "Error: Please configure your hostname"
    exit 1
fi

# Get current public IP
CURRENT_IP=$(curl -s https://api.ipify.org 2>/dev/null)

if [ -z "$CURRENT_IP" ]; then
    # Fallback to alternative IP service
    CURRENT_IP=$(curl -s https://ifconfig.me 2>/dev/null)
fi

if [ -z "$CURRENT_IP" ]; then
    log_message "ERROR: Could not determine public IP"
    echo "Error: Could not determine public IP"
    exit 1
fi

log_message "Current IP: $CURRENT_IP"

# Update DNS record
RESPONSE=$(curl -s -u "${DDNS_TOKEN}:${DDNS_TOKEN}" \
    "${API_URL}?hostname=${HOSTNAME}&myip=${CURRENT_IP}")

# Parse response
case "$RESPONSE" in
    good*|nochg*)
        log_message "SUCCESS: $RESPONSE (IP: $CURRENT_IP)"
        echo "Update successful: $RESPONSE"
        exit 0
        ;;
    badauth*)
        log_message "ERROR: Authentication failed - check your token"
        echo "Error: Authentication failed"
        exit 1
        ;;
    notfqdn*|nohost*)
        log_message "ERROR: Domain not found - check hostname"
        echo "Error: Domain not found"
        exit 1
        ;;
    *)
        log_message "ERROR: Unexpected response: $RESPONSE"
        echo "Error: Unexpected response: $RESPONSE"
        exit 1
        ;;
esac
