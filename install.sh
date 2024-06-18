#!/bin/bash
#Minite
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
	read -p "Do you want to convert Debian 12 to Minite? (y/n) " yn
	case $yn in
	[Yy]*)
		apt update
		apt -y install sysvinit-core sysvinit-utils

		# Instalando repo de Loc-OS 23
		apt install -y loc-os-23-archive-keyring_23.12.11_all.deb
		echo "deb $MIRROR $CODENAME main" >$LIST
		apt update && apt -y upgrade

		# Bloqueando systemd
		touch /etc/apt/preferences.d/00systemd
		chmod 777 /etc/apt/preferences.d/00systemd
		echo "Package: *systemd*:any
Pin: origin *
Pin-Priority: -1" >/etc/apt/preferences.d/00systemd

		apt -y purge qemu-guest-agent
		apt -y install libeudev1
		rm -r /etc/systemd/user.conf
		apt -y purge *systemd*
		break
		# Finalizado
		;;
	[Nn]*)
		exit
		;;
	*)
		echo "Please, choose (Y)es or (N)o."
		;;
	esac
done
