#!/bin/bash

SWNAME=bilibili
SWVER=1.1.0-12

# 注意安装顺序，后装者依赖前装者
DEB_PATH1=./downloads/${SWNAME}-${SWVER}.deb

DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh


function sw_download() {
	app_dir=/opt/apps/${SWNAME}-${SWVER}
	
	if [ ! -x /opt/apps/electron-18.2.3/electron ]; then
		echo ""							> /tmp/msg.txt
		echo "请先安装上面的 electron"	>>/tmp/msg.txt
		echo ""							>>/tmp/msg.txt
		gxmessage -title "提示" -file /tmp/msg.txt -center
		exit 1
	fi

	case "${CURRENT_VM_ARCH}" in
		"arm64")
			swUrl=${APP_URL_DLSERVER}/bilibili.zip
			download_file2 "${DEB_PATH1}" "${swUrl}"
			exit_if_fail $? "下载失败，网址：${swUrl}"
		;;
		"amd64")
			swUrl=${APP_URL_DLSERVER}/bilibili.zip
			download_file2 "${DEB_PATH1}" "${swUrl}"
			exit_if_fail $? "下载失败，网址：${swUrl}"
		;;
		*) exit_unsupport ;;
	esac
}

function sw_install() {
	apt-get install -y unzip
	exit_if_fail $? "unzip安装失败"

	mkdir -p ${app_dir} 2>/dev/null
	exit_if_fail $? "无法创建目录: ${app_dir}"

	unzip -oq ${DEB_PATH1} -d ${app_dir}
	exit_if_fail $? "安装失败，软件包：${DEB_PATH1}"


}

function sw_create_desktop_file() {

	echo "正在生成启动脚本"
	STARTUP_SCRIPT_FILE=${app_dir}/${SWNAME}
	cat <<- EOF > ${STARTUP_SCRIPT_FILE}
		#!/bin/bash
		export ELECTRON_IS_DEV=0
		export ELECTRON_FORCE_IS_PACKAGED=true
		/opt/apps/electron-18.2.3/electron ${app_dir}/resources/app.asar --no-sandbox \$@ >/dev/null 2>&1
		# /opt/apps/electron-18.2.3/electron --no-sandbox
		# rescode=\$?
		# echo "\$rescode"> /tmp/elrlt.txt
		# echo "\$@"      >>/tmp/elrlt.txt
		# case "\$rescode" in
		# 0) ;;
		# *) /opt/apps/electron-18.2.3/electron ${app_dir}/resources/app.asar --no-sandbox \$@ ;;
		# esac
	EOF
	chmod 755 ${STARTUP_SCRIPT_FILE}
	cp -f ${STARTUP_SCRIPT_FILE}  /usr/bin/

	STARTUP_SCRIPT_FILE=${app_dir}/${SWNAME}-virgl
	cat <<- EOF > ${STARTUP_SCRIPT_FILE}
		#!/bin/bash
		export GALLIUM_DRIVER=virpipe
		export MESA_GL_VERSION_OVERRIDE=4.0
		export ELECTRON_IS_DEV=0
		export ELECTRON_FORCE_IS_PACKAGED=true
		/opt/apps/electron-18.2.3/electron ${app_dir}/resources/app.asar --no-sandbox \$@ >/dev/null 2>&1
	EOF
	chmod 755 ${STARTUP_SCRIPT_FILE}
	cp -f ${STARTUP_SCRIPT_FILE}  /usr/bin/

	echo "正在生成桌面文件"
	tmpfile=${DIR_DESKTOP_FILES}/${SWNAME}.desktop
	cat <<- EOF > ${tmpfile}
		[Desktop Entry]
		Encoding=UTF-8
		Version=0.9.4
		Name=Bilibili
		Name[zh_CN]=哔哩哔哩
		Name[zh_TW]=嗶哩嗶哩
		Name[zh_HK]=嗶哩嗶哩
		Exec=${app_dir}/bilibili %U
		# Terminal=true
		Type=Application
		Icon=${app_dir}/imgs/bilibili.png
		StartupWMClass=bilibili
		Comment=Bilibili PC Client
		Comment[zh_CN]=哔哩哔哩 PC 客户端
		Comment[zh_TW]=嗶哩嗶哩 PC 用戶端
		Comment[zh_HK]=嗶哩嗶哩 PC 客戶端
		Categories=AudioVideo;
		StartupNotify=true
	EOF
	cp2desktop ${tmpfile}

	tmpfile=${DIR_DESKTOP_FILES}/${SWNAME}-virgl.desktop
	cat <<- EOF > ${tmpfile}
		[Desktop Entry]
		Encoding=UTF-8
		Version=0.9.4
		Name=Bilibili
		Name[zh_CN]=哔哩哔哩3D
		Name[zh_TW]=嗶哩嗶哩3D
		Name[zh_HK]=嗶哩嗶哩3D
		Exec=${app_dir}/bilibili-virgl %U
		# Terminal=true
		Type=Application
		Icon=${app_dir}/imgs/bilibili.png
		StartupWMClass=bilibili
		Comment=Bilibili PC Client
		Comment[zh_CN]=哔哩哔哩 PC 客户端
		Comment[zh_TW]=嗶哩嗶哩 PC 用戶端
		Comment[zh_HK]=嗶哩嗶哩 PC 客戶端
		Categories=AudioVideo;
		StartupNotify=true
	EOF
	cp2desktop ${tmpfile}

	cat <<- EOF > /tmp/msg.txt

		安装完成.

		【警告】
		此软件非官方出品的原版客户端，
		如需登录，请使用小号登录！

	EOF
	gxmessage -title "提示" -file /tmp/msg.txt -center
	# gxmessage -title "提示"     $'\n安装完成\n\n'  -center
}

if [ "${action}" == "卸载" ]; then
	echo "暂不支持卸载"
	exit 1
else
	sw_download
	sw_install
	sw_create_desktop_file
fi

