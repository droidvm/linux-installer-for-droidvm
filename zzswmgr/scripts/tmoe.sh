#!/bin/bash

SWNAME=tmoe

DIR_DESKTOP_FILES=/usr/share/applications

action=$1
if [ "$action" == "" ]; then action=安装; fi

filename=${DIR_DESKTOP_FILES}/tmoe.desktop

if [ "${action}" == "卸载" ]; then
	# sudo apt-get remove -y ${SWNAME}
	rm -rf ${filename}
else
	# sudo apt-get install -y ${SWNAME}

	rm -rf ./downloads/tmoe_installer.sh
	curl -Lv gitee.com/mo2/linux/raw/master/debian.sh -o ./downloads/tmoe_installer.sh
	chmod 755 ./downloads/tmoe_installer.sh

	echo "[Desktop Entry]"								> ${filename}
	echo "Encoding=UTF-8"								>>${filename}
	echo "Version=0.9.4"								>>${filename}
	echo "Type=Application"								>>${filename}
	echo "Name=tmoe软件管理工具"						>>${filename}
	echo "Comment=tmoe可以为系统安装常用的软件"			>>${filename}
	echo "Exec=/usr/local/etc/tmoe-linux/git/share/old-version/share/app/manager"	>>${filename}
	echo "Terminal=true"								>>${filename}

	cp2desktop ${filename}

	lxterminal -e ./downloads/tmoe_installer.sh

	# /usr/local/etc/tmoe-linux/git/share/old-version/share/app/manager

fi
