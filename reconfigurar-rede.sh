#!/bin/bash

# Copia arquivo de rede cabeada para systemd
install -m 644 systemd/cabeada.network /etc/systemd/network
# Copia arquivo de hostname dinamico para polkit
install -m 644 systemd/*.pkla /etc/polkit-1/localauthority/50-local.d
# Copia arquivo que esconde o nm no autostart  (nm pode ser network-manager)
install -m 644 autostart-disable-nm/*.desktop /home/freezetemplate/.config/autostart

# Altera dono de toda a arvore sob ~freezetemplate/.config/autostart (VERIFICAR se existe o grupo)
chown -R freezetemplate:freezetemplate /home/freezetemplate/.config/autostart


# Configurações para wifi
if [ -n "${wifi_iface}" ]
then
    # configruação de rede wifi
    install -m 644 systemd/wifi.network /etc/systemd/network
    # serviço do sistema (via systemd)
    install -m 644 systemd/wpa_supplicant@.service /etc/systemd/system
    # cria diretorio
    install -d /etc/wpa_supplicant
    # Copia config do wpa_supplicant
    install -m 644 systemd/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf
fi

# desabilita network-manager
systemctl stop NetworkManager
systemctl disable NetworkManager

# desabilita serviço de "compatibilidade"
systemctl stop networking
systemctl disable networking

# habilita e inicia rede via systemd
systemctl enable systemd-networkd
systemctl enable systemd-networkd-wait-online
systemctl enable systemd-resolved

systemctl start systemd-networkd
systemctl start systemd-networkd-wait-online
systemctl start systemd-resolved

# faz link para arquivo de dns
ln -sf /var/run/systemd/resolve/resolv.conf /etc/resolv.conf
