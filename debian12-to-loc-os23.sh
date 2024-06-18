#!/bin/bash
# Creador: Nicolas Longardi <nico@locosporlinux.com>
# Script que transforma Debian 12 en Loc-OS 23.
#==============================================================\
# Variables
KERNEL=5.10.218-loc-os
MIRROR=http://br.loc-os.com
CODENAME=contutti
LIST=/etc/apt/sources.list.d/loc-os.list
# Arquitectura
if [ "$(uname -m)" == "x86_64" ]; then
BIT=64
else
BIT=32
fi
#==============================================================\
# Comprueba si es Debian 12
if ! grep -q '^VERSION_ID="12"' /etc/os-release; then
    echo "This isn't Debian 12 Bookworm, aborting!"
    sleep 2
    exit 0
fi
# Comienza el script
while true; do
    read -p "Do you want to convert Debian 12 to Loc-OS 23? (y/n) " yn
    case $yn in
        [Yy]* )
            apt update
            apt -y install sysvinit-core sysvinit-utils

            # Instalando repo de Loc-OS 23
            wget -O /tmp/loc-os-23-archive-keyring_23.12.11_all.deb $MIRROR/pool/main/l/loc-os-23-archive-keyring/loc-os-23-archive-keyring_23.12.11_all.deb
            apt install -y /tmp/loc-os-23-archive-keyring_23.12.11_all.deb
            rm /tmp/loc-os-23-archive-keyring_23.12.11_all.deb
            echo "deb $MIRROR $CODENAME main" > $LIST
            apt update && apt -y upgrade

            # Info de la distro

	    touch /etc/lsb-release
    	    chmod 777 /etc/lsb-release
echo "PRETTY_NAME='Loc-OS Linux 23'
DISTRIB_ID=Loc-OS
DISTRIB_RELEASE=23
DISTRIB_CODENAME='Con Tutti'
DISTRIB_DESCRIPTION='Loc-OS Linux 23'" > /etc/lsb-release
            # Bloqueando systemd
	    touch /etc/apt/preferences.d/00systemd
	    chmod 777 /etc/apt/preferences.d/00systemd
echo "Package: *systemd*:any
Pin: origin *
Pin-Priority: -1" > /etc/apt/preferences.d/00systemd
echo "Loc-OS Linux 23 \n \l" > /etc/issue

	# lpkgbuild y SysV init 3.09
	mkdir -p /opt/Loc-OS-LPKG/lpkgbuild/remove/
	touch /opt/Loc-OS-LPKG/lpkgbuild/remove/lpkgbuild-$BIT.list
	wget -O /sbin/lpkgbuild https://gitlab.com/loc-os_linux/lpkgbuild/-/raw/main/lpkgbuild
	chmod +x /sbin/lpkgbuild
	lpkgbuild update
	lpkgbuild install sysvinit-3.09
	rm /opt/Loc-OS-LPKG/lpkgbuild/remove/*
    touch /opt/Loc-OS-LPKG/installed-lpkg/Listinstalled-lpkg.list
	# Kernel loc-os
            while true; do
                read -p "Do you want to install Linux $KERNEL? (y/n) " yn
                case $yn in
                    [Yy]* )
                        apt -y install linux-image-$KERNEL linux-headers-$KERNEL
                        break;;
                    [Nn]* )
                        echo "Linux $KERNEL not installed!" && sleep 1
                        break;;
                    * )
                        echo "Please, choose (Y)es or (N)o.";;
                esac
            done

		apt -y purge apparmor qemu-guest-agent
		rm -r /etc/apparmor.d/
		apt -y install libeudev1

	    # Eliminar kernel de Debian
	   if [ -f /boot/vmlinuz-$KERNEL ]; then
	   apt purge linux-image-6.1* --autoremove
           update-grub
	   fi
            # Finalizado
	        rm -r /etc/systemd/
            sed -i '106s/'"Debian GNU\/Linux"'/'"Loc-OS 23"'/g' /boot/grub/grub.cfg
            wget https://gitlab.com/loc-os_linux/debian12-to-loc-os23/-/raw/main/lxde-finish.sh
            chmod +x lxde-finish.sh
            echo "To complete the installation, you need reboot and run "$(pwd)"/lxde-finish.sh"
            break;;
        [Nn]* )
            exit;;
        * )
            echo "Please, choose (Y)es or (N)o.";;
    esac
done
