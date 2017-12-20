#!/bin/bash

###
## Um wrapper para o configurador do multiterminal
## Ele verifica a necessidade de reconfigurar/configurar o multiterminal e reinicia o sistema
###

set -x
####LOGFILE
if [ ! -d /var/log/le-multiterminal ]; then
    mkdir -p /var/log/le-multiterminal
fi

CONFIG_FLAG=0

if [ ! -e /etc/le-multiterminal/configurado ]; then
    touch /etc/le-multiterminal/configurado
    CONFIG_FLAG=1
fi

if [ $CONFIG_FLAG -eq 1 ]; then
    /opt/le-multiterminal/multiseat-controller.sh >> /var/log/le-multiterminal/controller.log 2>&1
    reboot
fi
