#!/bin/bash


SWNAME=termux
DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh


function sw_download() {
	DEB_PATH=./downloads/${SWNAME}.tar.gz
	app_dir=/opt/apps/${SWNAME}

	# if [ "$action" == "重装" ]; then
	# 	echo "正在删除之前下载的安装包"
	# 	rm -rf ${DEB_PATH}
	# fi

	# swUrl=https://gitee.com/droidvm/build_mylinux/releases/download/v0.01/termux-rootfs-arm64.tar.gz
	swUrl=${APP_URL_DLSERVER}/termux-rootfs-arm64.tar.gz
	download_file_axel "${DEB_PATH}" "${swUrl}"
	exit_if_fail $? "下载失败，网址：${swUrl}"
}

function sw_install() {
	apt-get install -y unzip
	exit_if_fail $? "解压工具unzip安装失败"

	echo "正在解压. . ."
	mkdir -p ${app_dir} 2>/dev/null
	tar -xzf ${DEB_PATH} --overwrite -C ${app_dir}
	exit_if_fail $? "解压失败，软件包：${DEB_PATH}"
	# unzip -oq ${DEB_PATH} -d ${app_dir}
	# exit_if_fail $? "解压失败，软件包：${DEB_PATH}"

	mkdir -p ${app_dir}/appdata/com.termux/cache 2>/dev/null
	cd ${app_dir}/appdata/com.termux && ln -sf ${APP_INTERNAL_DIR}/vm/${CURRENT_OS_NAME}${app_dir} ./files
	cd ${app_dir}/appdata/com.termux && ln -sf ${APP_INTERNAL_DIR}/vm/${CURRENT_OS_NAME}${app_dir}/usr/bin ./bin

	# 更换软件仓库地址
	echo "deb https://mirrors.tuna.tsinghua.edu.cn/termux/apt/termux-main stable main" > ${app_dir}/usr/etc/apt/sources.list
	echo "deb https://mirrors.tuna.tsinghua.edu.cn/termux/apt/termux-x11 x11 main"     > ${app_dir}/usr/etc/apt/sources.list.d/x11.list

}


function sw_create_desktop_file() {

	cat <<- EOF > ${app_dir}/termux_init.sh
		#!/data/data/com.termux/files/usr/bin/bash
		export HOME=/data/data/com.termux/files/home
		cd ~
		clear
		export app_home=${APP_INTERNAL_DIR}
		export tools_dir=${APP_INTERNAL_DIR}/tools
		export CURRENT_OS_DIR=${APP_INTERNAL_DIR}/vm/${CURRENT_OS_NAME}
		export TERMUX_PREFIX=/data/data/com.termux/files
		export PREFIX=/data/data/com.termux/files/usr
		export LD_PRELOAD=/data/data/com.termux/files/usr/lib/libtermux-exec.so
		export PATH=/data/data/com.termux/files/usr/bin:/exbin
		export TERM=vt100
		export LANG=C.UTF-8
		. \${CURRENT_OS_DIR}${app_dir}/termux_xserver.sh
		ln -sf /exbin/tools/zzswmgr/ezapp/mobox-installer \${HOME}/mobox-installer
		chmod a+x \${HOME}/mobox-installer/*
		busybox telnetd -p 1025 -l \${CURRENT_OS_DIR}${app_dir}/usr/bin/bash
		exec \${CURRENT_OS_DIR}${app_dir}/usr/bin/bash

	EOF
	chmod a+x ${app_dir}/termux_init.sh

	cat <<- EOF > ${app_dir}/start_termux.sh
		#!/system/bin/sh
		export CONSOLE_ENV=android
		cd ${APP_INTERNAL_DIR}
		. ./tools/iproot.sh
		proot -r / -w /data/data/com.termux/files/home \\
		-b ${APP_INTERNAL_DIR}/vm/${CURRENT_OS_NAME}${app_dir}/appdata:/data/data \\
		-b ${APP_INTERNAL_DIR}:/exbin \\
		-b ./tmp:/data/data/com.termux/files/usr/tmp \\
		${APP_INTERNAL_DIR}/vm/${CURRENT_OS_NAME}${app_dir}/termux_init.sh

	EOF
	# -b ${APP_INTERNAL_DIR}/vm/${CURRENT_OS_NAME}/tmp:/data/data/com.termux/files/usr/tmp \\
	# -b ${APP_INTERNAL_DIR}/vm/${CURRENT_OS_NAME}${app_dir}/usr/bin:/bin
	chmod a+x ${app_dir}/start_termux.sh

	cat <<- EOF > /usr/bin/${SWNAME}
		#!/bin/bash
		cd ${app_dir}

		echo "export DISPLAY=\${DISPLAY}" > ${app_dir}/termux_xserver.sh

		ps ax|grep busybox|grep telnet|grep 1025 >/dev/null 2>/dev/null
		if [ \$? -ne 0 ]; then
			# exec droidexec ./start_termux.sh
			droidexec ./start_termux.sh &
		fi
		echo "欢迎在虚拟电脑中使用termux, 目前尚未支持 termux-api等扩展功能"
		echo "虚拟电脑中引入termux主要是供开发人员使用！"
		echo "termux官方网站：https://termux.dev/"
		echo ""
		echo -e "您也可以通过telnet连接本机的\e[96m1025\e[0m端口来使用termux"
		echo -e "\e[96m要安装 mobox, 请运行：./mobox-installer/setup.sh \e[0m"
		echo ""
		sleep 0.5
		exec telnet 127.0.0.1 1025
		# exec lxterminal -e /exbin/tools/vm_connect_android_consle_via_telnet.sh &

	EOF
	chmod a+x /usr/bin/${SWNAME}

	echo "正在生成桌面文件"
	tmpfile=${DIR_DESKTOP_FILES}/${SWNAME}.desktop
	echo "[Desktop Entry]"			> ${tmpfile}
	echo "Encoding=UTF-8"			>>${tmpfile}
	echo "Version=0.9.4"			>>${tmpfile}
	echo "Type=Application"			>>${tmpfile}
	echo "Terminal=true"			>>${tmpfile}
	echo "Name=${SWNAME}"			>>${tmpfile}
	echo "Exec=${SWNAME} %f"		>>${tmpfile}
	cp2desktop ${tmpfile}
}

if [ "${action}" == "卸载" ]; then
	# echo "暂不支持卸载"
	# exit 1

	set -x	# echo on

	# apt-get autopurge -y wine
	rm -rf /opt/apps/${SWNAME}

	rm -rf ./downloads/${SWNAME}.tar.gz
	
	rm2desktop ${SWNAME}.desktop
	rm -rf /usr/bin/${SWNAME}*

	apt-get clean

	set +x	# echo off

else
	sw_download
	sw_install
	sw_create_desktop_file
fi
