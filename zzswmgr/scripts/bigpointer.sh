#!/bin/bash

SWNAME=bigpointer
SWVER=3.2.5

# 注意安装顺序，后装者依赖前装者
DEB_PATH1=./downloads/${SWNAME}-${SWVER}.deb

DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh

function sw_download() {
	case "${CURRENT_VM_ARCH}" in
		"arm64")
			swUrl=${APP_URL_DLSERVER}/adwaita-icon-theme_43-1_all_form_debian_apt_repo.deb
			download_file_axel "${DEB_PATH1}" "${swUrl}"
			exit_if_fail $? "下载失败，网址：${swUrl}"
		;;
		"amd64")
			swUrl=${APP_URL_DLSERVER}/adwaita-icon-theme_43-1_all_form_debian_apt_repo.deb
			download_file_axel "${DEB_PATH1}" "${swUrl}"
			exit_if_fail $? "下载失败，网址：${swUrl}"
		;;
		*) exit_unsupport ;;
	esac
}

function sw_install() {
	apt-get install -y \
	${ZZSWMGR_MAIN_DIR}/downloads/${SWNAME}-${SWVER}.deb
	exit_if_fail $? "安装失败"
}

function sw_create_desktop_file() {
	cat <<- EOF > /tmp/msg.txt
		安装完成. 重启后生效。
	EOF
	gxmessage -title "提示" -file /tmp/msg.txt -center
}

if [ "${action}" == "卸载" ]; then
	echo "暂不支持卸载"
	exit 1
else
	sw_download
	sw_install
	sw_create_desktop_file
fi

