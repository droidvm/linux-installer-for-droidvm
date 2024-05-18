#!/bin/bash

: '

https://www.jianshu.com/p/6d45af6d8966
https://www.bilibili.com/read/cv14624341/   # 在基于Debian系统的主机上安装及使用Klipper
https://gitee.com/miroky/kiauh/blob/master/scripts/moonraker.sh
https://gitee.com/miroky/klipper/blob/master/scripts/install-ubuntu-22.04.sh


https://github.com/Arksine/moonraker/blob/master/docs/installation.md	# moonraker 官方文档
https://moonraker.readthedocs.io/en/latest/configuration/				# 如何配置 moonraker

'

SWNAME=moonraker
DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh

function sw_download() {
	case "${CURRENT_VM_ARCH}" in
		"arm64")

				if [ ! -d /opt/apps/klipper ]; then
					echo ""					> /tmp/msg.txt
					echo "请先安装klipper"	>>/tmp/msg.txt
					echo ""					>>/tmp/msg.txt
					gxmessage -title "提示" -file /tmp/msg.txt -center
					exit 1
				fi

				# apt-get install -y git
				# exit_if_fail $? "解压工具unzip安装失败"

				DEB_PATH=./downloads/${SWNAME}.zip
				app_dir=/opt/apps/${SWNAME}

				# # url get from https://gitee.com/mirrors_Gottox/octo4a/blob/master/scripts/setup-klipper.sh
				# swUrl=${APP_URL_DLSERVER}/klipper.zip
				# download_file2 "${DEB_PATH}" "${swUrl}"
				# exit_if_fail $? "下载失败，网址：${swUrl}"

				if [ ! -d ${app_dir} ]; then

					# 生成补丁包的代码，自己补齐路径
					# diff -Npur machine.py.old machine.py > tmp.patch

					swUrl=https://gitee.com/miroky/moonraker.git
					download_file3 "${app_dir}" "${swUrl}"
					exit_if_fail $? "下载失败，网址：${swUrl}"

					echo "正在修改moonraker源码，以支持在网页端修改配置文件"
					cd ${app_dir}
					patch -p1 < ${ZZSWMGR_MAIN_DIR}/scripts/res/moonraker-remark-disable_write_access.patch
					exit_if_fail $? "源码修改失败：${SWNAME}"
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
				apt-get install -y unzip
				exit_if_fail $? "解压工具unzip安装失败"

				# https://gitee.com/miroky/klipper/blob/master/scripts/install-ubuntu-22.04.sh
				apt_pkgs="build-essential python3 python3-pip git python3-greenlet python3-cffi"
				apt_pkgs="${apt_pkgs} python3-serial python3-jinja2 python3-websocket python3-requests"
				apt_pkgs="${apt_pkgs} python3-venv virtualenv python3-dev libffi-dev build-essential libncurses-dev"
				apt_pkgs="${apt_pkgs} libjpeg-dev zlib1g-dev"
				apt_pkgs="${apt_pkgs} python3-virtualenv python3-dev python3-libgpiod liblmdb-dev"
				apt_pkgs="${apt_pkgs} libopenjp2-7 libsodium-dev zlib1g-dev libjpeg-dev packagekit"
				apt-get install -y ${apt_pkgs}
				exit_if_fail $? "依赖库安装失败"

				# echo "正在解压. . ."
				# unzip -oq ${DEB_PATH} -d /opt/apps/
				# exit_if_fail $? "安装失败，软件包：${DEB_PATH}"
				# mv -f /opt/apps/klipper-master /opt/apps/klipper

				echo "正在将pip下载仓库地址换成国内的. . ."
				pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple


				echo "正在创建python vENV"
				python3 -m venv ${app_dir}

				echo "正在将vENV中的pip的下载仓库地址换成国内的"
				${app_dir}/bin/pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
				exit_if_fail $? "pip仓库设置出错"

				echo "正在通过pip安装组件"
				${app_dir}/bin/pip install tornado streaming_form_data dbus_next lmdb inotify_simple distro libnacl
				exit_if_fail $? "依赖库安装失败，请将手机网络切换到数据流量网络后重新安装！"


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
				rm2desktop moonraker.desktop
				rm -rf /usr/share/applications/moonraker.desktop
				rm -rf /usr/bin/moonraker

				echo "正在生成 moonraker 的 moonraker.conf => /mnt/printer_data/config/moonraker.conf"
				mkdir -p /mnt/printer_data/config
				chmod 766 -R /mnt/printer_data
				tmpdata="
				[server]
				host: 0.0.0.0
				port: 7125
				klippy_uds_address: /tmp/klippy.sock

				[authorization]
				trusted_clients:
					10.0.0.0/8
					127.0.0.0/8
					169.254.0.0/16
					172.16.0.0/12
					192.168.0.0/16
					FE80::/10
					::1/128
				cors_domains:
					http://*.lan
					http://*.local
					https://my.mainsail.xyz
					http://my.mainsail.xyz
					https://app.fluidd.xyz
					http://app.fluidd.xyz
				[octoprint_compat]

				[history]

				[machine]
					provider: none

				"
				echo "${tmpdata}" > ${app_dir}/moonraker.conf.base

				STARTUP_SCRIPT_FILE=${app_dir}/moonraker.sh
				cat <<- EOF > ${STARTUP_SCRIPT_FILE}
				#!/bin/bash
				sudo chmod 766 -R /mnt/printer_data
				exec ${app_dir}/bin/python3 /opt/apps/moonraker/moonraker/moonraker.py -d /mnt/printer_data "\$@"
				EOF
				chmod 755 ${STARTUP_SCRIPT_FILE}
				cp -f ${STARTUP_SCRIPT_FILE}  /usr/bin/moonraker

				# tmpfile=${DIR_DESKTOP_FILES}/moonraker.desktop
				# echo "[Desktop Entry]"	> ${tmpfile}
				# echo "Encoding=UTF-8"	>>${tmpfile}
				# echo "Version=0.9.4"	>>${tmpfile}
				# echo "Type=Application"	>>${tmpfile}
				# echo "Name=Klipper"		>>${tmpfile}
				# echo "Exec=${STARTUP_SCRIPT_FILE} %f"	>> ${tmpfile}
				# cp2desktop ${tmpfile}

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
