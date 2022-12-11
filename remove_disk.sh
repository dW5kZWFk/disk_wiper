#!/bin/bash

#rescan all disks
#overwrite empty disks -> not connected:

sudo ./bin/arcconf slotconfig 1 ALL MAP | grep -A 11 "Slot 0"|
while read line;
do
	#echo $line 
	if [[ $line == *"EMPTY"* ]];
	then
#		echo "empty"
		no=${line%:*}
		no=${no#*Slot}
		no=`echo $no | tr -d ' '`
		echo $no	
		
		case $no in
        	0)
                	l_slot="9"
                	;;
       	 	1)
                	l_slot="5"
                	;;
       	 	2)
                	l_slot="1"
                	;;
        	3)
                	l_slot="10"
                	;;
        	4)
                	l_slot="6"
                	;;
        	5)
                	l_slot="2"
                	;;
        	6)
                	l_slot="11"
                	;;
        	7)
                	l_slot="7"
                	;;
        	8)
                	l_slot="3"
                	;;
        	9)
                	l_slot="12"
                	;;
        	10)
                	l_slot="8"
                	;;
        	11)
                	l_slot="4"
                	;;
        	*)
                	echo "Zuordnungsfehler bei dem Entfernen des Datenträgers" >> /home/eraser/diskwiper_gui/snips/error_msg.txt
                	;;
		esac

		status_file="/home/eraser/diskwiper_gui/snips/status${l_slot}.txt"
		progress_file="/home/eraser/diskwiper_gui/snips/progress${l_slot}.txt"
		echo "nicht verbunden" > $status_file
		chown eraser $status_file	
		echo "" > $progress_file
		chown eraser $progress_file
	fi
done 
