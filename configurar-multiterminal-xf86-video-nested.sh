#!/bin/bash

install -m 644 systemd/xorg-daemon.s* /etc/systemd/system
install -m 644 udev/* /etc/udev/rules.d

install -d /etc/X11/xorg.conf.d
install -m 644 xorg/*.conf /etc/X11/xorg.conf.d
install -m 755 seat-attach-assistant /usr/local/bin
install -m 755 update-xorg-conf /usr/local/bin
install -m 755 xorg-daemon /usr/local/bin

install -d /etc/xdg/lightdm/lightdm.conf.d
install -m 644 lightdm/9[5679]*.conf /etc/xdg/lightdm/lightdm.conf.d

update-xorg-conf "Silicon.Motion" /etc/X11/xorg.conf.d/98-proinfo-*.conf
systemctl enable xorg-daemon.socket
systemctl start xorg-daemon.socket

apt-add-repository ppa:ubuntu-multiseat/xf86-video-nested
apt update
apt -y upgrade
apt -y install xserver-xorg-video-siliconmotion xserver-xorg-video-nested compton numlockx

udevadm trigger
systemctl restart lightdm
