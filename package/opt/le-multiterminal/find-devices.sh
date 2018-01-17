#!/bin/bash

# Copyright (C) 2017 Centro de Computacao Cientifica e Software Livre
# Departamento de Informatica - Universidade Federal do Parana - C3SL/UFPR
#
# This file is part of le-multiterminal
#
# le-multiterminal is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301,
# USA.

#### Name: find-devices.sh
#### Description: Handles the event of a keyboard and associates the seat with the corresponding output.
#### Written by: Stephanie Briere Americo - sba16@c3sl.ufpr.br on 2017.

## Macros
DEVICES="/opt/le-multiterminal/devices" # shortcut to devices that have already been paired
CONF="/opt/le-multiterminal/98-xephyr-multi-seat.conf" # lightdm settings file (associates seat to output)

## Script/function in other file
READ_DEVICES="read-devices"
DETECT_KEYBOARDS="/opt/le-multiterminal/detect-keyboard.sh"
WRITE_W="write_window" # "window-acess.sh"

## Variables
declare -a SEATS_LISTED # save the name of the existing seats

find_keyboard () {
	fKey=$1 # key that this script should expect to be pressed
	wNum=$(($fKey-1)) # position in the window control vector

	# List all existing seats
	SEATS_LISTED=(seat0 $(loginctl list-seats | grep seat-))

	CREATED=0
	while test $CREATED -eq 0; do
		KEYBOARDS=$($DETECT_KEYBOARDS)

		# List all conected keyboards
		for i in `ls $MDM_DEVICES | grep "\<keyboard"`; do
			KEYBOARDS=$(sed "s#$i##g" <<< $KEYBOARDS)
		done

		# If no keyboard is connected, you can not proceed
		if test -z "$KEYBOARDS"; then
		    echo "[Error] No keyboards connected"
		    exit 1
		fi

		# See if someone presses the expected key
		PRESSED=$($READ_DEVICES $fKey $KEYBOARDS | grep '^detect' | cut -d'|' -f2)

		# If $READ_DEVICES gets killed the script won't do bad stuff
		if test -z "$PRESSED"; then
		    continue
		fi

		# If the key has not yet been processed, continue to wait
		if test "$PRESSED" = 'timeout'; then
		    continue
		fi

		# If you got here, then the key was pressed
		CREATED=1

		# Creates a link to the keyboard so no one else can use it
		ln -sf $PRESSED $DEVICES/keyboard_$fKey

		# Check if there is no longer a link to this keyboard
		for i in `ls $DEVICES | grep "\<keyboard"`; do
		    if test "$i" != "keyboard_$fKey"; then
			AUX=$(stat -c %N $DEVICES/$i | cut -d '>' -f2 | cut -d "'" -f2)

			if test "$AUX" = "$PRESSED"; then
			# Keyboard link already exists, try again
			rm -f $DEVICES/keyboard_$fKey
			CREATED=0
			fi
		    fi
		done
	done

	# Find device address
	SYS_DEV=/sys$(udevadm info $PRESSED | grep 'P:' | cut -d ' ' -f2- | sed -r 's/event.*$//g')

	if test -n "$SYS_DEV"; then
		# Now we know the seat/output
		SEAT_NAME=$(udevadm info -p $SYS_DEV | grep ID_SEAT | cut -d '=' -f2)

		# Sometimes the devices that belong to seat0 do not have ID_SEAT
		if test -z "$SEAT_NAME"; then
		    SEAT_NAME=seat0
		fi

		$WRITE_W ok $wNum

		# Write in configuration file
		if test $fKey -gt 1; then
			echo -e "[Seat:$SEAT_NAME]\nxserver-command=xephyr-wrapper :90.0 -output ${OUTPUTS[$((wNum-1))]}\n" >> $CONF
		fi

		exit 0
	else
		echo "[Error] Can not find keyboard!"
		exit 2
	fi
}
