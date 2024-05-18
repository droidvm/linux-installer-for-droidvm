#!/bin/bash

SWNAME=fakesystemd
DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh

function sw_install() {
	cp -Rf ./ezapp/systemctl/systemctl.sh /usr/bin/systemctl
	exit_if_fail $? "安装失败，无法复制文件到 /usr/bin/"

	chmod 755 /usr/bin/systemctl
	exit_if_fail $? "安装失败，无法添加可执行权限"

	ln -f -s /exbin/busybox /usr/bin/start-stop-daemon
	exit_if_fail $? "安装失败，无法创建 /usr/bin/start-stop-daemon"

	ln -f -s /exbin/busybox /sbin/start-stop-daemon
	exit_if_fail $? "安装失败，无法创建 /sbin/start-stop-daemon"


}

function sw_create_desktop_file() {
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
