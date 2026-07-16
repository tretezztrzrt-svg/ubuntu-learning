Clonezilla Backup: Kurzanleitung für SSDs/NVMe
Vorbereitung
Backup-Medium (USB-Festplatte) mit Skripten vorbereiten
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

Copy
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT,MODEL
NVMe: nvme0n1, nvme1n1
SSD: sda, sdb
Backup-Platte: meist sdb1 oder sdc1
4. Backup-Medium mounten
bash

Copy
mkdir -p /mnt/backup
mount /dev/sdb1 /mnt/backup  # sdb1 durch deine Partition ersetzen
5. Skript starten
bash

Copy
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
Wichtige Sicherheitshinweise
Passwort sicher aufbewahren - ohne kein Recovery!
NICHT die Backup-Platte als Quelle wählen
Gemountete Partitionen automatisch prüfen
Mehrfache Bestätigung vor Datenüberschreibung
Tipps für SSDs/NVMe
zstd-Komprimierung: Schnell & effizient
Prüfsumme aktivieren: Für Integrität
UEFI-Modus: Bessere NVMe-Erkennung
Fertig! Das Backup liegt verschlüsselt auf deiner externen Platte.