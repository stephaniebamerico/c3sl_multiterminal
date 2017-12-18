#!/bin/bash

## Script/function constants
READ_DEVICES=read-devices
DETECT_KEYBOARDS=detect-keyboard.sh
WRITE_W=write_window
DEVICES=devices
declare -a SEATS_LISTED # save the name of the existing seats


find_keyboard () {
	fKey=$1
	wNum=$(($fKey-1))

	SEATS_LISTED=(seat0 $(loginctl list-seats | grep seat-))

	CREATED=0
	while (( ! CREATED )); do
		KEYBOARDS=$($DETECT_KEYBOARDS)

		for i in `ls $MDM_DEVICES | grep "\<keyboard"`; do
			KEYBOARDS=$(sed "s#$i##g" <<< $KEYBOARDS)
		done

		if [ -z "$KEYBOARDS" ]; then
		    echo "No keyboards connected"
		    sleep 1
		    continue
		fi

		# See if someone presses the key:
		PRESSED=$($READ_DEVICES $fKey $KEYBOARDS | grep '^detect' | cut -d'|' -f2)

		if [ -z "$PRESSED" ]; then # if $READ_DEVICES gets killed the script won't do bad stuff
		    continue
		fi

		if [ "$PRESSED" = 'timeout' ]; then
		    continue
		fi

		CREATED=1

		ln -sf $PRESSED $DEVICES/keyboard_$fKey

		for i in `ls $DEVICES | grep "\<keyboard"`; do
		    if [ "$i" != "keyboard_$fKey" ]; then
			AUX=$(stat -c %N $DEVICES/$i | cut -d '>' -f2 | cut -d "'" -f2)
			if [ "$AUX" = "$PRESSED" ]; then
			    # Keyboard link already exists...
			    rm -f $DEVICES/keyboard_$fKey
			    CREATED=0
			fi
		    fi
		done
	done

	SYS_DEV=/sys$(udevadm info $PRESSED | grep 'P:' | cut -d ' ' -f2- | sed -r 's/event.*$//g')

	if [ -n "$SYS_DEV" ]; then 
		# Now we know the seat/output
		SEAT_NAME=$(udevadm info -p $SYS_DEV | grep ID_SEAT | cut -d '=' -f2)

		# Sometimes the devices that belong to seat0 do not have ID_SEAT
		if [ -z "$SEAT_NAME" ]; then
		    SEAT_NAME=seat0
		fi

		$WRITE_W ok $wNum

		# Write in configuration file
		if [[ $fKey -gt 1 ]]; then
			echo -e "[Seat:$SEAT_NAME]\nxserver-command=xephyr-wrapper :90.0 -output ${OUTPUTS[$((wNum-1))]}\n" >> configuracao
		fi

		exit 1
	else
		echo "CAN NOT FIND KEYBOARD"

		exit 0
	fi
}