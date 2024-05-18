#!/bin/bash

SWNAME=kdenlive
# SWVER=18.2.3

# 注意安装顺序，后装者依赖前装者
DEB_PATH1=./downloads/${SWNAME}-data.deb

DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh

function sw_download() {
	# app_dir=/opt/apps/${SWNAME}

	case "${CURRENT_VM_ARCH}" in
		"arm64")
			# https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/pool/universe/k/kdenlive/
			swUrl="https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/pool/universe/k/kdenlive/kdenlive-data_23.08.1-0ubuntu1_all.deb"
			download_file2 "${DEB_PATH1}" "${swUrl}"
			exit_if_fail $? "下载失败，网址：${swUrl}"
		;;
		"amd64")
			swUrl="https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/universe/k/kdenlive/kdenlive-data_23.08.1-0ubuntu1_all.deb"
			download_file2 "${DEB_PATH1}" "${swUrl}"
			exit_if_fail $? "下载失败，网址：${swUrl}"
		;;
		*) exit_unsupport ;;
	esac
}

function sw_install() {

	# apt-get install -y unzip
	# exit_if_fail $? "解压工具unzip安装失败"
	apt-get install -y software-properties-common
	exit_if_fail $? "依赖库安装失败"

	DEB_PATH=${DEB_PATH1}
	install_deb ${DEB_PATH}
	exit_if_fail $? "依赖库安装失败，软件包：${DEB_PATH}"

	add-apt-repository ppa:kdenlive/kdenlive-stable
	exit_if_fail $? "PPA仓库添加失败"

	apt-get install -y kdenlive
	exit_if_fail $? "安装失败"

}

function sw_create_desktop_file() {
	echo "正在生成桌面文件"
	# tmpfile=${DIR_DESKTOP_FILES}/${SWNAME}.desktop
	# echo "[Desktop Entry]"					> ${tmpfile}
	# echo "Encoding=UTF-8"					>>${tmpfile}
	# echo "Version=0.9.4"					>>${tmpfile}
	# echo "Name=QQ"							>>${tmpfile}
	# echo "Exec=/opt/QQ/qq --no-sandbox %U"	>>${tmpfile}
	# echo "Terminal=false"					>>${tmpfile}
	# echo "Type=Application"					>>${tmpfile}
	# echo "StartupWMClass=QQ"				>>${tmpfile}
	# echo "Categories=Network;"				>>${tmpfile}
	# echo "Comment=QQ"						>>${tmpfile}
	# echo "Icon=/usr/share/icons/hicolor/512x512/apps/qq.png"			>>${tmpfile}
	# cp2desktop ${tmpfile}

	# cat <<- EOF > /tmp/msg.txt

	# 	安装完成.

	# 	【警告】
	# 	proot虚拟系统中的权限是不完整的
	# 	请使用QQ小号、或者扫码登录QQ！

	# EOF
	# gxmessage -title "提示" -file /tmp/msg.txt -center
	# # gxmessage -title "提示"     $'\n安装完成\n\n'  -center
}

if [ "${action}" == "卸载" ]; then
	echo "暂不支持卸载"
	exit 1
else
	sw_download
	sw_install
	sw_create_desktop_file
fi

