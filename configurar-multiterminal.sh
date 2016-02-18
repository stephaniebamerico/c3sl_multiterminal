#!/bin/bash

install -m 644 systemd/xorg@.s* /etc/systemd/system
install -m 644 udev/* /etc/udev/rules.d

install -d /etc/X11/xorg.conf.d
install -m 644 xorg/* /etc/X11/xorg.conf.d

install -d /etc/xdg/lightdm/lightdm.conf.d
install -m 644 lightdm/xephyr*.conf /etc/xdg/lightdm/lightdm.conf.d
install -m 644 lightdm/autologin.conf /etc/xdg/lightdm/lightdm.conf.d

install -m 755 xephyr-wrapper /usr/local/bin
ln -s xephyr-wrapper /usr/local/bin/xephyr-wrapper-0
ln -s xephyr-wrapper /usr/local/bin/xephyr-wrapper-1

systemctl enable xorg@90.socket
systemctl start xorg@90.socket

apt-add-repository ppa:ubuntu-multiseat/ppa
apt update
apt -y upgrade
apt -y install xserver-xorg-video-siliconmotion xserver-xephyr compton

udevadm trigger
systemctl restart lightdm
