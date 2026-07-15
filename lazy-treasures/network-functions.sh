#!/bin/bash
# =============================================================================
# Network Functions
# Funktionen für Netzwerk-Diagnostik und Verbindungsprüfung
# =============================================================================

# Ping mit verschiedenen Targets
function quick_ping() {
    local targets=("8.8.8.8" "1.1.1.1" "google.com")
    for target in "${targets[@]}"; do
        echo "🔹 Testing: $target"
        ping -c 3 -W 1 "$target" 2>&1 | tail -3
    done
}

# Check if port is open remotely
function port_scan_simple() {
    if [ $# -lt 2 ]; then
        echo "Usage: port_scan_simple <host> <port>"
        return 1
    fi
    timeout 2 bash -c "echo > /dev/tcp/$1/$2" 2>/dev/null && echo "✅ Port $2 OPEN on $1" || echo "❌ Port $2 CLOSED on $1"
}

# Get external IP address
function external_ip() {
    echo "External IP Addresses:"
    echo -n "  Via ifconfig.me: "; curl -s -m 3 ifconfig.me 2>/dev/null || echo "Failed"
}

# Wi-Fi connection info
function wifi_info() {
    if ! command -v nmcli &>/dev/null; then
        echo "❌ nmcli not found (NetworkManager not installed, common on servers)"
        return 1
    fi
    nmcli -g ACTIVE,SSID,SIGNAL device wifi | head -10
}
