# disk_wiper

An application for the automated and simultaneous wiping of hard drives on a Linux server using the Adaptec ASR71605 RAID controller.


## Description 

Up to 12 hard drives can be wiped simultaneously. Once a drive is inserted into a slot, it is detected within a few minutes and erased by a single overwrite with zeros. After the wiping process is completed, a status file is created containing information such as the drive’s serial number, the start and end time of the wiping process, and the drive’s S.M.A.R.T. values. This file is written to a USB stick connected to the server. (If no USB stick is connected, the data is stored locally.)

![disk_wiper](https://github.com/dW5kZWFk/disk_wiper/assets/100794989/e16a641e-fe4f-4674-995d-b9e67dcc194d)

Since the RAID controller automatically detects defective drives and does not initialize them, no wiping process is typically started for such drives.  
Hard drives can be inserted and removed independently. A wiping process can be aborted by removing the drive.

## Functionality

When a storage device is added, a udev rule is triggered, which starts the script "add_disk.sh". The script initializes the wiping process and updates a text file in the corresponding slot with the current progress.  
When a drive is removed, the script "remove_disk.sh" is triggered, which clears the corresponding text file.  
The file "status.html" displays the contents of all progress files for the slots to the user (see image above).

## Configuration
(tested with Ubuntu Server 22.04.1 and gdm3)

[Adaptec Command Line Utility](https://storage.microsemi.com/en-us/speed/raid/storage_manager/arcconf_v1_7_21229_zip.htm) is required for communication with the RAID controller via the scripts. The following steps are also necessary: 

<ul>
  <li>Write the udev rules in /etc/udev/rules.d/90-block.rules (Ubuntu Server).</li>
  <li>Create the directory that stores the progress files, or adjust the path in the scripts and in the file "status.html".</li>
  <li>Define the script "start_gui.sh" as a service that runs on system startup.</li>
</ul>

<!--~/.config/systemd/user/wiper_gui.service (enable: systemctl --user enable wiper_gui) -->

(This project was originally designed in German and the README translated.)
