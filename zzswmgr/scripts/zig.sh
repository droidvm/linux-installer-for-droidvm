#!/bin/bash

SWNAME=zig
DEB_PATH=./downloads/${SWNAME}.tar.xz
DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh

function sw_download() {
	case "${CURRENT_VM_ARCH}" in
		"arm64") swUrl=https://ziglang.org/builds/zig-linux-aarch64-0.11.0-dev.3910+689f3163a.tar.xz ;;
		"amd64") swUrl=https://ziglang.org/builds/zig-linux-x86_64-0.11.0-dev.3910+689f3163a.tar.xz ;;
		*) exit_unsupport ;;
	esac

	download_file2 "${DEB_PATH}" "${swUrl}"
	exit_if_fail $? "下载失败，网址：${swUrl}"
}

function sw_install() {
	apt-get install -y xz-utils
	exit_if_fail $? "解压工具xz安装失败"

	echo "正在解压. . ."
	tar -xJf ${DEB_PATH} --overwrite -C /opt/apps/
	exit_if_fail $? "安装失败，软件包：${DEB_PATH}"
}

function sw_create_desktop_file() {

	case "${CURRENT_VM_ARCH}" in
		"arm64")
			echo ""																			>> /etc/profile
			echo "export PATH=\$PATH:/opt/apps/zig-linux-aarch64-0.11.0-dev.3910+689f3163a"	>> /etc/profile
			;;
		"amd64")
			echo ""																			>> /etc/profile
			echo "export PATH=\$PATH:/opt/apps/zig-linux-x86_64-0.11.0-dev.3910+689f3163a"	>> /etc/profile
			;;
		*) exit_unsupport ;;
	esac
}

if [ "${action}" == "卸载" ]; then
	echo "暂不支持卸载"
	exit 1
else

	sw_download
	sw_install
	sw_create_desktop_file
fi
