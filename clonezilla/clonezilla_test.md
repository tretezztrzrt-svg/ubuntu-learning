# 1. Clonezilla booten → Konsole
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT,MODEL 2>/dev/null
# lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT
    
# 2. Backup-Platte mounten
mount /dev/sdb1 /mnt/backup
# 3. Skript starten
cd /mnt/backup && ./clonezilla-smart.sh

Skripte ausführbar machen: chmod +x clonezilla-smart.sh

Schritt-für-Schritt Backup
1. Clonezilla booten
USB einstecken → PC neustarten → Boot-Menü (F12/F10/ESC)
UEFI-Modus wählen (für NVMe wichtig)
"Clonezilla live" auswählen

2. Shell öffnen
"Enter_shell" oder Strg+Alt+T für Terminal
Bei Bedarf Root: sudo -i

3. Geräte identifizieren
bash


lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT,MODEL

NVMe: nvme0n1, nvme1n1
SSD: sda, sdb
Backup-Platte: meist sdb1 oder sdc1

4. Backup-Medium mounten
mkdir -p /mnt/backup
mount /dev/sdb1 /mnt/backup  # sdb1 durch deine Partition ersetzen

5. Skript starten
cd /mnt/backup
./clonezilla-smart.sh

6. Interaktiver Prozess

Modus: 1 für Backup
Backup-Name: z.B. laptop-backup-2026-07-17
Quelle: NVMe/SSD (z.B. nvme0n1)
Passwort: Mind. 8 Zeichen, kein Leerzeichen
Optionen: ENTER für Standard (zstd, 4000MB, Prüfsumme)
Bestätigen: j → Backup startet
Nach dem Backup
Prüfsumme wird erstellt (falls aktiviert)
Backup-Größe wird angezeigt
Aushängen? j/n für Backup-Medium
Clonezilla beenden → System neustarten