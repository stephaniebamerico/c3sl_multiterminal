#!/bin/bash

if ! [ -d /boot/userful-rescue -a -f /boot/userful-rescue/userful-rescue-live-20160628-i386.iso ]
then
    cat << EOF

[ERRO] Userful Rescue Live não encontrado!
       Baixe a ISO do Userful Rescue Live no endereço

           https://drive.google.com/open?id=0B_0RrXAKZ1hbdnRvcGRuSFc2Nkk

       e salve-a na pasta /boot/userful-rescue.
       Depois disso, execute este script novamente.

EOF
    exit 1
fi

install -m 755 userful/42_userful-rescue /etc/grub.d
update-grub

install -m 644 systemd/userful-rescue-nextboot-* /etc/systemd/system
systemctl enable userful-rescue-nextboot-reboot.service
systemctl enable userful-rescue-nextboot-read-write.service
systemctl start userful-rescue-nextboot-read-write.service

cat << EOF

[AVISO] Agora você deve desligar o computador e ligá-lo novamente.
        O computador deve iniciar no Userful Rescue Live e reiniciar
        automaticamente de volta para este sistema.

        Uma vez concluído o processo, você pode reiniciar o computador
        sempre que necessário.

EOF
