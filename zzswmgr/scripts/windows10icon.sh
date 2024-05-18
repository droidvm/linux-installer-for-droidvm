#!/bin/bash

: '

https://github.com/yeyushengfan258/We10X-icon-theme

'

SWNAME=windows10icon
DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}
SWVER=3.5.5

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh


function sw_download() {
	apt-get install -y git
	exit_if_fail $? "git安装失败"

	app_dir=/opt/apps/${SWNAME}
	swUrl=https://mirror.ghproxy.com/https://github.com/yeyushengfan258/We10X-icon-theme
	download_file3 "${app_dir}" "${swUrl}"
	exit_if_fail $? "下载失败，网址：${swUrl}"

	# case "${CURRENT_VM_ARCH}" in
	# 	"arm64")
	# 			app_dir=/opt/apps/${SWNAME}
	# 			swUrl=https://mirror.ghproxy.com/https://github.com/shlomif/PySolFC
	# 			download_file3 "${app_dir}" "${swUrl}"
	# 			exit_if_fail $? "下载失败，网址：${swUrl}"

	# 			;;
	# 	"amd64")
	# 			exit_unsupport
	# 			;;
	# 	*) exit_unsupport ;;
	# esac

}

function sw_install() {
	cd ${app_dir}
	chmod a+x *.sh
	./install.sh
	exit_if_fail $? "安装失败"
	cd ${ZZSWMGR_MAIN_DIR}
}

function sw_create_desktop_file() {
	gxmessage -title "提示"     $'\n安装已完成\n请依次点击：开始使用->显示设置->显示风格->修改图标样式 进行启用\n\n'  -center &
}

if [ "${action}" == "卸载" ]; then
	# echo "暂不支持卸载"
	# exit 1
	rm -rf ${app_dir}
else
	sw_download
	sw_install
	sw_create_desktop_file
fi
