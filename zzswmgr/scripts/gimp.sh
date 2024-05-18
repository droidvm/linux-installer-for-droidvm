#!/bin/bash

SWNAME=gimp

action=$1
if [ "$action" == "" ]; then action=安装; fi

if [ "${action}" == "卸载" ]; then
	sudo apt-get remove -y ${SWNAME}
else
	sudo apt-get install -y ${SWNAME}
	cd /etc/gimp/2.0
	cp -f menurc.dpkg-new menurc

	echo "正在安装中文语言包"
	# sudo apt-get install -y language-pack-gnome-zh-hant	#繁体
	sudo apt-get install -y language-pack-gnome-zh-hans		#简体
fi
