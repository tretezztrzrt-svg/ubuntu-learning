#!/bin/bash
# =================================================================
# CLONEZILLA SMART BACKUP & RECOVERY SCRIPT v3.2 (Streamlined)
# =================================================================
DEFAULT_COMPRESSION="zstd"
DEFAULT_SPLIT_SIZE="4000"
DEFAULT_BACKUP_DIR="/home/partimag"
MIN_PASSWORD_LENGTH=8

# =================================================================
# HILFSFUNKTIONEN & FALLENABWEHR
# =================================================================
clear_screen() {
    clear
    echo -e " ============================================================ "
    echo -e "       CLONEZILLA SMART BACKUP & RECOVERY TOOL v3.2 "
    echo -e " ============================================================ "
}

show_disks() {
    echo -e " --- Vorhandene Festplatten & Partitionen --- "
    lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT,MODEL 2>/dev/null || lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT
}

get_password() {
    local PW1="" local PW2=""
    while true; do
        read -s -p "🔑 Verschlüsselungs-Passwort eingeben: " PW1
        echo ""
        if [ ${#PW1} -lt $MIN_PASSWORD_LENGTH ]; then
            echo -e " ❌ Mindestens $MIN_PASSWORD_LENGTH Zeichen! "
            continue
        fi
        read -s -p "🔑 Passwort wiederholen: " PW2
        echo ""
        if [ "$PW1" != "$PW2" ]; then
            echo -e " ❌ Passwörter stimmen nicht überein! "
        else
            echo "$PW1"
            return 0
        fi
    done
}

find_removable_partition() {
    local DEV=$(lsblk -dn -o NAME,RM | awk '$2==1 {print $1; exit}')
    if [ -n "$DEV" ]; then
        if [[ "$DEV" =~ [0-9]$ ]]; then
            echo "${DEV}p1"
        else
            echo "${DEV}1"
        fi
    fi
}

find_internal() {
    lsblk -dn -o NAME,RM,SIZE,TYPE | awk '$2==0 && $4=="disk" {print $1, $3}' | sort -k2 -h | tail -1 | awk '{print $1}'
}

is_system_critical() {
    local TARGET_DEV="/dev/$1"
    local MOUNTS=$(lsblk -no MOUNTPOINT "$TARGET_DEV" 2>/dev/null)
    if echo "$MOUNTS" | grep -qE '^/($|boot|usr|var|etc)'; then
        return 0
    fi
    return 1
}

# =================================================================
# HAUPTMENÜ
# =================================================================
clear_screen
echo " 1) Backup erstellen (savedisk)"
echo " 2) Backup wiederherstellen (restoredisk)"
echo " 0) Beenden"
read -p "Wahl [0-2]: " MODE_CHOICE

case $MODE_CHOICE in
    0) exit 0 ;;
    1) MODE="backup" ;;
    2) MODE="restore" ;;
    *) echo "❌ Ungültige Wahl!"; exit 1 ;;
esac

# =================================================================
# STEP 1: Backup-Laufwerk (Ziel-Speicherort) mounten
# =================================================================
clear_screen
echo "--- Schritt 1: Backup-Speicherort wählen ---"
show_disks
echo ""

SUGGESTED_PART=$(find_removable_partition)
if [ -n "$SUGGESTED_PART" ]; then
    echo -e " 💡 Vorschlag (Wechselmedium erkannt): $SUGGESTED_PART"
    read -p "Backup-Partition [$SUGGESTED_PART]: " BACKUP_PART
    BACKUP_PART="${BACKUP_PART:-$SUGGESTED_PART}"
else
    read -p "Backup-Partition eingeben (z.B. sdb1 oder nvme1n1p1): " BACKUP_PART
fi

BACKUP_PART=$(echo "$BACKUP_PART" | sed 's|^/dev/||')

if [ ! -b "/dev/$BACKUP_PART" ]; then
    echo "❌ Fehler: /dev/$BACKUP_PART existiert nicht oder ist kein Blockgerät!"
    exit 1
fi

if [[ "$BACKUP_PART" =~ p[0-9]+$ ]]; then
    BACKUP_DISK_BASE=$(echo "$BACKUP_PART" | sed 's/p[0-9]*$//')
else
    BACKUP_DISK_BASE=$(echo "$BACKUP_PART" | sed 's/[0-9]*$//')
fi

mkdir -p "$DEFAULT_BACKUP_DIR" 2>/dev/null
if ! mountpoint -q "$DEFAULT_BACKUP_DIR"; then
    mount "/dev/$BACKUP_PART" "$DEFAULT_BACKUP_DIR" 2>/dev/null || {
        echo "❌ Mount fehlgeschlagen!"
        exit 1
    }
fi

echo "✅ Erfolgreich gemountet auf $DEFAULT_BACKUP_DIR"
FREE_SPACE=$(df -h "$DEFAULT_BACKUP_DIR" | tail -1 | awk '{print $4}')
echo "📊 Freier Speicherplatz auf Backup-Medium: $FREE_SPACE"
read -p "[ENTER] zum Fortfahren..."

# =================================================================
# STEP 2: Backup-Name vergeben
# =================================================================
clear_screen
echo "--- Schritt 2: Name des Backup-Ordners ---"
SUGGESTED_NAME="backup-$(date +%Y-%m-%d-%H%M)"
read -p "Backup-Name [$SUGGESTED_NAME]: " BACKUP_NAME
BACKUP_NAME="${BACKUP_NAME:-$SUGGESTED_NAME}"

BACKUP_NAME=$(echo "$BACKUP_NAME" | sed 's/[^a-zA-A0-9_-]/_/g')

if [ "$MODE" = "backup" ] && [ -d "$DEFAULT_BACKUP_DIR/$BACKUP_NAME" ]; then
    read -p "⚠️  Ordner existiert bereits! Überschreiben? (j/n): " OVERWRITE
    [[ "$OVERWRITE" =~ ^[Jj]$ ]] || { echo "❌ Abgebrochen"; exit 1; }
fi

if [ "$MODE" = "restore" ] && [ ! -d "$DEFAULT_BACKUP_DIR/$BACKUP_NAME" ]; then
    echo "❌ Fehler: Der Backup-Ordner '$BACKUP_NAME' existiert nicht!"
    exit 1
fi

# =================================================================
# STEP 3: Quelle oder Ziel-Festplatte wählen
# =================================================================
clear_screen
show_disks
echo ""

SUGGESTED_INTERNAL=$(find_internal)

if [ "$MODE" = "backup" ]; then
    echo "📤 --- MODUS: BACKUP ERSTELLEN ---"
    if [ -n "$SUGGESTED_INTERNAL" ]; then
        echo -e " 💡 Vorschlag (Größte interne Platte): $SUGGESTED_INTERNAL"
        read -p "Quell-Festplatte (gesamte Disk) [$SUGGESTED_INTERNAL]: " CHOSEN_DISK
        CHOSEN_DISK="${CHOSEN_DISK:-$SUGGESTED_INTERNAL}"
    else
        read -p "Quell-Festplatte eingeben: " CHOSEN_DISK
    fi
else
    echo "📥 --- MODUS: WIEDERHERSTELLUNG ---"
    if [ -n "$SUGGESTED_INTERNAL" ]; then
        echo -e " 💡 Vorschlag (Ziel-Platte): $SUGGESTED_INTERNAL"
        read -p "ZIEL-Festplatte (WIRD KOMPLETT GELÖSCHT!) [$SUGGESTED_INTERNAL]: " CHOSEN_DISK
        CHOSEN_DISK="${CHOSEN_DISK:-$SUGGESTED_INTERNAL}"
    else
        read -p "ZIEL-Festplatte eingeben: " CHOSEN_DISK
    fi
fi

CHOSEN_DISK=$(echo "$CHOSEN_DISK" | sed 's|^/dev/||')

if [ ! -b "/dev/$CHOSEN_DISK" ]; then
    echo "❌ Fehler: /dev/$CHOSEN_DISK existiert nicht!"
    exit 1
fi

if [ "$CHOSEN_DISK" = "$BACKUP_DISK_BASE" ]; then
    echo "❌ FATALER FEHLER: Du versucht, die Backup-Platte selbst zu wählen!"
    exit 1
fi

if is_system_critical "$CHOSEN_DISK"; then
    if [ "$MODE" = "restore" ]; then
        echo "❌ ABSOLUTES VERBOT: Das aktive System kann nicht überschrieben werden!"
        exit 1
    else
        echo "⚠️  WARNUNG: Quellplatte enthält aktive System-Mounts."
        read -p "Trotzdem fortfahren? (j/n): " LIVE_CONFIRM
        [[ "$LIVE_CONFIRM" =~ ^[Jj]$ ]] || { echo "❌ Abgebrochen"; exit 1; }
    fi
fi

if [ "$MODE" = "restore" ]; then
    echo -e "\n🔥 !!! WARNUNG !!! 🔥"
    echo "ALLE DATEN AUF /dev/$CHOSEN_DISK WERDEN UNWIDERRUFLICH GELÖSCHT!"
    read -p "Sicher? Tippe 'JA-ICH-WILL' zum Bestätigen: " FINAL_CONFIRM
    if [ "$FINAL_CONFIRM" != "JA-ICH-WILL" ]; then
        echo "❌ Abgebrochen."
        exit 1
    fi
fi

# =================================================================
# STEP 4: Passwort abfragen (Verschlüsselung)
# =================================================================
clear_screen
echo "--- Schritt 4: Verschlüsselung ---"
PASSWORD=$(get_password)

# =================================================================
# STEP 5: Zusammenfassung & Clonezilla Start
# =================================================================
clear_screen
echo "============================================================"
echo "                   ZUSAMMENFASSUNG                          "
echo "============================================================"
echo -e " Modus:         \033[1;33m${MODE^^}\033[0m"
echo -e " Speicher-Part: /dev/$BACKUP_PART (auf $DEFAULT_BACKUP_DIR)"
echo -e " Backup-Name:   $BACKUP_NAME"
if [ "$MODE" = "backup" ]; then
    echo -e " Quelle:        /dev/$CHOSEN_DISK"
else
    echo -e " Ziel (Löschung): /dev/$CHOSEN_DISK"
fi
echo "============================================================"
read -p "Drücke [ENTER] um Clonezilla endgültig zu starten..."

if [ "$MODE" = "backup" ]; then
    echo "$PASSWORD" | ocs-sr -q2 -j2 -z1p -i "$DEFAULT_SPLIT_SIZE" -sfsck -senc -p choose savedisk "$BACKUP_NAME" "$CHOSEN_DISK"
else
    echo "$PASSWORD" | ocs-sr -g auto -e1 auto -e2 -c -r -j2 -senc -p choose restoredisk "$BACKUP_NAME" "$CHOSEN_DISK"
fi
