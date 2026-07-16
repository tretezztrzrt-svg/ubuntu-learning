# 1. Clonezilla booten → Konsole wählen (Enter_shell)

# 2. Backup-Festplatte mounten
mkdir -p /mnt/backup
mount /dev/sdb1 /mnt/backup   # sdb1 durch deine Partition ersetzen

# 3. Skript ausführen
cd /mnt/backup
./clonezilla-smart.sh