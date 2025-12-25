<?php
/**
 * ApertoDNS DDNS Provider for Synology DSM
 *
 * Installation:
 * 1. Copy this file to /usr/syno/bin/ddns/
 * 2. Add provider entry to /etc/ddns_provider.conf
 * 3. Restart DSM or DDNS service
 *
 * @author Andrea Ferro <support@apertodns.com>
 * @version 1.0.0
 * @link https://www.apertodns.com
 */

if ($argc !== 5) {
    echo "badparam";
    exit();
}

$hostname = $argv[1];  // Domain name (e.g., myhost.apertodns.com)
$username = $argv[2];  // Email or Token
$password = $argv[3];  // Password or Token
$ip = $argv[4];        // IP address to update

// Validate inputs
if (empty($hostname) || empty($password) || empty($ip)) {
    echo "badparam";
    exit();
}

// Build update URL
$url = "https://api.apertodns.com/nic/update?hostname=" . urlencode($hostname) . "&myip=" . urlencode($ip);

// Initialize cURL
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, true);
curl_setopt($ch, CURLOPT_TIMEOUT, 30);
curl_setopt($ch, CURLOPT_USERAGENT, "Synology-DDNS/1.0 ApertoDNS-Client");

// Set authentication
// If username is empty or same as password, use token auth (password:password)
if (empty($username) || $username === $password) {
    curl_setopt($ch, CURLOPT_USERPWD, $password . ":" . $password);
} else {
    curl_setopt($ch, CURLOPT_USERPWD, $username . ":" . $password);
}

// Execute request
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
// Note: curl_close() deprecated in PHP 8.0+, handle is closed automatically

// Handle response
if ($response === false) {
    echo "911";
    exit();
}

$response = trim(strtolower($response));

// Map DynDNS2 responses to Synology expected responses
// Synology expects: good, nochg, badauth, notfqdn, badagent, 911
if (strpos($response, 'good') === 0) {
    echo "good";
} elseif (strpos($response, 'nochg') === 0) {
    echo "nochg";
} elseif ($response === 'badauth' || $httpCode === 401) {
    echo "badauth";
} elseif ($response === 'notfqdn' || $response === 'nohost') {
    echo "notfqdn";
} elseif ($response === 'abuse' || $response === 'badagent') {
    echo "badagent";
} else {
    // Unknown response - return as-is for debugging
    echo "911 " . $response;
}
?>
