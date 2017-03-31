#!/bin/bash

install -m 644 systemd/xorg-daemon.s* /etc/systemd/system
install -m 644 udev/* /etc/udev/rules.d

install -d /etc/X11/xorg.conf.d
install -m 644 xorg/9[78]*.conf /etc/X11/xorg.conf.d
install -m 755 seat-attach-assistant /usr/local/bin
install -m 755 update-xorg-conf /usr/local/bin
install -m 755 xorg-daemon /usr/local/bin
install -m 755 xephyr-wrapper /usr/local/bin

install -d /etc/xdg/lightdm/lightdm.conf.d
install -m 644 lightdm/*.conf /etc/xdg/lightdm/lightdm.conf.d

update-xorg-conf "Silicon.Motion" /etc/X11/xorg.conf.d/98-proinfo-*.conf
systemctl enable xorg-daemon.socket
systemctl start xorg-daemon.socket

apt-add-repository ppa:ubuntu-multiseat/xephyr
apt update
apt -y upgrade
apt -y --allow-downgrades install xserver-xorg-video-siliconmotion compton numlockx xserver-{common,xorg-core,xephyr}=2:1.18.3-1ubuntu2.3+multiseat0

for i in common xorg-core xephyr
do
    echo "xserver-$i hold" | dpkg --set-selections
    [ -x /usr/bin/aptitude ] && aptitude hold xserver-$i
done

udevadm trigger
systemctl restart lightdm