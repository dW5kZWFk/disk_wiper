#!/bin/bash

#$1: SCSI_IDENT (logical identifier RAID)
#$2: DEVNAME (e.g. /dev/sda)

echo "SCSI_IDENT: $1" >> /home/eraser/diskwiper_gui/test.txt 
slot=`sudo ./bin/arcconf getconfig 1 ld | grep -A 18 $1 | grep 'Slot:'`

#for testing:
#slot=`sudo ./arcconf getconfig 1 ld | grep -A 18 $1 | grep 'Slot:'`


##############################################################################################
serial=${slot##*)}
serial=`echo $serial | tr -d ' '`


#S.M.A.R.T with Controller:
health_controller=`sudo ./bin/arcconf getconfig 1 pd  | grep -A 9 $serial | grep 'S.M.A.R.T. warnings'`

#for testing
#health_controller=`sudo ./arcconf getconfig 1 pd  | grep -A 9 $serial | grep 'S.M.A.R.T. warnings'`


health_controller=${health_controller##*:}

if [ "0" -eq $health_controller ]
then
	echo "smart controller: OK"
fi

#S.M.A.R.T with smartctl:
health_os=`smartctl -d scsi --all $2 | grep 'SMART Health Status'`
health_os=${health_os##*:}
health_os=`echo $health_os | tr -d ' '`


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
		echo "Zuordnungsfehler" >> /home/eraser/diskwiper_gui/snips/error_msg.txt
		;;
esac

####################################################################
#Statusanzeige - Verbinden
status_file="/home/eraser/diskwiper_gui/snips/status${l_slot}.txt"
echo "verbunden" > $status_file
chown eraser $status_file

if [[ "$health_os" == "OK" ]] && [ "0" -eq $health_controller ]
then
        echo " S.M.A.R.T. Health: OK" >> $status_file
else
	echo " S.M.A.R.T. Health: Not OK - remove disk" >> $status_file
	exit 0
fi

######################################################################
#Löschen und Progress

tmp_file="/home/eraser/diskwiper_gui/snips/tmp${l_slot}.txt"
progress_file="/home/eraser/diskwiper_gui/snips/progress${l_slot}.txt"

#deletion:
dcfldd if=/dev/zero of=${DEVNAME} status=on sizeprobe=of statusinterval=25600 &> $tmp_file &
dd_id=$!
start_date=`date`
echo $dd_id >> /home/eraser/diskwiper_gui/test.txt
while kill -0 "$dd_id" >/dev/null 2>&1; do
	echo "loop" >> /home/eraser/diskwiper_gui/test.txt
	x=`cat $tmp_file`
	y=${x##*[}
	echo "["${y%%.*} > $progress_file
	echo "$start_date" >> $progress_file
	echo "" > $tmp_file 	#long string
	chown eraser $progress_file
	sleep 10
done

#Abbruch des Vorgangs:
wait $dd_id
exit_state=$?

if [ $exit_state -gt 0 ]
then
	echo "Löschvorgang auf Slot $l_slot abgebrochen." >> /home/eraser/diskwiper_gui/snips/error_msg.txt
	exit 1
fi

echo "Löschung abgeschlossen - Log File ${serial}.txt geschrieben." > $progress_file
chown eraser $progress_file

##############################################################################################
#Log-File schreiben:


#create directory for current month, if it does not exist
dirname=`date +"%m_%Y"`

if [ ! -d /home/eraser/diskwiper_gui/logs/$dirname ]
then
		mkdir /home/eraser/diskwiper_gui/logs/$dirname
fi

log_file="/home/eraser/diskwiper_gui/logs/${dirname}/${serial}.txt"

disk_info=`sudo ./bin/arcconf getconfig 1 pd | grep -A 5 -B 2 $serial`
end_date=`date`

echo "Löschung abgeschlossen - einmaliges Überschreiben mit 0 en." > $log_file
echo "Start: $start_date" >> $log_file
echo "Abgeschlossen: $end_date" >> $log_file
echo "-----------------------------------------------------------" >> $log_file
echo "Gerät:">> $log_file
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

#echo $status_file >> "/home/eraser/diskwiper_gui/test.txt"
#echo Slot: $slot >> /home/eraser/diskwiper_gui/test.txt
#echo $2 >>/home/eraser/diskwiper_gui/test.txt
