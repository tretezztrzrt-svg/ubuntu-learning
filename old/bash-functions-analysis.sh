#!/bin/bash
# =============================================================================
# Directory Analysis Functions
# Funktionen zur Analyse von Verzeichnisgrößen
# =============================================================================

# Ordnergrößen anzeigen (die buggy Version korrigiert)
function folder_size() {
    if [ -z "$1" ]; then
        echo "📊 Top 10 largest directories in current:"
        du -sh * 2>/dev/null | sort -hr | head -10
    else
        echo "📊 Size of '$1':"
        du -sh "$1" 2>/dev/null
    fi
}

# Detaillierte Ordneranalyse
function analyze_dirs() {
    local limit="${2:-50}"
    echo "=== Largest directories in $1 ==="
    du -xs "$1"/* 2>/dev/null | sort -nr | head -"$limit" | awk '{$2=$2; print}' | column -t
}
