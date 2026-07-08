#!/usr/bin/env bash
#
# treesize.sh – TreeSize‑artige Speicherplatzübersicht für Bash (Ubuntu)
# ----------------------------------------------------------------------
# Dieses Skript zeigt eine farbige Baumstruktur aller Ordner/Dateien
# mit Größenangaben, ähnlich wie TreeSize Free unter Windows.
#
# Aufruf: ./treesize.sh [-d TIEFE] [-s] [VERZEICHNIS]
#
# Ausführliche Dokumentation siehe `-h` oder `--help`.

set -o pipefail
shopt -s extglob

# ----- Farben (ANSI) -----
readonly RED='\033[0;31m'
readonly YELLOW='\033[0;33m'
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# ----- Standardwerte -----
MAX_DEPTH=9999
SORT_LEVELS=false
TARGET_DIR="${PWD}"

# ----- Umfassende Hilfe (READMEM) -----
usage() {
    cat <<EOF
${BOLD}${BLUE}═══════════════════════════════════════════════════════════════════${NC}
${BOLD}treesize.sh – Baumstruktur mit Speicherplatzbelegung${NC}
${BLUE}═══════════════════════════════════════════════════════════════════${NC}

${BOLD}BESCHREIBUNG${NC}
    treesize.sh durchsucht ein Verzeichnis rekursiv und zeigt eine
    farbige Baumstruktur aller enthaltenen Dateien und Ordner mit
    ihren Größen an. Die Darstellung ähnelt dem Tool "TreeSize Free"
    unter Windows – nur mit reinen Bash‑Bordmitteln (du, find, numfmt).

${BOLD}SYNTAX${NC}
    $0 [-d TIEFE] [-s] [VERZEICHNIS]

${BOLD}OPTIONEN${NC}
    -d TIEFE   Maximale Rekursionstiefe (Standard: unbegrenzt)
    -s         Sortiere die Einträge auf jeder Ebene absteigend nach Größe
               (größte zuerst) – standardmäßig unsortiert (wie bei TreeSize)
    -h, --help Zeigt diese ausführliche Hilfe an und beendet das Programm

${BOLD}ARGUMENTE${NC}
    VERZEICHNIS   Das zu durchsuchende Verzeichnis. Wird keins angegeben,
                  wird das aktuelle Verzeichnis verwendet.

${BOLD}BEISPIELE${NC}
    $0 /home/benutzer/Dokumente
        Zeigt den gesamten Baum unter Dokumente, ohne Sortierung.

    $0 -d 2 -s /var/log
        Zeigt nur zwei Ebenen tief, sortiert nach Größe (größte zuerst).

    $0 -s
        Durchsucht das aktuelle Verzeichnis und sortiert.

${BOLD}FARBEN (Augenschmaus)${NC}
    🔴 Rot    → Datei/Ordner größer als 1 GiB
    🟡 Gelb   → Datei/Ordner größer als 100 MiB
    🟢 Grün   → Datei/Ordner kleiner oder gleich 100 MiB

    Die Farben helfen, große Speicherfresser sofort zu erkennen.

${BOLD}AUSGABE${NC}
    Jede Zeile zeigt: [Größe] [Name]
    Die Einrückung entspricht der Tiefe im Baum.
    Am Anfang wird eine Zusammenfassung mit Gesamtgröße angezeigt.
    Während des Scans erscheint ein Spinner als Fortschrittsanzeige.

${BOLD}ABHÄNGIGKEITEN${NC}
    - Bash 4.0+
    - coreutils (für du, numfmt, sort, printf, …)
    - find (wird für die Auflistung verwendet)

    Alle genannten Tools sind auf einem Standard‑Ubuntu‑System vorhanden.

${BOLD}HINWEISE${NC}
    • Das Skript zeigt standardmäßig ALLE Einträge (Dateien + Ordner).
      Um NUR Ordner anzuzeigen, kann die Funktion scan_dir angepasst werden
      (z.B. mit find -type d).
    • Bei sehr großen Verzeichnissen kann der Scan einige Sekunden dauern.
      Die Sortierung (-s) erhöht die Laufzeit, da intern sortiert wird.
    • Die Größen werden mit numfmt in IEC‑Einheiten (KiB, MiB, GiB) umgerechnet.

${BOLD}FEHLERBEHANDLUNG${NC}
    Falls du oder numfmt nicht verfügbar sind, bricht das Skript mit einer
    Fehlermeldung ab. Auch wenn das Zielverzeichnis nicht existiert.

${BLUE}═══════════════════════════════════════════════════════════════════${NC}
EOF
    exit 0
}

# ----- Optionen parsen -----
while getopts "d:sh-:" opt; do
    case "$opt" in
        d) MAX_DEPTH="$OPTARG" ;;
        s) SORT_LEVELS=true ;;
        h) usage ;;
        -) case "${OPTARG}" in
               help) usage ;;
               *) echo "Unbekannte Option --${OPTARG}" >&2; usage ;;
           esac ;;
        *) usage ;;
    esac
done
shift $((OPTIND-1))
[ -n "$1" ] && TARGET_DIR="$1"

# ----- Prüfungen -----
if ! command -v du &>/dev/null; then
    echo -e "${RED}Fehler: 'du' nicht gefunden.${NC}" >&2
    exit 1
fi
if ! command -v numfmt &>/dev/null; then
    echo -e "${RED}Fehler: 'numfmt' nicht gefunden (coreutils installieren).${NC}" >&2
    exit 1
fi
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${RED}Fehler: '$TARGET_DIR' ist kein Verzeichnis.${NC}" >&2
    exit 1
fi

# ----- Spinner (Augenschmaus) -----
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while ps -p "$pid" >/dev/null 2>&1; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "      \b\b\b\b\b\b"
}

# ----- Scannen: alle Einträge mit Größe (in Bytes) -----
scan_dir() {
    local dir="$1"
    du -sb0 "$dir"/* 2>/dev/null | while IFS= read -r -d '' line; do
        size="${line%%$'\t'*}"
        path="${line#*$'\t'}"
        printf "%s\t%s\n" "$size" "$path"
    done
}

# ----- Rekursive Baumausgabe -----
print_tree() {
    local dir="$1"
    local depth="$2"
    local indent="$3"

    [ "$depth" -ge "$MAX_DEPTH" ] && return

    local items=()
    while IFS=$'\t' read -r size path; do
        items+=("$size" "$path")
    done < <(scan_dir "$dir")
    [ ${#items[@]} -eq 0 ] && return

    if $SORT_LEVELS; then
        local sorted=()
        for ((i=0; i<${#items[@]}; i+=2)); do
            printf "%020d\t%s\n" "${items[i]}" "${items[i+1]}"
        done | sort -nr | while IFS=$'\t' read -r size path; do
            size=$((10#$size))
            sorted+=("$size" "$path")
        done
        items=("${sorted[@]}")
    fi

    for ((i=0; i<${#items[@]}; i+=2)); do
        local size="${items[i]}"
        local path="${items[i+1]}"
        local name="${path##*/}"

        local colour="$GREEN"
        [ "$size" -gt 1073741824 ] && colour="$RED"
        [ "$size" -gt 104857600 ] && [ "$size" -le 1073741824 ] && colour="$YELLOW"

        local hr_size
        hr_size=$(numfmt --to=iec --suffix=B "$size" 2>/dev/null || echo "$size")

        printf "%s${colour}%s${NC}  %s\n" "$indent" "$hr_size" "$name"

        if [ -d "$path" ]; then
            print_tree "$path" $((depth+1)) "${indent}  "
        fi
    done
}

# ----- Hauptprogramm -----
echo -e "${BOLD}${BLUE}TreeSize für Bash${NC}"
echo "Durchsuche: $TARGET_DIR"
echo "Tiefenlimit: $MAX_DEPTH"
echo "Sortierung:  $([ "$SORT_LEVELS" ] && echo "ein" || echo "aus")"
echo "----------------------------------------"

(
    total_size=$(du -sb "$TARGET_DIR" 2>/dev/null | cut -f1)
    echo "$total_size" > /tmp/treesize_total.$$
) &
spinner $!

total_size=$(cat /tmp/treesize_total.$$ 2>/dev/null || echo 0)
rm -f /tmp/treesize_total.$$ 2>/dev/null

hr_total=$(numfmt --to=iec --suffix=B "$total_size" 2>/dev/null || echo "$total_size")
echo -e "${BOLD}Gesamtgröße: ${CYAN}${hr_total}${NC}"

print_tree "$TARGET_DIR" 0 ""

echo "----------------------------------------"
echo -e "${BOLD}${BLUE}Fertig.${NC}"