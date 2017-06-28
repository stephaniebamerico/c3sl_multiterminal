#!/bin/bash

freeze_template_user="freezetemplate"
freeze_template_fullname="Modelo para Freeze"

addgroup freeze
adduser --disabled-login --gecos "${freeze_template_fullname}" --shell /bin/bash ${freeze_template_user}
echo "${freeze_template_user}:freeze" | chpasswd

for i in 0 1 2 3 4
do
    adduser --disabled-login --gecos "Aluno #${i}" --shell /bin/bash aluno${i}
    adduser aluno${i} freeze
    echo "aluno${i}:aluno${i}" | chpasswd
done

apt update
apt -y install libpam-mount bindfs python-gnomekeyring

install -d /etc/xdg/lightdm/lightdm.conf.d
install -m 644 lightdm/96-disable-guest.conf /etc/xdg/lightdm/lightdm.conf.d
install -m 755 mount-wrapper /usr/local/sbin
install -m 755 prepare-clonezilla /usr/local/sbin
install -m 644 pam_mount.conf.xml /etc/security
install -m 644 lubuntu/*.policy /usr/share/polkit-1/actions

install -d /usr/local/share/file-manager/actions
install -m 644 lubuntu/*.desktop /usr/local/share/file-manager/actions
install -m 755 lubuntu/*-pkexec /usr/local/bin

install -m 755 freeze-session-auto /usr/local/bin
install -d /home/${freeze_template_user}/.config/autostart
install -m 644 autostart/freeze-session-auto.desktop /home/${freeze_template_user}/.config/autostart
install -m 644 autostart-disable/*.desktop /home/${freeze_template_user}/.config/autostart

chown -R freezetemplate:freezetemplate /home/freezetemplate

mkdir -pm 0777 /var/freeze-data/{documents,pictures,music,videos}
