#!/bin/bash

: '

https://www.jianshu.com/p/6d45af6d8966
https://www.bilibili.com/read/cv14624341/   # 在基于Debian系统的主机上安装及使用Klipper
https://gitee.com/mirrors_Gottox/octo4a/blob/master/scripts/setup-klipper.sh
https://gitee.com/miroky/klipper/blob/master/scripts/install-ubuntu-22.04.sh

'

SWNAME=klipperscreen
DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh

function sw_download() {
	case "${CURRENT_VM_ARCH}" in
		"arm64")

				if [ ! -d /opt/apps/klipper ] || [ ! -d /opt/apps/moonraker ]; then
					echo ""								> /tmp/msg.txt
					echo "请先安装klipper和moonraker"	>>/tmp/msg.txt
					echo ""								>>/tmp/msg.txt
					gxmessage -title "提示" -file /tmp/msg.txt -center
					exit 1
				fi

				apt-get install -y git
				exit_if_fail $? "解压工具unzip安装失败"

				DEB_PATH=./downloads/${SWNAME}.zip
				app_dir=/opt/apps/${SWNAME}

				if [ ! -d ${app_dir} ]; then
					swUrl=https://gitee.com/Neko-vecter/KlipperScreen
					download_file3 "${app_dir}" "${swUrl}"
					exit_if_fail $? "下载失败，网址：${swUrl}"
				fi

				;;
		"amd64")
				exit_unsupport
				;;
		*) exit_unsupport ;;
	esac

}

function sw_install() {
	case "${CURRENT_VM_ARCH}" in
		"arm64")
				# apt-get install -y unzip
				# exit_if_fail $? "解压工具unzip安装失败"

				apt_pkgs="python3-virtualenv virtualenv python3-distutils"
				apt_pkgs="${apt_pkgs} libgirepository1.0-dev gcc libcairo2-dev pkg-config python3-dev gir1.2-gtk-3.0"
				apt_pkgs="${apt_pkgs} librsvg2-common libopenjp2-7 wireless-tools libdbus-glib-1-dev autoconf"
				apt_pkgs="${apt_pkgs} gcc make socat"


				# echo "正在创建python vENV"
				# python3 -m venv ${app_dir}

				# echo "正在将vENV中的pip的下载仓库地址换成国内的"
				# ${app_dir}/bin/pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
				# exit_if_fail $? "pip仓库设置出错"

				# # echo "正在通过pip安装组件"
				# # ${app_dir}/bin/pip install webhooks


				# # download_file3 "${SRC_DIR}" "${swUrl}"
				# # exit_if_fail $? "下载失败，网址：${swUrl}"

				;;
		"amd64")
				exit_unsupport
				;;
		*) exit_unsupport ;;
	esac
}

function sw_create_desktop_file() {
	case "${CURRENT_VM_ARCH}" in
		"arm64")
			    # sudo cp -f ${app_dir}/styles/icon.svg  /usr/share/icons/hicolor/scalable/apps/KlipperScreen.svg
				# cp -f ${app_dir}/ks_includes/defaults.conf /mnt/printer_data/config/KlipperScreen.conf

				rm2desktop KlipperScreen.desktop
				rm -rf /usr/share/applications/KlipperScreen.desktop

				# tmpfile=${DIR_DESKTOP_FILES}/KlipperScreen.desktop
				# cp -f ${app_dir}/scripts/KlipperScreen.desktop ${tmpfile}
				echo "正在生成桌面文件"
				tmpfile=${DIR_DESKTOP_FILES}/KlipperScreen.desktop
				cat <<- EOF > ${tmpfile}
					[Desktop Entry]
					Name=KlipperScreen
					GenericName=Touch screen GUI for Klipper via Moonraker
					Icon=${app_dir}/styles/icon.svg
					Exec=python3 ${app_dir}/screen.py
					Terminal=false
					Type=Application
					Categories=Graphics;3DGraphics;Engineering;
					Keywords=3D;Printing
					StartupNotify=false
					StartupWMClass=klipper-screen
				EOF
				cp2desktop ${tmpfile}

				echo "安装已完成"
				gxmessage -title "提示" "安装已完成"  -center
				;;
		"amd64")
				exit_unsupport
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
