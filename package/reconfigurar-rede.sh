#!/bin/bash

install -m 644 systemd/cabeada.network /etc/systemd/network
install -m 644 systemd/*.pkla /etc/polkit-1/localauthority/50-local.d

install -m 644 autostart-disable-nm/*.desktop /home/freezetemplate/.config/autostart
chown -R freezetemplate:freezetemplate /home/freezetemplate/.config/autostart

if [ -n "${wifi_iface}" ]
then
    install -m 644 systemd/wifi.network /etc/systemd/network
    install -m 644 systemd/wpa_supplicant@.service /etc/systemd/system
    install -d /etc/wpa_supplicant
    install -m 644 systemd/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf
fi

systemctl stop NetworkManager
systemctl disable NetworkManager

systemctl stop networking
systemctl disable networking

systemctl enable systemd-networkd
systemctl enable systemd-networkd-wait-online
systemctl enable systemd-resolved

systemctl start systemd-networkd
systemctl start systemd-networkd-wait-online
systemctl start systemd-resolved

ln -sf /var/run/systemd/resolve/resolv.conf /etc/resolv.conf
