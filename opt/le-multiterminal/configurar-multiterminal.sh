#!/bin/bash

cd ../../
# Copia arquivos do X para systemd
install -m 644 etc/systemd/system/xorg-daemon.s* /etc/systemd/system
# Copia configs de usb para o udev
install -m 644 etc/udev/rules.d/* /etc/udev/rules.d

# Cria diretorio
install -d /etc/X11/xorg.conf.d
# Copia configurações de monitores para xorg
install -m 644 etc/X11/xorg.conf.d/9[78]*.conf /etc/X11/xorg.conf.d

# Copia scripts para bin
# mapeia as portas usb para monitores
install -m 755 usr/local/bin/seat-attach-assistant /usr/local/bin
# Copia script que atualiza entradas no xorg para bin (explicado no arquivo)
install -m 755 usr/local/bin/update-xorg-conf /usr/local/bin
# Copia script para executar o X para bin
install -m 755 usr/local/bin/xorg-daemon /usr/local/bin
# Copia script do Xephyr para bin
install -m 755 usr/local/bin/xephyr-wrapper /usr/local/bin

# Cria diretorio e copia configs do lightdm
install -d /etc/xdg/lightdm/lightdm.conf.d
install -m 644 etc/xdg/lightdm/lightdm.conf.d/*.conf /etc/xdg/lightdm/lightdm.conf.d

# roda o script que atualiza as configs do xorg
update-xorg-conf "Silicon.Motion" /etc/X11/xorg.conf.d/98-proinfo-*.conf
# habilita e roda o xorg-daemon
systemctl enable xorg-daemon.socket
systemctl start xorg-daemon.socket

apt update
apt -y upgrade
apt -y install curl xserver-xorg-video-siliconmotion-hwe-16.04 compton numlockx xserver-xephyr-hwe-16.04

# Pede eventos ao kernel: "força" a identificação dos dispositivos na maquina
udevadm trigger
systemctl restart lightdm
