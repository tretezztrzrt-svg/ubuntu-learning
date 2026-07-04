===============================================================================
                  UBUNTU PACKAGE CHEAT SHEET (APT / SNAP / FLATPAK)
===============================================================================
Ein kompakter Spickzettel fuer die wichtigsten Paket- und App-Formate unter Ubuntu
sowie nuetzliche Befehle zur Verwaltung von Speicherplatz, Versionen und Diensten.

-------------------------------------------------------------------------------
1. DER DIREKTE VERGLEICH: APT VS. SNAP VS. FLATPAK
-------------------------------------------------------------------------------

Aktion                         | Klassisch (apt)             | Modern (snap)               | Universal (flatpak)
-------------------------------|-----------------------------|-----------------------------|---------------------
Paket suchen                   | apt search <name>           | snap find <name>            | flatpak search <name>
App installieren               | sudo apt install <name>     | sudo snap install <name>    | flatpak install flathub <name>
App entfernen                  | sudo apt remove <name>      | sudo snap remove <name>     | flatpak uninstall <name>
Updates installieren           | sudo apt update &&          | sudo snap refresh           | flatpak update
                               | sudo apt upgrade            |                             |
Installierte Apps auflisten    | apt list --installed        | snap list                   | flatpak list
Informationen anzeigen         | apt show <name>             | snap info <name>            | flatpak info <name>

Hinweis: Flatpak ist oft die beste Wahl fuer Apps, die aktuellere Versionen
oder weniger Abhaengigkeiten brauchen. Unter Ubuntu funktionieren auch AppImages
sehr gut: einfach eine pcsx2.appimage-Datei mit chmod +x markiert und ausfuehren.


-------------------------------------------------------------------------------
2. FORTGESCHRITTENE SNAP-BEFEHLE
-------------------------------------------------------------------------------

VERSIONEN VERWALTEN & FEHLERBEHEBUNG
* Eine bestimmte App manuell aktualisieren:
  sudo snap refresh <app-name>

* Zur vorherigen Version zurueckkehren (Downgrade):
  (Falls ein Update Fehler verursacht, springst du sofort zur Vorversion zurueck)
  sudo snap revert <app-name>

DIENSTE (DAEMONS) STEUERN
* Alle Dienste einer App anzeigen:
  snap services <app-name>

* Dienst stoppen und dauerhaft deaktivieren:
  sudo snap stop --disable <app-name>.<dienst>

* Dienst starten und aktivieren (beim Systemstart):
  sudo snap start --enable <app-name>.<dienst>


-------------------------------------------------------------------------------
3. FLATPAK-BEFEHLE
-------------------------------------------------------------------------------

* Flatpak zuerst installieren (falls noetig):
  sudo apt install flatpak

* Flathub als Quelle hinzufuegen:
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

* App installieren:
  flatpak install flathub <app-id>

* App aktualisieren:
  flatpak update

* App entfernen:
  flatpak uninstall <app-id>

* Installierte Flatpaks auflisten:
  flatpak list


-------------------------------------------------------------------------------
4. SPEICHERPLATZ BEREINIGEN (CLEAN / MAINTENANCE)
-------------------------------------------------------------------------------

Snap behaelt standardmaessig alte Versionen als Backup. Wenn du Speicherplatz 
freigeben moechtest, kannst du das wie folgt optimieren:

* Anzahl der gesicherten Versionen auf das Minimum (2) reduzieren:
  sudo snap set system refresh.retain=2

* Alle Versionen (auch alte, inaktive) auflisten:
  (Suche nach Eintraegen mit dem Status "disabled")
  snap list --all

* Eine spezifische alte Version manuell loeschen:
  sudo snap remove <app-name> --revision=<nummer>


-------------------------------------------------------------------------------
5. BERECHTIGUNGEN (INTERFACES) VERWALTEN
-------------------------------------------------------------------------------

Da Snaps isoliert (Sandbox) laufen, benoetigen sie fuer bestimmte Aktionen 
(z.B. Zugriff auf Kamera, USB oder Heimverzeichnis) explizite Berechtigungen.

* Aktuelle Berechtigungen einer App einsehen:
  snap connections <app-name>

* Eine Berechtigung erlauben (verbinden):
  sudo snap connect <app-name>:<interface>

* Eine Berechtigung entziehen (trennen):
  sudo snap disconnect <app-name>:<interface>


-------------------------------------------------------------------------------
6. APPIMAGE-HINWEIS
-------------------------------------------------------------------------------

* AppImages sind einzelne Portable-Apps mit der Endung .appimage.
* Unter Ubuntu funktionieren sie oft direkt, wenn du sie ausfuehrbar machst:
  chmod +x dateiname.AppImage
  ./dateiname.AppImage

* Wenn du willst, kannst du sie auch mit einem Doppelklick starten, sofern die
  Dateirechte korrekt gesetzt sind.

===============================================================================
