#!/bin/bash

SWNAME=build_mylinux
DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh

function sw_install() {
	app_dir=/opt/apps/${SWNAME}

	cp -Rf ./ezapp/build_mylinux /opt/apps/
	exit_if_fail $? "安装失败，无法复制文件到 /opt/apps/"

	chmod 755 ${app_dir}/*
}

function sw_create_desktop_file() {
	echo "[Desktop Entry]"								> ${DSK_PATH}
	echo "Encoding=UTF-8"								>>${DSK_PATH}
	echo "Version=0.9.4"								>>${DSK_PATH}
	echo "Type=Application"								>>${DSK_PATH}
	echo "Name=编译linux"								>>${DSK_PATH}
	echo "Comment=编译linux内核"						>>${DSK_PATH}
	echo "Exec=lxterminal -e ${app_dir}/build_mylinux.sh"	>> ${DSK_PATH}
	echo "Terminal=false"								>>${DSK_PATH}

	cp2desktop ${DSK_PATH}

	echo "安装已完成"
	gxmessage -title "提示" "安装已完成"  -center
}

if [ "${action}" == "卸载" ]; then
	echo "暂不支持卸载"
	exit 1
else
	# sw_download
	sw_install
	sw_create_desktop_file
fi
