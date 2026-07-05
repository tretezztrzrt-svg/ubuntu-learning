#!/bin/bash
# Führt install-common aus (dies ist ein Alias)
sudo apt update -qq
install-common
# Wechsle in das Verzeichnis ubuntu-learning
cd ubuntu-learning
# Verschiebe den Ordner schript (im aktuellen Verzeichnis) nach ~
mv schript ~/
mv backup ~/
mv trash ~/

echo "jo, jetzt kann eben backup eingerichtet werden, aber func backup und trash ist mit den directory scharf"

# ---------- Schritt 6: GNOME – RDP ----------
echo "optinal  und testen"
echo "[6/10] Aktiviere RDP-Server (Port 3389) ..."
if gsettings list-schemas | grep -q "org.gnome.desktop.remote-desktop.rdp"; then
    gsettings set org.gnome.desktop.remote-desktop.rdp enable true
    echo "   ✅ [6/10] Fertig."
else
    echo "   ⚠️  [6/10] RDP nicht verfügbar – 'gnome-remote-desktop' fehlt."
fi
