#!/bin/bash

# Copia arquivos do X para systemd
install -m 644 systemd/xorg-daemon.s* /etc/systemd/system
# Copia configs de usb para o udev
install -m 644 udev/* /etc/udev/rules.d

# Cria diretorio
install -d /etc/X11/xorg.conf.d
# Copia configurações de monitores para xorg
install -m 644 xorg/9[78]*.conf /etc/X11/xorg.conf.d

# Copia scripts para bin
# mapeia as portas usb para monitores
install -m 755 seat-attach-assistant /usr/local/bin
# Copia script que atualiza entradas no xorg para bin (explicado no arquivo)
install -m 755 update-xorg-conf /usr/local/bin
# Copia script para executar o X para bin
install -m 755 xorg-daemon /usr/local/bin
# Copia script do Xephyr para bin
install -m 755 xephyr-wrapper /usr/local/bin

# Cria diretorio e copia configs do lightdm
install -d /etc/xdg/lightdm/lightdm.conf.d
install -m 644 lightdm/*.conf /etc/xdg/lightdm/lightdm.conf.d

# roda o script que atualiza as configs do xorg
update-xorg-conf "Silicon.Motion" /etc/X11/xorg.conf.d/98-proinfo-*.conf
# habilita e roda o xorg-daemon
systemctl enable xorg-daemon.socket
systemctl start xorg-daemon.socket

# adiciona ppa (repositorio pessoal) do xephyr e instala x, numlock, xserver, xephyr, etc
apt-add-repository ppa:ubuntu-multiseat/xephyr
apt update
apt -y upgrade
apt -y --allow-downgrades install xserver-xorg-video-siliconmotion compton numlockx xserver-{common,xorg-core,xephyr}=2:1.18.3-1ubuntu2.3+multiseat0

# Coloca pacotes do xorg e xephyr em hold (nao muda a versao em atualizações)
for i in common xorg-core xephyr
do
    echo "xserver-$i hold" | dpkg --set-selections
    [ -x /usr/bin/aptitude ] && aptitude hold xserver-$i
done

# Pede eventos ao kernel: "força" a identificação dos dispositivos na maquina
udevadm trigger
systemctl restart lightdm
