#!/bin/bash
# =============================================================================
# Bash Functions Loader
# Lädt alle Funktionen aus den einzelnen Kategorien-Dateien
# =============================================================================
# 
# Verwende diese Datei in deiner ~/.bashrc mit:
#   source ~/.bash/bash-functions-loader.sh
#
# ODER lade einzelne Kategorien direkt:
#   source ~/.bash/bash-functions-navigation.sh
#   source ~/.bash/bash-functions-search.sh
#   etc.
#
# =============================================================================

BASH_FUNCTIONS_DIR="${HOME}/.bash"

# Array der Funktions-Module
declare -a function_modules=(
    "bash-functions-navigation.sh"
    "bash-functions-search.sh"
    "bash-functions-analysis.sh"
    "bash-functions-archive.sh"
    "bash-functions-monitoring.sh"
    "bash-functions-network.sh"
    "bash-functions-security.sh"
    "bash-functions-cleanup.sh"
    "bash-functions-development.sh"
    "bash-functions-productivity.sh"
)

# Lade alle Module
for module in "${function_modules[@]}"; do
    if [ -f "$BASH_FUNCTIONS_DIR/$module" ]; then
        source "$BASH_FUNCTIONS_DIR/$module"
    else
        echo "⚠️ Warning: $module not found in $BASH_FUNCTIONS_DIR"
    fi
done

echo "✅ Bash functions loaded from: $BASH_FUNCTIONS_DIR"
