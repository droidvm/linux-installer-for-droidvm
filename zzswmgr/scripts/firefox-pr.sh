#!/bin/bash

SWNAME=firefox-pr
# SWVER=3.2.5

# 注意安装顺序，后装者依赖前装者
DEB_PATH1=./downloads/${SWNAME}-${SWVER}.deb

DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh

function sw_download() {
	echo "此处不需下载"
	# case "${CURRENT_VM_ARCH}" in
	# 	"arm64")
	# 		swUrl="https://dldir1.qq.com/qqfile/qq/QQNT/d0154345/linuxqq_3.2.5-20811_arm64.deb"
	# 		download_file_axel "${DEB_PATH1}" "${swUrl}"
	# 		exit_if_fail $? "下载失败，网址：${swUrl}"
	# 	;;
	# 	"amd64")
	# 		swUrl="https://dldir1.qq.com/qqfile/qq/QQNT/d0154345/linuxqq_3.2.5-20811_amd64.deb"
	# 		download_file_axel "${DEB_PATH1}" "${swUrl}"
	# 		exit_if_fail $? "下载失败，网址：${swUrl}"
	# 	;;
	# 	*) exit_unsupport ;;
	# esac
}

function sw_install() {
	apt-get install -y python3-pip python3.11-venv libasound2
	exit_if_fail $? "依赖库安装失败"

	sudo -u ${ZZ_USER_NAME} python3 -m venv ${ZZSWMGR_MAIN_DIR}/ezapp/zzllq
	exit_if_fail $? "python工作环境目录初始化失败"

	sudo -u ${ZZ_USER_NAME} ${ZZSWMGR_MAIN_DIR}/ezapp/zzllq/bin/pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
	exit_if_fail $? "python工作环境的下载仓库配置失败"

	sudo -u ${ZZ_USER_NAME} ${ZZSWMGR_MAIN_DIR}/ezapp/zzllq/bin/pip install playwright
	if [ $? -ne 0 ]; then
		sudo -u ${ZZ_USER_NAME} ${ZZSWMGR_MAIN_DIR}/ezapp/zzllq/bin/pip install -i https://mirrors.aliyun.com/pypi/simple playwright
		exit_if_fail $? "python 模块 playwright 安装失败"
	fi

	sudo -u ${ZZ_USER_NAME} ${ZZSWMGR_MAIN_DIR}/ezapp/zzllq/bin/python -m playwright install firefox
	exit_if_fail $? "无法通过 playwright 安装 firefox! "

	dir_tmp=`ls -a /home/${ZZ_USER_NAME}/.cache/ms-playwright/|grep firefox|tail -n 1`

}

function sw_create_desktop_file() {

	# STARTUP_SCRIPT_FILE=${app_dir}/${SWNAME}
	STARTUP_SCRIPT_FILE=/usr/bin/${SWNAME}
	cat <<- EOF > ${STARTUP_SCRIPT_FILE}
		#!/bin/bash
		export MOZ_FAKE_NO_SANDBOX=1
		exec /home/${ZZ_USER_NAME}/.cache/ms-playwright/${dir_tmp}/firefox/firefox \$@
	EOF
	chmod a+x ${STARTUP_SCRIPT_FILE}
	# cp -f ${STARTUP_SCRIPT_FILE}  /usr/bin/

	echo "正在生成桌面文件"
	tmpfile=${DIR_DESKTOP_FILES}/${SWNAME}.desktop
	echo "[Desktop Entry]"					> ${tmpfile}
	echo "Encoding=UTF-8"					>>${tmpfile}
	echo "Version=0.9.4"					>>${tmpfile}
	echo "Name=firefox-爬虫版"				>>${tmpfile}
	echo "Exec=${SWNAME} www.baidu.com"		>>${tmpfile}
	echo "Terminal=false"					>>${tmpfile}
	echo "Type=Application"					>>${tmpfile}
	echo "StartupWMClass=firefox"			>>${tmpfile}
	echo "Categories=Network;"				>>${tmpfile}
	echo "Comment=firefox"					>>${tmpfile}
	echo "Icon=/home/${ZZ_USER_NAME}/.cache/ms-playwright/${dir_tmp}/firefox/browser/chrome/icons/default/default48.png"			>>${tmpfile}
	cp2desktop ${tmpfile}

	cat <<- EOF > /tmp/msg.txt

		安装完成.

	EOF
	gxmessage -title "提示" -file /tmp/msg.txt -center
	# gxmessage -title "提示"     $'\n安装完成\n\n'  -center
}

if [ "${action}" == "卸载" ]; then
	# echo "暂不支持卸载"
	# exit 1

	rm -rf ${ZZSWMGR_MAIN_DIR}/ezapp/zzllq
	rm -rf /home/${ZZ_USER_NAME}/.cache/ms-playwright
	rm2desktop ${SWNAME}.desktop
else
	sw_download
	sw_install
	sw_create_desktop_file
fi

