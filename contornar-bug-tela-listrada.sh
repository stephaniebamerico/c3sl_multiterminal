#!/bin/bash

indice=0
particao=
le5_encontrado=false

encontrar_le5() {
    while read -r linha
    do
        if echo "${linha}" | grep "menuentry.*Linux Educacional 5.0" >/dev/null
        then
            particao=$(echo ${linha} | cut -d' ' -f7 | cut -d')' -f1)
            le5_encontrado=true
            break
        else
            indice=$(( indice + 1 ))
        fi
    done < <(grep "^menuentry\|submenu" /boot/grub/grub.cfg)
}

encontrar_le5

if ! ${le5_encontrado}
then
    # Partição do LE 5.0 não detectada.
    # Atualizando o menu do GRUB e tentando novamente...
    indice=0
    update-grub
    encontrar_le5
fi

if ! ${le5_encontrado}
then
    echo
    echo "[ERRO] Partição do Linux Educacional 5.0 não detectada!"
    echo "       Certifique-se de que o Linux Educacional 5.0"
    echo "       está instalado em uma outra partição."
    exit 1
fi

echo
echo "[INFO] Partição do Linux Educacional 5.0 encontrada em ${particao}."
echo "       Índice correspondente no menu do GRUB: ${indice}."

install -m 644 systemd/le-nextboot-* /etc/systemd/system

cat > /etc/le-nextboot.conf << EOF
LE_NEXTBOOT_ENABLE=true
LE_NEXTBOOT_INDEX=${indice}
EOF

systemctl enable le-nextboot-poweroff.service
grub-reboot ${indice}

mount ${particao} /mnt
install -m 644 userful/auto_login.conf /mnt/etc/userful
install -m 755 userful/auto-reboot /mnt/usr/local/bin
umount /mnt

echo
echo "[AVISO] Agora você deve desligar o computador e ligá-lo novamente."
echo "        O computador deve iniciar no Linux Educacional 5.0 e reiniciar"
echo "        automaticamente de volta para este sistema."
echo
echo "        Uma vez concluído o processo, você pode reiniciar o computador"
echo "        sempre que necessário."
