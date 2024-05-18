#!/bin/bash

SWNAME=qq
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
			swUrl="https://dldir1.qq.com/qqfile/qq/QQNT/d0154345/linuxqq_3.2.5-20811_arm64.deb"
			download_file_axel "${DEB_PATH1}" "${swUrl}"
			exit_if_fail $? "下载失败，网址：${swUrl}"
		;;
		"amd64")
			swUrl="https://dldir1.qq.com/qqfile/qq/QQNT/d0154345/linuxqq_3.2.5-20811_amd64.deb"
			download_file_axel "${DEB_PATH1}" "${swUrl}"
			exit_if_fail $? "下载失败，网址：${swUrl}"
		;;
		*) exit_unsupport ;;
	esac
}

function sw_install() {

	apt-get install -y libasound2
	exit_if_fail $? "依赖库安装失败"

	# if [ ! -e "/usr/share/doc/libva2/copyright" ]; then
	# 	apt-get install -y libva2
	# 	exit_if_fail $? "依赖包安装失败"
	# fi

	# DEB_PATH=${DEB_PATH1}
	# install_deb ${DEB_PATH}
	# exit_if_fail $? "安装失败，软件包：${DEB_PATH}"

	# DEB_PATH=${DEB_PATH2}
	# install_deb ${DEB_PATH}
	# exit_if_fail $? "安装失败，软件包：${DEB_PATH}"

	# DEB_PATH=${DEB_PATH3}
	# install_deb ${DEB_PATH}

	install_deb ${DEB_PATH1} ${DEB_PATH2} ${DEB_PATH3}
	install_deb ${DEB_PATH1}
	exit_if_fail $? "安装失败，软件包：${DEB_PATH1}"

	# apt-get --fix-broken install -y
	# exit_if_fail $? "安装失败"

	# rm -rf ${DIR_DESKTOP_FILES}/chromium-browser.desktop

}

function sw_create_desktop_file() {
	echo "正在生成桌面文件"
	tmpfile=${DIR_DESKTOP_FILES}/${SWNAME}.desktop
	echo "[Desktop Entry]"					> ${tmpfile}
	echo "Encoding=UTF-8"					>>${tmpfile}
	echo "Version=0.9.4"					>>${tmpfile}
	echo "Name=QQ"							>>${tmpfile}
	echo "Exec=/opt/QQ/qq --no-sandbox %U"	>>${tmpfile}
	echo "Terminal=false"					>>${tmpfile}
	echo "Type=Application"					>>${tmpfile}
	echo "StartupWMClass=QQ"				>>${tmpfile}
	echo "Categories=Network;"				>>${tmpfile}
	echo "Comment=QQ"						>>${tmpfile}
	echo "Icon=/usr/share/icons/hicolor/512x512/apps/qq.png"			>>${tmpfile}
	cp2desktop ${tmpfile}

	cat <<- EOF > /tmp/msg.txt

		安装完成.

		【警告】
		proot虚拟系统中的权限是不完整的
		请使用QQ小号、或者扫码登录QQ！

	EOF
	gxmessage -title "提示" -file /tmp/msg.txt -center
	# gxmessage -title "提示"     $'\n安装完成\n\n'  -center
}

if [ "${action}" == "卸载" ]; then
	# echo "暂不支持卸载"
	# exit 1
	

	pkgname2rm=linuxqq
	echo "正在 dpkg --remove --force-remove-reinstreq ${pkgname2rm}"
	dpkg --remove --force-remove-reinstreq ${pkgname2rm}
	exit_if_fail $? "force-remove-reinstreq 失败"

	echo "正在 apt-get purge ${pkgname2rm} -y"
	apt-get purge ${pkgname2rm} -y

	rm -rf ${app_dir} ${DIR_DESKTOP_FILES}/${SWNAME}.desktop
	rm2desktop ${SWNAME}.desktop
else
	sw_download
	sw_install
	sw_create_desktop_file
fi

