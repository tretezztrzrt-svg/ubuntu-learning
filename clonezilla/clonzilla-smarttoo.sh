#!/bin/bash
# =================================================================
# CLONEZILLA SMART BACKUP & RECOVERY SCRIPT v3.4 (Partition Edition)
# =================================================================
DEFAULT_COMPRESSION="zstd"
DEFAULT_SPLIT_SIZE="4000"
DEFAULT_BACKUP_DIR="/home/partimag"
MIN_PASSWORD_LENGTH=8

# =================================================================
# ENFORCE ROOT RIGHTS
# =================================================================
if [ "$EUID" -ne 0 ]; then
    echo "❌ FEHLER: Dieses Skript muss als root (mit sudo) ausgeführt werden!"
    exit 1
fi

# =================================================================
# AUTOMATIC CLEANUP ON EXIT
# =================================================================
cleanup() {
    echo -e "\n🧹 Skript beendet. Räume auf..."
    if mountpoint -q "$DEFAULT_BACKUP_DIR"; then
        echo "🔓 Unmounte $DEFAULT_BACKUP_DIR..."
        umount "$DEFAULT_BACKUP_DIR" 2>/dev/null
    fi
}
trap cleanup EXIT SIGINT SIGTERM

# =================================================================
# HILFSFUNKTIONEN & FALLENABWEHR
# =================================================================
clear_screen() {
    clear
    echo -e " ============================================================ "
    echo -e "   CLONEZILLA SMART PARTITION BACKUP & RECOVERY TOOL v3.4 "
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
echo " 1) Partition sichern (saveparts)"
echo " 2) Partition wiederherstellen (restoreparts)"
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
SUGGESTED_NAME="parts-backup-$(date +%Y-%m-%d-%H%M)"
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
# STEP 3: Quelle oder Ziel-Partition wählen
# =================================================================
clear_screen
show_disks
echo ""

if [ "$MODE" = "backup" ]; then
    echo "📤 --- MODUS: PARTITION SICHERN ---"
    read -p "Quell-Partition eingeben (z.B. sda1 oder nvme0n1p2): " CHOSEN_PART
else
    echo "📥 --- MODUS: PARTITION WIEDERHERSTELLEN ---"
    read -p "ZIEL-Partition eingeben (WIRD KOMPLETT GELÖSCHT!) (z.B. sda1): " CHOSEN_PART
fi

CHOSEN_PART=$(echo "$CHOSEN_PART" | sed 's|^/dev/||')

if [ ! -b "/dev/$CHOSEN_PART" ]; then
    echo "❌ Fehler: /dev/$CHOSEN_PART existiert nicht!"
    exit 1
fi

# 🔥 PARTITION VS DISK CHECK (Hier umgedreht für den neuen Modus!)
DEV_TYPE=$(lsblk -nod TYPE "/dev/$CHOSEN_PART" 2>/dev/null)
if [ "$DEV_TYPE" != "part" ]; then
    echo "❌ FEHLER: /dev/$CHOSEN_PART ist keine Partition ($DEV_TYPE)."
    echo "   Dieses Skript ist im Partitions-Modus. Bitte gib eine Partition an (z.B. sda1 statt sda)!"
    exit 1
fi

if [ "$CHOSEN_PART" = "$BACKUP_PART" ]; then
    echo "❌ FATALER FEHLER: Du versuchst, die Backup-Partition selbst zu wählen!"
    exit 1
fi

if is_system_critical "$CHOSEN_PART"; then
    if [ "$MODE" = "restore" ]; then
        echo "❌ ABSOLUTES VERBOT: Die aktive Systempartition kann nicht im laufenden Betrieb überschrieben werden!"
        exit 1
    else
        echo "⚠️  WARNUNG: Diese Partition enthält aktive System-Mounts."
        read -p "Trotzdem fortfahren? (j/n): " LIVE_CONFIRM
        [[ "$LIVE_CONFIRM" =~ ^[Jj]$ ]] || { echo "❌ Abgebrochen"; exit 1; }
    fi
fi

if [ "$MODE" = "restore" ]; then
    echo -e "\n🔥 !!! WARNUNG !!! 🔥"
    echo "ALLE DATEN AUF /dev/$CHOSEN_PART WERDEN UNWIDERRUFLICH GELÖSCHT!"
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
echo -e " Modus:         \033[1;33m${MODE^^} PARTITION\033[0m"
echo -e " Speicher-Part: /dev/$BACKUP_PART (auf $DEFAULT_BACKUP_DIR)"
echo -e " Backup-Name:   $BACKUP_NAME"
if [ "$MODE" = "backup" ]; then
    echo -e " Quelle:        /dev/$CHOSEN_PART"
else
    echo -e " Ziel (Löschung): /dev/$CHOSEN_PART"
fi
echo "============================================================"
read -p "Drücke [ENTER] um Clonezilla endgültig zu starten..."

if [ "$MODE" = "backup" ]; then
    echo "$PASSWORD" | ocs-sr -q2 -j2 -z1p -i "$DEFAULT_SPLIT_SIZE" -sfsck -senc -p choose saveparts "$BACKUP_NAME" "$CHOSEN_PART"
else
    echo "$PASSWORD" | ocs-sr -g auto -e1 auto -e2 -c -r -j2 -senc -p choose restoreparts "$BACKUP_NAME" "$CHOSEN_PART"
fi
