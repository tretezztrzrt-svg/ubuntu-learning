#!/bin/bash
# =============================================================================
# Navigation Helper Functions
# Funktionen für Verzeichnisnavigation und Verwaltung
# =============================================================================

# Erstellen eines Ordners und sofortiges Wechseln hinein
function mkcd() {
    if [ -z "$1" ]; then
        echo "❌ usage: mkcd <directory_name>"
        return 1
    fi
    mkdir -p "$1" && cd "$1" && echo "✅ Created and entered: $1"
}

# Navigiere zur vorherigen Verzeichnisposition
function back() {
    cd - > /dev/null && pwd
}

# Tree-like directory navigation
function treedir() {
    local depth="${2:-5}"
    find "$1" -maxdepth "$depth" -type d | sed 's:[^/]*/:  :g;s:.::;s:^--$:|:'
}
