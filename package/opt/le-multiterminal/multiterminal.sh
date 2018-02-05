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

#### Description: A wrapper for the multiterminal configurator. 
#### Checks the need to reconfigure / configure the multi-terminal and restarts the system.
#### Written by: Thiago Abdo - tja14@c3sl.ufpr.br on 2017.

set -x
####LOGFILE
if test ! -d /var/log/le-multiterminal; then
    mkdir -p /var/log/le-multiterminal
fi

CONFIG_FLAG=0

if test ! -e /etc/le-multiterminal/configurado; then
    touch /etc/le-multiterminal/configurado
    CONFIG_FLAG=1
fi

if test $CONFIG_FLAG -eq 1; then
    /opt/le-multiterminal/multiseat-controller.sh >> /var/log/le-multiterminal/controller.log 2>&1
    reboot
fi
