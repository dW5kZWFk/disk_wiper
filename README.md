

Ubuntu Server 22.04.1, gdm3
Raid-Controller: Adaptec ASR71605

Adaptec Command Line Utility, necessary to communicate with RAID-Controller:
https://storage.microsemi.com/en-us/speed/raid/storage_manager/arcconf_v1_7_21229_zip.htm
udev rules in /etc/udev/rules.d/90-block.rules

systemctl service to start browser with status page after boot finished
~/.config/systemd/user/wiper_gui.service (enable: systemctl --user enable wiper_gui)
