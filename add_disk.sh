#!/bin/bash

#$1: SCSI_IDENT (logical identifier RAID)
#$2: DEVNAME (e.g. /dev/sda)

slot=`sudo ./bin/arcconf getconfig 1 ld | grep -A 18 $1 | grep 'Slot:'`


serial=${slot##*)}
serial=`echo $serial | tr -d ' '`
##################################################################
#map physical slots to logical (user) slots:
slot=${slot##*:}
slot=${slot%)*} 


case $slot in
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
		#device is faulty and not registered as logical device
		exit 0
		;;
esac

##############################################################################################


#S.M.A.R.T with Controller:
health_controller=`sudo ./bin/arcconf getconfig 1 pd  | grep -A 9 $serial | grep 'S.M.A.R.T. warnings'`

health_controller=${health_controller##*:}

if [ "0" -eq $health_controller ]
then
	echo "smart controller: OK"
fi

#S.M.A.R.T with smartctl:
health_os=`sudo smartctl -d scsi --all $2 | grep 'SMART Health Status'`
health_os=${health_os##*:}
health_os=`echo $health_os | tr -d ' '`



#Statusanzeige - Verbinden
status_file="/home/eraser/diskwiper_gui/snips/status${l_slot}.txt"
progress_file="/home/eraser/diskwiper_gui/snips/progress${l_slot}.txt"


echo "verbunden" > $status_file
echo "" > $progress_file

chown eraser $status_file

if [[ "$health_os" == "OK" ]] && [ "0" -eq $health_controller ]
then
        echo "Zustand Datenträger: Gut " >> $status_file
else
	echo "Zustand Datenträger: Defekt - Datenträger entfernen" >> $status_file
	exit 0
fi

######################################################################
#Löschen und Progress

tmp_file="/home/eraser/diskwiper_gui/snips/tmp${l_slot}.txt"

#deletion:
dcfldd if=/dev/zero of=$2 status=on sizeprobe=of statusinterval=25600 &> $tmp_file &
#sleep 5 &
dd_id=$!

start_date=`date +"%d.%m.%Y-%T"`
echo $dd_id >> /home/eraser/diskwiper_gui/test.txt
while kill -0 "$dd_id" >/dev/null 2>&1; do
	x=`cat $tmp_file`
	y=${x##*[}
	
	#write only if tmp is not currently empty
	if [ ! -z "$y" ]
	then
		echo "Löschvorgang gestartet ($start_date)" > $progress_file
		echo "["${y%%.*} >> $progress_file
	fi
	echo "" > $tmp_file 	#long string
	chown eraser $progress_file
	sleep 10
done

cat $status_file | grep "nicht verbunden"
disconnected=$?
echo "disconnected: $disconnected" >> /home/eraser/diskwiper_gui/snips/error_msg.txt

if [ $disconnected -eq 0 ]
then
	echo "Löschvorgang abgebrochen." > $progress_file
	exit 1
fi


##############################################################################################
#write Log-File:


#create directory for current month, if it does not exist
dirname=`date +"%m_%Y"`

#check whether usb stick is mounted AND physically connected (if not default to local path for saving logs)
if findmnt /media/logs >/dev/nul && ls -l /dev/disk/by-uuid | grep E8C8-4D1E >/dev/nul;
	then
		local=1
		path=/media/logs/
	else
		path=/home/eraser/dskwiper_gui/logs/
fi		

if [ ! -d $path$dirname ]
then
		mkdir $path$dirname
fi

log_file="${path}${dirname}/${serial}.txt"

disk_info=`sudo ./bin/arcconf getconfig 1 pd | grep -A 5 -B 2 $serial`
end_date=`date +"%d.%m.%Y-%T"`

echo "Löschung des Datenträgers durch einmaliges Überschreiben mit nullen." > $log_file
echo "Start des Löschvorgangs: $start_date" >> $log_file
echo "Löschvorgang abgeschlossen am: $end_date" >> $log_file
echo "-----------------------------------------------------------" >> $log_file
echo "Geräteinformationen:">> $log_file
echo  "$disk_info">>$log_file
echo "-----------------------------------------------------------" >> $log_file
echo "S.M.A.R.T.-Werte" >> $log_file

#channel und physical ID des Datenträgers:
x=`sudo ./bin/arcconf getconfig 1 pd | grep -B 6 $serial | grep "Reported Channel"`; 
y=${x##*,};
z=${y%%(*};
smarts=`sudo ./bin/arcconf getsmartstats 1 | grep -A 25 "id=\"$z\""`
echo "$smarts" >> $log_file


chown eraser $log_file

if [[ $local -eq 1 ]]
	then
		echo "Löschvorgang abgeschlossen - Log-Datei ${serial}.txt gespeichert." > $progress_file
	else
		echo "Löschvorgang abgeschlossen - USB-Stick nicht verbunden. Log-Datei ${serial}.txt lokal gespeichert." > $progress_file
fi

chown eraser $progress_file
