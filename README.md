## 🧰 Meine Bash-Toolbox

### Aliases – Schnelle Befehle

| Alias | Befehl | Beschreibung |
| :--- | :--- | :--- |
| `home` | `cd /home/alex/` | Wechselt ins Home |
| `var` | `cd /var/` | Wechselt nach `/var` |
| `log` | `cd /var/log/` | Wechselt in die Logs |
| `etc` | `cd /etc/` | Wechselt nach `/etc` |
| `dvd` | `cd .. && ls -la` | Eine Ebene hoch mit Auflistung |
| `c` | `clear` | Terminal leeren |
| `q` | `exit` | Terminal beenden |
| `x` | `chmod +x` | Datei ausführbar machen |
| `reboot` | `shutdown -r now` | Sofort neu starten |
| `ram` | `free -h --si` | RAM-Auslastung anzeigen |
| `platz` | `df -hPT \| column -t` | Speicherplatz als Tabelle |
| `diskinfo` | `lsblk` | Festplatten und Partitionen anzeigen |
| `install` | `sudo apt install` | Paket installieren |
| `uninstall` | `sudo apt remove` | Paket entfernen |
| `update` | `sudo apt update && sudo apt full-upgrade -y && sudo snap refresh && sudo flatpak update -y` | **Alles** aktualisieren |
| `top` | `btop` | Systemmonitor (btop) |

### Funktionen – Echte Helfer

| Funktion | Nutzung | Beschreibung |
| :--- | :--- | :--- |
| `hello <ordner>` | `hello /etc` | In Ordner wechseln und Inhalt anzeigen |
| `back` | `back` | Eine Ebene zurück mit Auflistung |
| `make-dir <name>` | `make-dir projekt` | Ordner erstellen und hineinwechseln |
| `entpack <datei.7z>` | `entpack archiv.7z` | 7z-Archiv entpacken |
| `pack <quelle> <ziel>` | `pack ordner backup` | Ordner als 7z packen |
| `pack-harder <quelle> <ziel>` | `pack-harder ordner backup` | 7z mit maximaler Kompression |
| `tarfix <name.tar.gz> <dateien...>` | `tarfix backup.tar.gz file1 file2` | tar.gz-Archiv erstellen |
| `untar <datei.tar.gz>` | `untar backup.tar.gz` | tar.gz-Archiv entpacken |

### 🖥️ GUI-Tools für die Serververwaltung

**Cockpit** – moderne, schlanke Weboberfläche:
```bash
sudo apt install cockpit
# Danach aufrufen: https://<server-ip>:9090

Webmin – der Klassiker mit extrem vielen Einstellungen:
bash

curl -o webmin-setup-repo.sh https://raw.githubusercontent.com/webmin/webmin/master/webmin-setup-repo.sh
sudo sh webmin-setup-repo.sh
sudo apt-get install webmin --install-recommends
# Danach aufrufen: https://<server-ip>:10000

    Tipp: Cockpit ist der perfekte Einstieg – modern und schnell. Webmin bietet mehr Details, wenn du wirklich jede Schraube drehen willst. Beide kann man nebeneinander betreiben.
```

