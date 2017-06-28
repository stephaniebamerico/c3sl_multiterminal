#!/bin/bash

freeze_template_user="freezetemplate"
freeze_template_fullname="Modelo para Freeze"

# Cria grupo "freeze"
addgroup freeze
# Cria usuário "freezetemplate" no grupo "freeze", com login desabilitado
adduser --disabled-login --gecos "${freeze_template_fullname}" --shell /bin/bash ${freeze_template_user}
# senha "freeze"
echo "${freeze_template_user}:freeze" | chpasswd

# Cria aluno$i com senha aluno$i, com login desabilitado, no grupo "freeze"
for i in 0 1 2 3 4
do
    adduser --disabled-login --gecos "Aluno #${i}" --shell /bin/bash aluno${i}
    adduser aluno${i} freeze
    echo "aluno${i}:aluno${i}" | chpasswd
done

# Atualiza lista de pacotes e instala PAM (autenticação), bindfs (espelhar um diretorio, mas com permissoes diferentes) e python-gnomekeyring (gnome keyring: gerenciamento de chaves e senhas)
apt update
apt -y install libpam-mount bindfs python-gnomekeyring

# Cria diretorio
install -d /etc/xdg/lightdm/lightdm.conf.d
# Copia arquivo que desabilita o usuario convidado para o diretório, com permissões rw-r--r-- (uuugggooo)
install -m 644 lightdm/96-disable-guest.conf /etc/xdg/lightdm/lightdm.conf.d
# Copia script (Cria pastas para o OverlayFS) para sbin, com permissoes rwxr-xr-x
install -m 755 mount-wrapper /usr/local/sbin
# Copia script (limpa o sistema) para sbin
install -m 755 prepare-clonezilla /usr/local/sbin
# Copia arquivo (com configurações para montagem dos diretórios usando PAM e Overlay) para security
install -m 644 pam_mount.conf.xml /etc/security
# Copia arquivo com descrição e traduções para terminal
install -m 644 xubuntu/*.policy /usr/share/polkit-1/actions

# Copia script para bin (Explicado no proprio arquivo)
install -m 755 freeze-session-auto /usr/local/bin
# Cria diretorio
install -d /home/${freeze_template_user}/.config/autostart
# Copia config que executa o script freeze-session-auto para o autostart do freeze
install -m 644 autostart/freeze-session-auto.desktop /home/${freeze_template_user}/.config/autostart
# Copia config que "esconde" alguns programas
install -m 644 autostart-disable/*.desktop /home/${freeze_template_user}/.config/autostart

# Cria diretorio
install -d /home/${freeze_template_user}/.config/Thunar
# Copia config do xubuntu versao Thunar para o diretorio
install -m 644 xubuntu/uca.xml /home/${freeze_template_user}/.config/Thunar
# Altera o dono de toda a arvore sob /home/freezetemplate (VERIFICAR se o grupo esta correto (existe))
chown -R "${freeze_template_user}:${freeze_template_user}" /home/${freeze_template_user}

# Cria diretórios de usuario em /var/freeze-data/
mkdir -pm 0777 /var/freeze-data/{documents,pictures,music,videos}
