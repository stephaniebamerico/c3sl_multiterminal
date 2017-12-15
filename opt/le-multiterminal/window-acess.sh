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

#### Description: Given a specific display, these functions create and write in a window.
#### There should already be an Xorg/Xephyr running in this display.
#### Written by: Stephanie Briere Americo - sba16@c3sl.inf.ufpr.br on 2017.

## Script/function in other file 
NEW_WINDOW="seat-parent-window" # it receives as parameter <RESOLUTION>x<X_Initial>+<Y_Inicial>
WRITE_MESSAGE="write-message" # it receives as parameter <ID_WINDOW> <Message>

create_window () {
	#### Description: Create a window in a specific display.
	#### ID_WINDOWS and WINDOW_COUNTER are declared in "multiseat-controller.sh".

	# Try to access Xorg
	xdpyinfo -display ${DISPLAY_XORGS[$WINDOW_COUNTER]}
	EXIT_CODE=$?
	while [[ $EXIT_CODE -ne 0 ]]; do 
		sleep 0.5
		xdpyinfo -display ${DISPLAY_XORGS[$WINDOW_COUNTER]}
		EXIT_CODE=$?
	done
	
	# Get screen resolution
	SCREEN_RESOLUTION=$(xdpyinfo -display ${DISPLAY_XORGS[$WINDOW_COUNTER]} | grep dimensions | sed -r 's/^[^0-9]*([0-9]+x[0-9]+).*$/\1/')

	# Creates a new window for writing on this output
	WINDOW_NAME=w$(($WINDOW_COUNTER+1))
	$NEW_WINDOW $SCREEN_RESOLUTION+0+0 $WINDOW_NAME &

	# Try to access the window
	xwininfo -name $WINDOW_NAME
	EXIT_CODE=$?
	while [[ $EXIT_CODE -ne 0 ]]; do 
		sleep 0.5
		xwininfo -name $WINDOW_NAME
		EXIT_CODE=$?
	done

	# Get the window id
	ID_WINDOWS[$WINDOW_COUNTER]=$(xwininfo -name $WINDOW_NAME | grep "Window id" | cut -d ' ' -f4)

	write_window wait_load $WINDOW_COUNTER
	
	# Increases the number of windows
	WINDOW_COUNTER=$(($WINDOW_COUNTER+1))
}

write_window() {
	#### Description: Writes in a specific window on a particular display.
	#### Parameters: $1 - message to be written; $2 - display to be used. 
	#### DISPLAY_XORGS and ID_WINDOWS are declared in "multiseat-controller.sh".
	
	export DISPLAY=${DISPLAY_XORGS[$2]}
	case $1 in
		ok) 
			$WRITE_MESSAGE ${ID_WINDOWS[$2]} "Monitor configurado, aguarde o restante ficar pronto" ;;
		wait_load) 
			$WRITE_MESSAGE ${ID_WINDOWS[$2]} "Aguarde" ;;
		press_key) 
			$WRITE_MESSAGE ${ID_WINDOWS[$2]} "Pressione a tecla F$(($2+1))" ;;
		press_mouse) 
			$WRITE_MESSAGE ${ID_WINDOWS[$2]} "Pressione o botão esquerdo do mouse" ;;
    esac
}