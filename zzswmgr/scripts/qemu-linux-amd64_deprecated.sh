#!/bin/bash


SWNAME=qemu-linux-amd64
DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh


function sw_download() {
	DEB_PATH=./downloads/${SWNAME}.zip
	app_dir=/opt/apps/${SWNAME}

	if [ "$action" == "重装" ]; then
		echo "正在删除之前下载的安装包"
		rm -rf ${DEB_PATH}
	fi

	# swUrl=${APP_URL_DLSERVER}/qemu-linux-amd64.zip
	swUrl=https://gitee.com/droidvm/build_mylinux/releases/download/v0.01/qemu-linux-amd64.zip
	download_file2 "${DEB_PATH}" "${swUrl}"
	exit_if_fail $? "下载失败，网址：${swUrl}"
}

function sw_install() {
	apt-get install -y unzip
	exit_if_fail $? "解压工具unzip安装失败"

	echo "正在解压. . ."
	mkdir -p ${app_dir} 2>/dev/null
	unzip -oq ${DEB_PATH} -d ${app_dir}
	exit_if_fail $? "安装失败，软件包：${DEB_PATH}"

	chmod 755 ${app_dir}/qemu-linux-amd64.sh

	apt-get install -y qemu-system-x86
	exit_if_fail $? "qemu-system安装失败"
}


function sw_create_desktop_file() {
	echo "正在生成桌面文件"
	tmpfile=${DIR_DESKTOP_FILES}/${SWNAME}.desktop
	echo "[Desktop Entry]"			> ${tmpfile}
	echo "Encoding=UTF-8"			>>${tmpfile}
	echo "Version=0.9.4"			>>${tmpfile}
	echo "Type=Application"			>>${tmpfile}
	echo "Terminal=true"			>>${tmpfile}
	echo "Name=小型linux"			>>${tmpfile}
	echo "Exec=${app_dir}/qemu-linux-amd64.sh %f"	>> ${tmpfile}
	cp2desktop ${tmpfile}
}

if [ "${action}" == "卸载" ]; then
	# echo "暂不支持卸载"
	# exit 1

	set -x	# echo on

	apt-get autopurge -y qemu-system-x86

	rm -rf ./downloads/${SWNAME}.zip

	rm -rf /opt/apps/${SWNAME}

	rm2desktop ${SWNAME}.desktop

	apt-get clean

	set +x	# echo off

else
	sw_download
	sw_install
	sw_create_desktop_file
fi
