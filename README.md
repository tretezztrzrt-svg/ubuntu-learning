Übersicht für Git (ohne Ordner "old")

Kurzbeschreibung
- Dieses Repository enthält Lernmaterialien für Ubuntu.
- Der Ordner "old" wird nicht berücksichtigt/verwaltet (sollte in .gitignore stehen).

Empfohlene .gitignore-Einträge
- old/

Grundlegende Git-Befehle
- Repository initialisieren: git init
- Änderungen hinzufügen: git add <dateien>
- Commit erstellen: git commit -m "Kurzbeschreibung"
- Änderungen pushen: git push origin main
- Remote-Änderungen holen: git pull
- Branch erstellen: git checkout -b <branch-name>

Arbeitsablauf (grob)
1) Branch erstellen: git checkout -b feature/x
2) Änderungen vornehmen und prüfen: git status, git diff
3) Änderungen hinzufügen und committen: git add ., git commit -m "Beschreibung"
4) Push und Merge Request (PR) erstellen: git push origin feature/x -> Erstelle PR auf der Plattform

Hinweis
- Stellen Sie sicher, dass der Ordner "old" in der .gitignore steht, damit er nicht versehentlich eingecheckt wird.
