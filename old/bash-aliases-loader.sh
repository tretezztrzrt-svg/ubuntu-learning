#!/bin/bash
# =============================================================================
# Bash Aliases Loader
# Lädt alle Alias-Kategorien
# =============================================================================
#
# Verwende diese Datei in deiner ~/.bashrc mit:
#   source ~/.bash/bash-aliases-loader.sh
#
# ODER lade einzelne Kategorien direkt:
#   source ~/.bash/bash-aliases-navigation.sh
#   source ~/.bash/bash-aliases-system.sh
#   etc.
#
# =============================================================================

BASH_ALIASES_DIR="${HOME}/.bash"

# Array der Alias-Module
declare -a alias_modules=(
    "bash-aliases-navigation.sh"
    "bash-aliases-system.sh"
    "bash-aliases-disk.sh"
    "bash-aliases-processes.sh"
    "bash-aliases-files.sh"
    "bash-aliases-search.sh"
    "bash-aliases-packages.sh"
    "bash-aliases-permissions.sh"
    "bash-aliases-shortcuts.sh"
    "bash-aliases-misc.sh"
)

# Lade alle Module
for module in "${alias_modules[@]}"; do
    if [ -f "$BASH_ALIASES_DIR/$module" ]; then
        source "$BASH_ALIASES_DIR/$module"
    else
        echo "⚠️ Warning: $module not found in $BASH_ALIASES_DIR"
    fi
done

echo "✅ Bash aliases loaded from: $BASH_ALIASES_DIR"
