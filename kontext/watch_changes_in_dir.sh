#!/usr/bin/env bash
#
# recent-files.sh – Listet alle Dateien im ausgewählten Ordner (inkl. Unterordner)
#                    die in den letzten 60 Minuten geändert wurden.
# Für Nautilus: Ordner auswählen → Rechtsklick → Skripte → recent-files
#

set -euo pipefail

# ---------- Parameter ----------
if [ -n "${NAUTILUS_SCRIPT_SELECTED_FILE_PATHS:-}" ]; then
    TARGET=$(echo "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" | head -n1 | tr -d '\n')
else
    TARGET="${1:-.}"
fi

# ---------- Prüfungen ----------
if [ ! -d "$TARGET" ]; then
    if command -v notify-send &>/dev/null; then
        notify-send "❌ Fehler" "'$TARGET' ist kein Verzeichnis"
    fi
    echo "Fehler: '$TARGET' ist kein Verzeichnis" >&2
    exit 1
fi

# ---------- Dateien finden (letzte 60 Minuten) ----------
# -mmin -60 : Änderungszeitpunkt vor weniger als 60 Minuten
# -type f    : nur Dateien
# -printf    : Pfad (relativ zum Start), Größe in Bytes, Änderungszeit (lesbar)
FILES=$(find "$TARGET" -type f -mmin -60 -printf "%P  %s  %t\n" 2>/dev/null | sort -k3r)

if [ -z "$FILES" ]; then
    msg="Keine Dateien in den letzten 60 Minuten geändert."
    if command -v notify-send &>/dev/null; then
        notify-send "📁 recent-files" "$msg"
    fi
    # Trotzdem anzeigen (GUI oder Terminal)
    if command -v yad &>/dev/null || command -v zenity &>/dev/null; then
        echo "$msg" | show_gui "Keine aktuellen Dateien"
    else
        echo "$msg"
    fi
    exit 0
fi

# ---------- Ausgabe formatieren ----------
# Spalten: Pfad (max. 60 Zeichen), Größe (menschenlesbar), Datum+Uhrzeit
# Wir verwenden awk, um Größe umzurechnen und Datum zu kürzen.
FORMATTED=$(echo "$FILES" | awk '
function human(n) {
    if (n < 1024) return n " B";
    if (n < 1048576) return sprintf("%.1f KB", n/1024);
    if (n < 1073741824) return sprintf("%.1f MB", n/1048576);
    return sprintf("%.1f GB", n/1073741824);
}
{
    path = $1;
    size = $2;
    # Datum: $3..$5 (Monat, Tag, Uhrzeit) oder je nach Locale
    # Wir nehmen einfach den gesamten Rest als Datum
    # Da -printf "%t" das Datum im Format "Mon Tag HH:MM" liefert (z.B. "Jul 22 08:30")
    date_str = $3 " " $4 " " $5;
    # Größe umrechnen
    size_h = human(size);
    # Pfad kürzen
    if (length(path) > 60) path = substr(path, 1, 57) "...";
    printf "%-60s  %10s  %s\n", path, size_h, date_str;
}')

# ---------- GUI-Funktion ----------
show_gui() {
    local content="$1"
    local title="📁 Kürzlich geändert – $(basename "$TARGET")"
    if command -v yad &>/dev/null; then
        echo -e "$content" | yad --text-info --title="$title" \
            --width=900 --height=600 --fontname="Monospace 10" \
            --button="Schließen":0 --window-icon="folder"
    elif command -v zenity &>/dev/null; then
        echo -e "$content" | zenity --text-info --title="$title" \
            --width=900 --height=600 --font="Monospace 10" \
            --ok-label="Schließen"
    else
        # Fallback: Terminal
        echo "$content"
    fi
}

# ---------- Kopfzeile ----------
HEADER="Dateien in '$TARGET' (geändert in den letzten 60 Minuten)
========================================
(Zeitpunkt: $(date '+%Y-%m-%d %H:%M:%S'))

Pfad                                                       Größe       Datum/Uhrzeit
----                                                       -----       -------------
"

OUTPUT="${HEADER}${FORMATTED}"

# ---------- Ausgabe ----------
# Wenn Nautilus-Kontext -> immer GUI (falls vorhanden)
if [ -n "${NAUTILUS_SCRIPT_SELECTED_FILE_PATHS:-}" ]; then
    show_gui "$OUTPUT"
else
    # Terminal-Modus (wenn nicht von Nautilus)
    echo "$OUTPUT"
fi