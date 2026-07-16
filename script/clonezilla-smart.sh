#!/bin/bash
# =================================================================
# CLONEZILLA SMART BACKUP & RECOVERY SCRIPT
# =================================================================
# Dieses Skript führt dich sicher durch Backup und Wiederherstellung.
# Es fragt alles ab, was wichtig ist, und warnt vor häufigen Fehlern.
# ================================================================
# KONFIGURATION (Hier kannst du Standardwerte anpassen)
# =================================================================
DEFAULT_COMPRESSION="zstd"    # zstd, gzip, lzma, oder none (zstd ist schnell & gut)
DEFAULT_SPLIT_SIZE="4000"     # Max. Dateigröße in MB (für FAT32-kompatible Backups)
DEFAULT_BACKUP_DIR="/home/partimag"  # Standard-Clonezilla-Image-Verzeichnis
MIN_PASSWORD_LENGTH=8         # Mindestlänge für das Passwort
# =================================================================
# HILFSFUNKTIONEN
# =================================================================
# Bildschirm leeren und Kopfzeile anzeigen
clear_screen() {
    clear
    echo -e " ============================================================ "
    echo -e "       CLONEZILLA SMART BACKUP & RECOVERY TOOL "
    echo -e " ============================================================ "
}
# Auf Tastendruck warten
press_any_key() {
    echo -e " Drücke [ENTER] um fortzufahren... "
    read -r
}
# Festplatten übersichtlich anzeigen
show_disks() {
    echo -e " --- Vorhandene Festplatten --- "
    lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT,MODEL 2>/dev/null || lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT
    echo -e " Hinweis:  sda, sdb, nvme0n1, etc. sind die Gerätenamen."
    echo -e "         Partitionen wie sda1, sda2 sind NICHT die ganze Platte!"
}
# Sichere Passwortabfrage
get_password() {
    local PW1=""
    local PW2=""
    while true; do
        echo -e " Verschlüsselungspasswort: "
        echo -e " Hinweis: Mindestens $MIN_PASSWORD_LENGTH Zeichen, kein Leerzeichen. "
        read -s -p "Passwort eingeben: " PW1
        read -s -p "Passwort wiederholen: " PW2
        if [ ${#PW1} -lt $MIN_PASSWORD_LENGTH ]; then
            echo -e " Fehler: Passwort muss mindestens $MIN_PASSWORD_LENGTH Zeichen lang sein! "
        elif [ "$PW1" != "$PW2" ]; then
            echo -e " Fehler: Passwörter stimmen nicht überein! "
        else
            echo "$PW1"
            return 0
        fi
    done
}
# Prüfen, ob eine Festplatte gemountet ist und ggf. aushängen
check_and_unmount() {
    local DEVICE="$1"
    local MOUNTS=$(mount | grep "^$DEVICE" | awk '{print $3}')
    if [ -n "$MOUNTS" ]; then
        echo -e " Warnung: $DEVICE ist noch gemountet auf: "
        echo "$MOUNTS"
        echo -e " Ein gemountetes Laufwerk kann nicht für die Wiederherstellung verwendet werden! "
        read -p "Soll ich die Mounts automatisch aushängen? (j/n): " UNMOUNT_ANSWER
        if [[ "$UNMOUNT_ANSWER" =~ ^[Jj]$ ]]; then
            for M in $MOUNTS; do
                echo "Hänge $M aus..."
                umount "$M" 2>/dev/null || echo -e " Konnte $M nicht aushängen! "
            done
            sleep 2
        else
            echo -e " Abbruch. Bitte hänge die Partitionen manuell aus. "
            exit 1
        fi
    fi
}
# Zielplatte auswählen mit Sicherheitsabfrage
select_target_disk() {
    local PROMPT="$1"
    local EXCLUDE="$2"
    local DISK=""
    while true; do
        echo -e "$PROMPT"
        echo -e " Gib den Gerätenamen ein (z.B. sda, sdb, nvme0n1):  "
        read -r DISK
        DISK=$(echo "$DISK" | sed 's|^/dev/||')  # /dev/ entfernen falls vorhanden
        # Prüfen ob Gerät existiert
        if [ ! -b "/dev/$DISK" ]; then
            echo -e " Fehler: /dev/$DISK existiert nicht! "
            continue
        fi
        # Prüfen ob es die ausgeschlossene Platte ist (z.B. die Backup-Platte)
        if [ -n "$EXCLUDE" ] && [ "$DISK" = "$EXCLUDE" ]; then
            echo -e " Fehler: Das ist die Backup-Platte ($EXCLUDE)! Bitte wähle eine andere. "
            continue
        fi
        # Zusätzliche Sicherheitsabfrage für die Wiederherstellung
        if [[ "$MODE" == "restore" ]]; then
            echo -e " ⚠️  ACHTUNG: /dev/$DISK wird KOMPLETT überschrieben! "
            echo -e "     Alle Daten auf dieser Platte gehen verloren! "
            read -p "Bist du dir SICHER, dass du /dev/$DISK überschreiben willst? (j/n): " CONFIRM
            if [[ ! "$CONFIRM" =~ ^[Jj]$ ]]; then
                echo -e " Abgebrochen. Wähle eine andere Platte. "
                continue
            fi
        fi
        echo "$DISK"
        return 0
    done
}
# =================================================================
# HAUPTMENÜ
# =================================================================
clear_screen
echo -e " Wähle den Modus: "
echo "  1) Backup erstellen (Quelle sichern)"
echo "  2) Backup wiederherstellen (Recovery)"
echo "  3) Nur Festplatten anzeigen"
echo "  0) Beenden"
read -p "Deine Wahl [0-3]: " MODE_CHOICE
case $MODE_CHOICE in
    0)
        echo "Auf Wiedersehen!"
        exit 0
        ;;
    3)
        clear_screen
        show_disks
        press_any_key
        exit 0
        ;;
    1)
        MODE="backup"
        ;;
    2)
        MODE="restore"
        ;;
    *)
        echo -e " Ungültige Auswahl! "
        exit 1
        ;;
esac
# =================================================================
# STEP 1: Backup-Laufwerk finden und mounten
# =================================================================
clear_screen
echo -e " --- Schritt 1: Backup-Laufwerk mounten --- "
show_disks
echo -e " Wähle das Laufwerk, auf dem das Backup gespeichert wird: "
echo -e "   (Das ist deine EXTERNE Festplatte oder USB-Stick)"
echo -e " Beispiel:  Wenn deine externe Platte sdb1 ist, gib 'sdb1' ein"
read -p "Backup-Partition (z.B. sdb1): " BACKUP_PART
BACKUP_PART=$(echo "$BACKUP_PART" | sed 's|^/dev/||')
if [ ! -b "/dev/$BACKUP_PART" ]; then
    echo -e " Fehler: /dev/$BACKUP_PART existiert nicht! "
    exit 1
fi
# Mount-Verzeichnis erstellen
mkdir -p "$DEFAULT_BACKUP_DIR" 2>/dev/null
# Prüfen ob schon gemountet
if mount | grep -q "$DEFAULT_BACKUP_DIR"; then
    echo -e " Warnung: $DEFAULT_BACKUP_DIR ist bereits gemountet. "
    read -p "Soll ich es neu mounten? (j/n): " REMOUNT
    if [[ "$REMOUNT" =~ ^[Jj]$ ]]; then
        umount "$DEFAULT_BACKUP_DIR" 2>/dev/null
        mount "/dev/$BACKUP_PART" "$DEFAULT_BACKUP_DIR" || {
            echo -e " Fehler beim Mounten von /dev/$BACKUP_PART auf $DEFAULT_BACKUP_DIR "
            exit 1
        }
    fi
else
    mount "/dev/$BACKUP_PART" "$DEFAULT_BACKUP_DIR" || {
        echo -e " Fehler beim Mounten von /dev/$BACKUP_PART auf $DEFAULT_BACKUP_DIR "
        exit 1
    }
fi
echo -e " ✅ Backup-Laufwerk erfolgreich gemountet auf $DEFAULT_BACKUP_DIR "
# Freien Speicherplatz anzeigen
FREE_SPACE=$(df -h "$DEFAULT_BACKUP_DIR" | tail -1 | awk '{print $4}')
echo -e " Freier Speicherplatz: $FREE_SPACE "
press_any_key
# =================================================================
# STEP 2: Backup-Name festlegen
# =================================================================
clear_screen
echo -e " --- Schritt 2: Backup-Name --- "
echo -e " Gib einen eindeutigen Namen für dein Backup ein. "
echo -e "   (Der Ordner wird unter $DEFAULT_BACKUP_DIR erstellt)"
echo -e "    Vorschlag: backup-$(date +%Y-%m-%d) "
read -p "Backup-Name: " BACKUP_NAME
# Leeren Namen verhindern
while [ -z "$BACKUP_NAME" ]; do
    echo -e " Der Name darf nicht leer sein! "
    read -p "Backup-Name: " BACKUP_NAME
done
# Prüfen ob Backup schon existiert
if [ -d "$DEFAULT_BACKUP_DIR/$BACKUP_NAME" ]; then
    echo -e " Warnung: Ein Backup mit diesem Namen existiert bereits! "
    read -p "Soll ich es überschreiben? (j/n): " OVERWRITE
    if [[ ! "$OVERWRITE" =~ ^[Jj]$ ]]; then
        echo "Bitte wähle einen anderen Namen."
        exit 1
    fi
fi
# =================================================================
# STEP 3: Quelle oder Ziel auswählen (je nach Modus)
# =================================================================
clear_screen
echo -e " --- Schritt 3: Festplatte auswählen --- "
show_disks
if [ "$MODE" = "backup" ]; then
    echo -e " --- Backup-Modus --- "
    echo -e "Wähle die QUELL-Festplatte (die, die gesichert werden soll):"
    echo -e " Hinweis: Das ist deine INTERNE Laptop-Festplatte. "
    echo -e " ⚠️  Wähle NICHT die Backup-Platte ($BACKUP_PART)! "
    SOURCE_DISK=$(select_target_disk "Quell-Festplatte wählen:" "$(echo "$BACKUP_PART" | sed 's/[0-9]*$//')")
    TARGET_DISK=""  # Wird beim Backup nicht benötigt
else
    echo -e " --- Wiederherstellungs-Modus --- "
    echo -e "Wähle die ZIEL-Festplatte (die, die überschrieben werden soll):"
    echo -e " Hinweis: Das ist deine INTERNE Laptop-Festplatte. "
    echo -e " ⚠️  ALLE DATEN auf dieser Platte werden gelöscht! "
    echo -e " ⚠️  Wähle NICHT die Backup-Platte ($BACKUP_PART)! "
    TARGET_DISK=$(select_target_disk "Ziel-Festplatte wählen:" "$(echo "$BACKUP_PART" | sed 's/[0-9]*$//')")
    SOURCE_DISK=""  # Wird beim Restore nicht benötigt
fi
# =================================================================
# STEP 4: Passwort festlegen
# =================================================================
clear_screen
echo -e " --- Schritt 4: Verschlüsselungspasswort --- "
PASSWORD=$(get_password)
# =================================================================
# STEP 5: Erweiterte Optionen (für Profis)
# =================================================================
clear_screen
echo -e " --- Schritt 5: Erweiterte Optionen (optional) --- "
echo -e " Möchtest du erweiterte Optionen einstellen? "
echo -e "   (Für die meisten Anwender reichen die Standardwerte)"
echo -e "    Empfohlen:  Nein (einfach ENTER drücken)"
read -p "Erweiterte Optionen? (j/n) [n]: " ADVANCED
COMPRESSION="$DEFAULT_COMPRESSION"
SPLIT_SIZE="$DEFAULT_SPLIT_SIZE"
if [[ "$ADVANCED" =~ ^[Jj]$ ]]; then
    clear_screen
    echo -e " --- Erweiterte Optionen --- "
    echo -e "1) Komprimierung:"
    echo -e "    zstd   = Standard (schnell & gute Komprimierung)"
    echo -e "   gzip  = Langsamer, aber kleiner"
    echo -e "   lzma  = Sehr langsam, aber sehr klein"
    echo -e "   none  = Keine Komprimierung (schnellste Sicherung)"
    read -p "Komprimierung [zstd]: " COMPRESSION
    [ -z "$COMPRESSION" ] && COMPRESSION="zstd"
    echo -e "2) Max. Dateigröße (MB):"
    echo -e "    4000  = Standard (kompatibel mit FAT32)"
    echo -e "   0     = Keine Aufteilung"
    read -p "Max. Dateigröße [4000]: " SPLIT_SIZE
    [ -z "$SPLIT_SIZE" ] && SPLIT_SIZE="4000"
    echo -e "3) Prüfsumme nach Backup erstellen? (empfohlen)"
    echo -e "    Empfohlen:  Ja (stellt die Integrität sicher)"
    read -p "Prüfsumme erstellen? (j/n) [j]: " CHECKSUM
    [ -z "$CHECKSUM" ] && CHECKSUM="j"
fi
# =================================================================
# STEP 6: Befehl zusammenbauen und ausführen
# =================================================================
clear_screen
echo -e " --- Schritt 6: Zusammenfassung & Ausführung --- "
# Parameter zusammenbauen
OCS_CMD="ocs-sr"
OCS_CMD="$OCS_CMD -z$COMPRESSION"
OCS_CMD="$OCS_CMD -c"                          # Prüfsumme prüfen
[ "$SPLIT_SIZE" -gt 0 ] && OCS_CMD="$OCS_CMD -k -s $SPLIT_SIZE"  # Aufteilen
OCS_CMD="$OCS_CMD -enc -pe \"$PASSWORD\""     # Verschlüsselung
if [ "$MODE" = "backup" ]; then
    OCS_CMD="$OCS_CMD savedisk \"$BACKUP_NAME\" $SOURCE_DISK"
else
    OCS_CMD="$OCS_CMD restoredisk \"$BACKUP_NAME\" $TARGET_DISK"
fi
# Zusammenfassung anzeigen
echo -e " Modus:        $MODE"
if [ "$MODE" = "backup" ]; then
    echo -e " Quelle:        /dev/$SOURCE_DISK"
else
    echo -e " Ziel:          /dev/$TARGET_DISK"
fi
echo -e " Backup-Name:  $BACKUP_NAME"
echo -e " Backup-Pfad:  $DEFAULT_BACKUP_DIR/$BACKUP_NAME"
echo -e " Komprimierung:  $COMPRESSION"
[ "$SPLIT_SIZE" -gt 0 ] && echo -e " Dateigröße:    $SPLIT_SIZE MB"
echo -e " Verschlüsselung:  Aktiviert"
echo -e " Ausführender Befehl: "
echo -e " $OCS_CMD "
if [ "$MODE" = "restore" ]; then
    echo -e " ⚠️  WARNUNG: Dies löscht ALLE Daten auf /dev/$TARGET_DISK! "
    echo -e " ⚠️  Das Backup wird auf /dev/$TARGET_DISK geschrieben. "
fi
echo -e " Bist du sicher, dass du fortfahren möchtest? "
read -p "(j/n): " FINAL_CONFIRM
if [[ ! "$FINAL_CONFIRM" =~ ^[Jj]$ ]]; then
    echo -e " Abgebrochen. "
    exit 1
fi
# =================================================================
# AUSFÜHRUNG
# =================================================================
echo -e " Starte Backup/Recovery... "
echo -e " Bitte warten, dies kann einige Zeit dauern. "
# Zum Backup-Verzeichnis wechseln und Befehl ausführen
cd "$DEFAULT_BACKUP_DIR" || {
    echo -e " Fehler: Kann nicht nach $DEFAULT_BACKUP_DIR wechseln "
    exit 1
}
# Befehl ausführen
eval "$OCS_CMD"
# =================================================================
# NACHBEREINIGUNG
# =================================================================
echo -e " ============================================================ "
echo -e " ✅ Vorgang abgeschlossen! "
echo -e " ============================================================ "
# Prüfsumme erstellen (wenn gewünscht)
if [[ "$CHECKSUM" =~ ^[Jj]$ ]] && [ "$MODE" = "backup" ]; then
    echo -e " Erstelle Prüfsumme für das Backup... "
    cd "$DEFAULT_BACKUP_DIR/$BACKUP_NAME" 2>/dev/null
    sha256sum * > checksum.sha256
    echo -e " Prüfsumme gespeichert in: $DEFAULT_BACKUP_DIR/$BACKUP_NAME/checksum.sha256 "
fi
# Speicherplatz anzeigen
if [ "$MODE" = "backup" ]; then
    BACKUP_SIZE=$(du -sh "$DEFAULT_BACKUP_DIR/$BACKUP_NAME" 2>/dev/null | awk '{print $1}')
    echo -e " Backup-Größe: $BACKUP_SIZE "
fi
echo -e " Möchtest du das Backup-Laufwerk aushängen? "
read -p "(j/n) [n]: " UMOUNT
if [[ "$UMOUNT" =~ ^[Jj]$ ]]; then
    umount "$DEFAULT_BACKUP_DIR" 2>/dev/null
    echo -e " Backup-Laufwerk ausgehängt. "
fi
echo -e " Fertig! Du kannst Clonezilla jetzt beenden. "
press_any_key
exit 0