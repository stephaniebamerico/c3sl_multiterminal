#!/bin/bash

PACOTES="
ubuntu-edu-preschool
ubuntu-edu-primary
ubuntu-edu-secondary
kde-l10n-ptbr
gparted
pinta
vlc
ktouch
openshot
dreamchess
gnome-chess
supertux
supertuxkart
pingus
chromium-browser
adobe-flashplugin
ssvnc
epoptes-client
ssh
nginx-light
wine
"

apt-add-repository ppa:oiteam/epoptes
apt update

OMNITUX="http://downloads.sourceforge.net/project/omnitux/omnitux/v1.2.1/omnitux_1.2.1_all.deb?r=http%3A%2F%2Fomnitux.sourceforge.net%2Fdownload.en.php&ts=1462984447&use_mirror=liquidtelecom"
wget -c $OMNITUX -O /tmp/omnitux_1.2.1_all.deb && apt install /tmp/omnitux_1.2.1_all.deb

apt install $PACOTES

install -m 644 tuxpaint.conf /etc/tuxpaint
