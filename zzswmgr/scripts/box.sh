#!/bin/bash

SWNAME=box
DEB_PATH=./downloads/${SWNAME}.deb
DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh

function sw_download() {
	case "${CURRENT_VM_ARCH}" in
		"arm64") swUrl=${APP_URL_DLSERVER}/box.deb ;;
		*) exit_unsupport ;;
	esac

	download_file2 "${DEB_PATH}" "${swUrl}"
	exit_if_fail $? "下载失败，网址：${swUrl}"
}

function sw_install() {
	dpkg --add-architecture armhf
	exit_if_fail $? "依赖包安装失败"

	apt-get update
	exit_if_fail $? "依赖包安装失败"

	apt-get install -y libc6:armhf
	exit_if_fail $? "依赖包安装失败"

	install_deb ${DEB_PATH}
	exit_if_fail $? "安装失败，软件包：${DEB_PATH}"
}

function sw_create_desktop_file() {
	echo ""
	# gxmessage -title "提示" "安装已完成，但需要重启一次才能运行"  -center
}

if [ "${action}" == "卸载" ]; then
	# echo "暂不支持卸载"
	# exit 1

	set -x	# echo on

	apt-get autopurge -y box

	rm -rf ./downloads/${SWNAME}.deb

	# 移除armhf架构的包
	apt-get autopurge -y --allow-remove-essential `dpkg --get-selections | grep ":armhf" | awk '{print $1}'`

	# 移除armhf架构的软件仓库
	dpkg --remove-architecture armhf

	apt update

	apt-get clean

	set +x	# echo off

else

	sw_download
	sw_install
	sw_create_desktop_file
fi
