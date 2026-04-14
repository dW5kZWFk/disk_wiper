# disk_wiper

Eine Anwendung zum automatisierten und gleichzeitigem Löschen von Festplatten auf einem Linux-Server mit dem Adaptec ASR71605 Raid-Controller.

## Beschreibung 

Bis zu 12 Festplatten können gleichzeitig gelöscht werden. Nachdem eine Festplatte in den Einschub platziert wurde, wird diese innerhalb weniger Minuten erkannt und durch einmaliges Überschreiben mit Nullen gelöscht. Nach Beendigung eines Löschvorgangs wird eine Statusdatei erstellt, welche Informationen wie die Seriennummer der Platte, den Start- und Endzeitpunkt des Löschvorgangs sowie die S.M.A.R.T.-Werte der Platte speichert. Diese Datei wird auf einen mit dem Server verbundenen USB-Stick geschrieben. (Falls kein Stick verbunden ist, werden die Daten lokal gespeichert.)

![disk_wiper](https://github.com/dW5kZWFk/disk_wiper/assets/100794989/e16a641e-fe4f-4674-995d-b9e67dcc194d)

Da der RAID-Controller defekte Platten automatisch als solche erkennt und sie nicht einbindet, wird für diese in der Regel kein Löschvorgang gestartet.
Festplatten können unabhängig voneinander hinzugefügt und entfernt werden. Ein Löschvorgang kann durch das Entfernen einer Platte abgebrochen werden.

## Funtkionsweise

Nach dem Hinzufügen eines Datenträgers wird eine udev-Regel ausgelöst, die das Skript "add_disk.sh" startet. Das Skript initialisiert den Löschvorgang und überschreibt eine Textdatei im verwendeten Einschub mit dem aktuellen Fortschritt. Durch Entfernen einer Platte wird das Skript "remove_disk.sh" ausgelöst, welches die Textdatei wieder leert.
Die Datei "status.html" zeigt die Inhalte aller Fortschrittsdateien der Einschübe für den Anwender an (siehe Bild oben).

## Konfiguration
(getestet mit Ubuntu-Server 22.04.1 und gdm3)

[Adaptec Command Line Utility](https://storage.microsemi.com/en-us/speed/raid/storage_manager/arcconf_v1_7_21229_zip.htm) ist Voraussetzung für die Kommunikation mit dem Raid-Controller durch die Skripte. Folgende Schritte sind ebenfalls Notwendig: 

<ul>
  <li> Schreiben der udev-Regeln in /etc/udev/rules.d/90-block.rules (Ubuntu-Server).</li>
  <li> Das Verzeichnis, welches die Fortschrittsdateien enthält anlegen, respektive den Pfad im Skript und der Datei "status.html" anpassen. <!-- Schreib und Leserechte --> </li>
  <li> Das Skript "start_gui.sh" als Service definieren, der nach Systemstart ausgeführt wird. </li>
</ul>

<!--~/.config/systemd/user/wiper_gui.service (enable: systemctl --user enable wiper_gui) -->
