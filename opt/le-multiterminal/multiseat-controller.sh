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
source find-devices.sh
source window-acess.sh

## Path constants
MC3SL_SCRIPTS=$(pwd) #/usr/sbin/ 
MC3SL_DEVICES=devices #/etc/mc3sl/devices/ 
MC3SL_LOGS=$(pwd) #/etc/mc3sl/logs/ 

## Script/function in other file 
DISCOVER_DEVICES="$MC3SL_SCRIPTS/discover-devices"
FIND_KEYBOARD="find_keyboard" # "find-devices.sh"
CREATE_WINDOW="create_window" # "window-acess.sh"
WRITE_WINDOW="write_window" # "window-acess.sh"

## Macros
FAKE_DISPLAY=:90 # display to access fake-seat (secondary card)
OUTPUTS=("LVDS" "VGA") # output options

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

	pkill -P $$
}

### TODO: Serviços que precisam rodar ANTES desse script 
systemctl stop lightdm
Xorg :90 -seat __fake-seat-1__ -dpms -s 0 -nocursor &
sleep 1
rm -f configuracao
### TO-DO end

############ BEGIN ############

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
    CONFIGURED_SEATS=$(($CONFIGURED_SEATS+1))
done

# Cleans the system by killing all the processes and files it has created
kill_jobs


exit 0
