#!/bin/bash
# =============================================================================
# treesize.sh - TreeSize Free für Ubuntu/Linux (pure Bash)
# =============================================================================
# 
# README:
# 
# Ein einfaches, aber mächtiges Bash-Script das wie TreeSize Free funktioniert:
# - Zeigt Verzeichnisbaum mit Größen
# - Sortiert nach Größe (absteigend)
# - Schöne Unicode-Tree-Darstellung + Farben + Fortschrittsbalken (Eye-Candy)
# - Rekursiv bis einstellbare Tiefe
# 
# Vorteile:
# - Keine zusätzlichen Programme nötig (nur coreutils = du, sort, awk, basename)
# - Schnell und übersichtlich
# - Funktionalität > Optik (genau wie du wolltest)
# 
# Nutzung:
#   ./treesize.sh [Verzeichnis] [max-tiefe]
# 
# Beispiele:
#   ./treesize.sh                    # Aktuelles Verzeichnis, Tiefe 3
#   ./treesize.sh /home/user 5       # Home-Ordner, bis Tiefe 5
#   ./treesize.sh / 2                # Root, nur oberste Ebene
# 
# Konfiguration (am Anfang des Scripts editierbar):
#   MAX_DEPTH, SHOW_BARS, BAR_WIDTH, Farben usw.
# 
# Tipps:
# - Für interaktive Nutzung (besser als TreeSize!): sudo apt install ncdu
# - Script ist absichtlich einfach gehalten, damit du es leicht anpassen kannst.
# 
# Autor: Grok (für dich optimiert)
# Version: 1.0
# =============================================================================

set -euo pipefail

# ====================== KONFIGURATION ======================
MAX_DEPTH=${2:-3}
TARGET_DIR="${1:-.}"
HUMAN_READABLE=true
SHOW_BARS=true
BAR_WIDTH=30
SORT_BY_SIZE=true

# Farben für Eye-Candy
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ====================== FUNKTIONEN ======================
human() {
    local bytes=$1
    if [ "$HUMAN_READABLE" = false ]; then
        echo "$bytes"
        return
    fi
    if [ "$bytes" -ge 1073741824 ]; then
        awk "BEGIN {printf \"%.1fG\", $bytes/1073741824}"
    elif [ "$bytes" -ge 1048576 ]; then
        awk "BEGIN {printf \"%.1fM\", $bytes/1048576}"
    elif [ "$bytes" -ge 1024 ]; then
        awk "BEGIN {printf \"%.1fK\", $bytes/1024}"
    else
        echo "${bytes}B"
    fi
}

progress_bar() {
    local percent=$1
    local filled=$(( (percent * BAR_WIDTH) / 100 ))
    local bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=filled; i<BAR_WIDTH; i++)); do bar+="░"; done
    echo -e "${YELLOW}[${bar}]${NC} ${percent}%"
}

print_tree() {
    local dir="$1"
    local prefix="$2"
    local depth=$3
    local total_size=0

    if [ "$depth" -gt "$MAX_DEPTH" ]; then
        return
    fi

    local items=()
    while IFS= read -r line; do
        items+=("$line")
    done < <(du -s --bytes "$dir"/* 2>/dev/null | sort -nr)

    local count=${#items[@]}
    local idx=0

    for item in "${items[@]}"; do
        idx=$((idx + 1))
        local size=$(echo "$item" | awk '{print $1}')
        local path=$(echo "$item" | awk '{for(i=2;i<=NF;i++) printf "%s ", $i; print ""}' | xargs)
        local name=$(basename "$path")
        local is_last=$([ "$idx" -eq "$count" ] && echo true || echo false)
        local connector=$([ "$is_last" = true ] && echo "└──" || echo "├──")
        local sub_prefix=$([ "$is_last" = true ] && echo "${prefix}    " || echo "${prefix}│   ")

        total_size=$((total_size + size))

        printf "${prefix}%s ${BLUE}%s${NC}  ${GREEN}%s${NC}  " "$connector" "$name" "$(human "$size")"

        if [ "$SHOW_BARS" = true ]; then
            local rough_pct=$(( (size * 100) / (total_size + 1) ))
            [ "$rough_pct" -gt 100 ] && rough_pct=100
            progress_bar "$rough_pct"
        else
            echo
        fi

        if [ -d "$path" ] && [ "$depth" -lt "$MAX_DEPTH" ]; then
            print_tree "$path" "$sub_prefix" $((depth + 1))
        fi
    done

    if [ "$depth" -eq 1 ]; then
        echo -e "\n${GREEN}Gesamtgröße dieses Levels: $(human "$total_size")${NC}"
    fi
}

# ====================== MAIN ======================
echo -e "${YELLOW}=== TreeSize Bash v1.0 - Scanne $TARGET_DIR (Tiefe $MAX_DEPTH) ===${NC}"
echo -e "${BLUE}Root: $(basename "$(realpath "$TARGET_DIR")")${NC}\n"

root_size=$(du -sb "$TARGET_DIR" 2>/dev/null | cut -f1)
echo -e "Root-Größe: ${GREEN}$(human "$root_size")${NC}\n"

print_tree "$TARGET_DIR" "" 1

echo -e "\n${YELLOW}Fertig! Teste es und sag mir, was verbessert werden soll.${NC}"
echo -e "   ncdu installieren für interaktive Version: ${GREEN}sudo apt install ncdu${NC}"