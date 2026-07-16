# 1. Clonezilla booten → Konsole
# 2. Backup-Platte mounten
mount /dev/sdb1 /mnt/backup
# 3. Skript starten
cd /mnt/backup && ./clonezilla-smart.sh