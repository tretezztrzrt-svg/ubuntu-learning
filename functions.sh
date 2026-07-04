# nautilius kontext-menü --> könnt functions ersetzen
#cat > ~/.local/share/nautilus/scripts/echo-selection.sh <<'EOF'
##!/usr/bin/env bash
#echo "Auswahl:"
#echo "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS"
#EOF
#chmod +x ~/.local/share/nautilus/scripts/echo-selection.sh
#sudo apt update
#sudo apt install nautilus-extension-gnome-terminal
#nautilus -q
# Durchsucht Dateien rekursiv nach einem Suchbegriff
# Nutzung: search "suchbegriff"
#function search() {
#    if [ -z "$1" ]; then
#        echo "Verwendung: search <suchbegriff>"
#        return 1
#    fi
#} 
# buggy? nochmals

# --- Functions ----------------------------------------------------------------
# Erstellt einen Ordner und wechselt sofort hinein
function make-dir) {
  if [ -z "$1" ]; then
    echo "Verwendung: mkdircd <ordnername>"
    return 1
  fi
  mkdir -p -- "$1" && cd -- "$1" && pwd
}

# Öffnet Ordner $1, dann pwd und ls -la
function hello() {
  if [ -z "$1" ]; then
    echo "Verwendung: hello <ordnername>"
    return 1
  fi
  cd -- "$1" || return
  pwd
  ls -la
}

# Geht einen Ordner zurück, dann pwd und ls -la
function back() {
  cd .. || return
  pwd
  ls -la
}
# aus backup-4-cron.sh
function backup() {
  # backup <datei|ordner-pfad>  (legt Backup unter ~/backup an)
  local target backup_dir log_file target_name timestamp date_day backup_name
  backup_dir="$HOME/backup"

  # Argument prüfen
  if [[ $# -ne 1 ]]; then
    echo "Fehler: Bitte gib eine Datei oder ein Verzeichnis an!" >&2
    echo "Nutzung: backup <pfad/zur/datei_oder_ordner>" >&2
    return 1
  fi

  target="$1"
  if [[ ! -e "$target" ]]; then
    echo "Fehler: '$target' existiert nicht oder ist ungültig!" >&2
    return 2
  fi

  # Zielordner anlegen
  mkdir -p -- "$backup_dir" "$backup_dir/dir" "$backup_dir/file"

  target_name="$(basename -- "$target")"
  timestamp="$(date +"%Y-%m-%d_%H-%M-%S")"
  date_day="$(date +"%Y-%m-%d")"
  backup_name="${timestamp}_${target_name}"

  # Logfile: immer im backup_dir, mit Kennung "_func_"
  log_file="${backup_dir}/${date_day}_func_.log"

  {
    echo "=== Backup-Start: $(date) ==="
    echo "Zielobjekt: $target"
    echo "Backup-Name: $backup_name"

    if [[ -d "$target" ]]; then
      echo "Typ: Verzeichnis"
      tar -czf "${backup_dir}/dir/${backup_name}.tar.gz" \
        -C "$(dirname -- "$target")" "$target_name"
      echo "Erfolgreich als ${backup_name}.tar.gz gesichert."
    else
      echo "Typ: Datei"
      cp -- "$target" "${backup_dir}/file/${backup_name}"
      echo "Erfolgreich als ${backup_name} gesichert."
    fi

    echo "=== Backup-Ende: $(date) ==="
    echo
  } >> "$log_file" 2>&1
}

# --- Universal entpacken/packen/packenhard ------------------------------------------
# alias packen-tarfix='tar -czvf' # Komprimiert einen Ordner zu .tar.gz , vorherige kurzversion
# alias packen-untar='tar -zxvf' # Entpackt eine .tar.gz Datei , vorherige kurzversion
# sudo apt install p7zip-full

function entpack() {
    if [ $# -ne 1 ]; then
        echo "Error: No file specified."
        return 1
    fi

    local archiv="$1"
    if [ ! -f "$archiv" ]; then
        echo "'$archiv' is not a valid file"
        return 1
    fi

    case "$archiv" in
        *.7z|*.7Z)
            7z x -y "$archiv"

            ;;
        *)
            echo "'$archiv' ist kein .7z Archiv"
            return 1
            ;;
    esac
}

function pack() {
    if [ $# -lt 2 ]; then
        echo "Verwendung: packen <datei_oder_ordner> [zielname]"
        return 1
    fi

    local quelle="$1"
    local ziel="${2:-$(basename "$quelle").7z}"

    # wenn kein .7z am Ende, dann ergänzen
    case "$ziel" in
        *.7z) ;; 
        *) ziel="${ziel}.7z" ;;
    esac
    if [ ! -e "$quelle" ]; then
        echo "Fehler: Quelle existiert nicht: $quelle"
        return 1
    fi
    if [ -e "$ziel" ]; then
        echo "Fehler: $ziel existiert bereits!"
        return 1
    fi

    7z a -t7z "$ziel" "$quelle"
    # 7z a -t7z -mx=9 "$ziel" "$quelle"
    # 7z a "$ziel" "$quelle" - war der vorherige vorschlag
} # hat geklappt

function pack-harder() {
    if [ $# -lt 2 ]; then
        echo "Verwendung: packen <datei_oder_ordner> [zielname]"
        return 1
    fi

    local quelle="$1"
    local ziel="${2:-$(basename "$quelle").7z}"

    # wenn kein .7z am Ende, dann ergänzen
    case "$ziel" in
        *.7z) ;; 
        *) ziel="${ziel}.7z" ;;
    esac
    if [ ! -e "$quelle" ]; then
        echo "Fehler: Quelle existiert nicht: $quelle"
        return 1
    fi
    if [ -e "$ziel" ]; then
        echo "Fehler: $ziel existiert bereits!"
        return 1
    fi

    7z a -t7z -mx=9 "$ziel" "$quelle"
}

