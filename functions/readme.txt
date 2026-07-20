FUNKTIONSKATEGORIEN
NAVIGATION
hello <ordnername> -> Wechselt in Ordner + zeigt Inhalt
back -> Geht eine Ebene zurück + zeigt Inhalt
make-dir <name> -> Erstellt Ordner und wechselt hinein
ARCHIVIERUNG
entpack <archiv.7z> -> Entpackt .7z Archive
pack <quelle> [ziel] -> Packt zu .7z (Standard)
pack-harder <quelle> [ziel] -> Packt zu .7z (maximal)
tarfix <archiv.tar.gz> <dateien> -> Erstellt .tar.gz
untar <archiv.tar.gz> -> Entpackt .tar.gz
SICHERUNG
backup <pfad> -> Sichert nach ~/backup/ mit Log
trash <pfad> -> Verschiebt nach ~/trash/ mit Log
SYSTEM
service {action} <service> -> systemctl Wrapper
please / fuck -> Letzten Befehl mit sudo
killforce <PID> -> Beendet Prozesse (SIGKILL)
who-to-kill -> Zeigt RAM/CPU-Verbraucher
FESTPLATTE
ordner [pfad] -> Verzeichnisgröße sortiert
sortiert -> Dateigrößen sortiert
bigfiles [pfad] -> 10 größte Dateien
HISTORIE
profile_me [n] -> Häufigste Befehle
PROJEKTE
projektname <name> -> Erstellt vollständiges Projekt
VORAUSSETZUNGEN
p7zip-full: sudo apt install p7zip-full
ncdu empfohlen: sudo apt install ncdu
LOG-DATEIEN
Backup-Logs: ~/backup/<YYYY-MM-DD>func.log Trash-Logs: ~/trash/<YYYY-MM-DD>func.log

WICHTIGE HINWEISE
killforce verwendet SIGKILL (unwiderruflich)
trash verschiebt nur, löscht nicht endgültig
Log-Dateien für Nachvollziehbarkeit
Für interaktive Bash-Shells gedacht
