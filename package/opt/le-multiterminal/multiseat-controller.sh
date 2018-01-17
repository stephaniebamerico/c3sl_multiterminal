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

#### Name: multiseat-controller.sh
#### Description: Prepares the environment and launches the seat configuration scripts.
#### Xorg that communicates with the Thinnetworks card (fake-seat) should already be running.
#### Written by: Stephanie Briere Americo - sba16@c3sl.ufpr.br on 2017.

set -x

export PATH=$PATH:/opt/le-multiterminal

## Auxiliary scripts
source /opt/le-multiterminal/find-devices.sh
source /opt/le-multiterminal/window-acess.sh

## Path constants
MC3SL_DEVICES="/opt/le-multiterminal/devices" # shortcut to devices that have already been paired
MC3SL_CONF="/opt/le-multiterminal/98-xephyr-multi-seat.conf" # lightdm settings file (associates seat to output)
LIGHTDM_CONF="/etc/xdg/lightdm/lightdm.conf.d/98-xephyr-multi-seat.conf"

## Script/function in other file
FIND_KEYBOARD="find_keyboard" # "find-devices.sh"
CREATE_WINDOW="create_window" # "window-acess.sh"
WRITE_WINDOW="write_window" # "window-acess.sh"

## Macros
FAKE_DISPLAY=:90 # display to access fake-seat (secondary card)
FAKE_SEAT="__fake-seat-1__"
OUTPUTS=("LVDS" "VGA") # output options
MAX_ATTEMPTS=100

## Variables
WINDOW_ID_INIT=0 # if the onboard board, the start is 0; otherwise it is 1
WINDOW_COUNTER=0 # how many windows were created
N_SEATS_LISTED=0 # how many seats are there in the system
ONBOARD=0 # if the onboard is connected
declare -a DISPLAY_XORGS # saves the display of the Xorg launched processes
declare -a ID_WINDOWS # saves the created window ids (used in window-acess.sh)
declare -a PID_FIND_DEVICES # saves the pid from the launched configuration processes

create_onboard_window () {
	# Checks if there is a device connected to the onboard card
	if [ "$(cat "/sys$(udevadm info /sys/class/drm/card0 | grep "P:" | cut -d " " -f2)/card0-VGA-1/status")" == "connected" ]; then
		# Runs Xorg and creates the window for the onboard card
		DISPLAY_XORGS[$WINDOW_COUNTER]=:$(($WINDOW_COUNTER+10))
		export DISPLAY=${DISPLAY_XORGS[$WINDOW_COUNTER]}

		Xorg ${DISPLAY_XORGS[$WINDOW_COUNTER]} &
		pid=$!

		# Guarantees the Xorg execution
		xdpyinfo -display ${DISPLAY_XORGS[$WINDOW_COUNTER]}
		EXIT_CODE=$?
		N_ATTEMPT=0
		while [[ $EXIT_CODE -ne 0 ]]; do
			sleep 0.5
			xdpyinfo -display ${DISPLAY_XORGS[$WINDOW_COUNTER]}
			EXIT_CODE=$?
			if ! kill -0 "${pid}" >/dev/null 2>&1; then
				Xorg ${DISPLAY_XORGS[$WINDOW_COUNTER]} &
				pid=$!
			fi

			if [[ $N_ATTEMPT -gt $MAX_ATTEMPTS ]]; then
				echo "[Error] Run Xorg ${DISPLAY_XORGS[$WINDOW_COUNTER]} failed."
				exit 1
	    fi

			N_ATTEMPT=$(($N_ATTEMPT+1))
		done

		$CREATE_WINDOW

		ONBOARD=1
	else
		WINDOW_ID_INIT=1
		WINDOW_COUNTER=1
	fi
}

create_secundarycard_windows () {
	# The fake_seat display needs to be exported to run the Xephyr that communicate with it
	export DISPLAY=$FAKE_DISPLAY

	for i in ${OUTPUTS[*]}; do
		# Display for each output
		DISPLAY_XORGS[$WINDOW_COUNTER]=:$((WINDOW_COUNTER+10))

		# Run Xephyr to type in this output
		Xephyr ${DISPLAY_XORGS[$WINDOW_COUNTER]} -output $i -noxv &
		pid=$!

		# Guarantees the Xephyr execution
		xdpyinfo -display ${DISPLAY_XORGS[$WINDOW_COUNTER]}
		EXIT_CODE=$?
		N_ATTEMPT=0
		while [[ $EXIT_CODE -ne 0 ]]; do
			sleep 0.5
			xdpyinfo -display ${DISPLAY_XORGS[$WINDOW_COUNTER]}
			EXIT_CODE=$?
			if ! kill -0 "${pid}" >/dev/null 2>&1; then
				Xephyr ${DISPLAY_XORGS[$WINDOW_COUNTER]} -output $i -noxv &
				pid=$!
			fi

			if [[ $N_ATTEMPT -gt $MAX_ATTEMPTS ]]; then
				echo "[Error] Run Xephyr ${DISPLAY_XORGS[$WINDOW_COUNTER]} failed."
				exit 1
	    fi

			N_ATTEMPT=$(($N_ATTEMPT+1))
		done

		# Export display and create a window to write on this output
		export DISPLAY=${DISPLAY_XORGS[$WINDOW_COUNTER]}

		$CREATE_WINDOW

		# Again: the fake_seat display needs to be exported
		export DISPLAY=$FAKE_DISPLAY
	done
}

configure_devices () {
	COUNT=0
	for WINDOW in `seq $WINDOW_ID_INIT $(($WINDOW_COUNTER-1))`; do
		$FIND_KEYBOARD $(($WINDOW+1)) &
		PID_FIND_DEVICES[$COUNT]=$!
		COUNT=$(($COUNT+1))

		$WRITE_WINDOW press_key $WINDOW
	done
}

kill_jobs () {
	if [[ -n "$(ls | grep lock)" ]]; then
		rm lock*
	fi

	if [[ -n "$(ls $MC3SL_DEVICES)" ]]; then
		rm -rf $MC3SL_DEVICES/
	fi

	rm -rf $MC3SL_DEVICES

	pkill -P $$
}

############ BEGIN ############

# Guarantees the fake-seat execution, used to access the secondary board
Xorg $FAKE_DISPLAY -seat $FAKE_SEAT -dpms -s 0 -nocursor &
pid=$!

xdpyinfo -display $FAKE_DISPLAY
EXIT_CODE=$?
N_ATTEMPT=0
while [[ $EXIT_CODE -ne 0 ]]; do
	sleep 0.5
	xdpyinfo -display $FAKE_DISPLAY
	EXIT_CODE=$?
	if ! kill -0 "${pid}" >/dev/null 2>&1; then
		Xorg $FAKE_DISPLAY -seat $FAKE_SEAT -dpms -s 0 -nocursor &
		pid=$!
	fi

	if [[ $N_ATTEMPT -gt $MAX_ATTEMPTS ]]; then
		echo "[Error] Run Xorg $FAKE_DISPLAY -seat $FAKE_SEAT failed."
		exit 1
	fi

	N_ATTEMPT=$(($N_ATTEMPT+1))
done

# If the onboard is connected, it creates a window to write on the screen
create_onboard_window

# Creates the necessary windows to write on the screen of each output of the secondary card
create_secundarycard_windows

# We'll use it to save a shortcut to devices that have already been paired
mkdir -p $MC3SL_DEVICES

# Run configuration script for each seat
configure_devices

# Wait until all seats are configured
N_SEATS_LISTED=$(($(loginctl list-seats | grep -c "seat-")+$ONBOARD))
CONFIGURED_SEATS=0
while [[ $CONFIGURED_SEATS -lt $N_SEATS_LISTED ]]; do
	wait -n ${PID_FIND_DEVICES[*]}
	EXIT_CODE=$?

	if [[ $EXIT_CODE -eq 0 ]]; then
		CONFIGURED_SEATS=$(($CONFIGURED_SEATS+1))
	else if [[ $EXIT_CODE -eq 2 ]]; then
		echo "[Error] Can not configure output: find-devices.sh failed."
		rm -f $MC3SL_CONF
		exit 1
	fi
	fi
done

# Move settings file created for lightdm folder
mv -f $MC3SL_CONF $LIGHTDM_CONF

# Cleans the system by killing all the processes and files it has created
kill_jobs


exit 0