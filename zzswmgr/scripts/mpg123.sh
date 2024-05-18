#!/bin/bash

SWNAME=mpg123
DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh

if [ "${action}" == "卸载" ]; then
	sudo apt-get remove -y ${SWNAME}
else
	# 下载演示音频
	DEB_PATH=./downloads/test.mp3
	swUrl=${APP_URL_DLSERVER}/test.mp3
	download_file2 "${DEB_PATH}" "${swUrl}"
	exit_if_fail $? "下载失败，网址：${swUrl}"

	cp -f ${DEB_PATH} /home/${ZZ_USER_NAME}/
	chmod a+r /home/${ZZ_USER_NAME}/test.mp3

	cat <<- EOF > /usr/bin/sndtest
		#!/bin/bash
		mpg123 ~/test.mp3
		echo ""
		echo "rescode: \$?"
		read -s -n1 -p "按任意键退出"
	EOF
	chmod a+x /usr/bin/sndtest

	echo "正在生成桌面文件"
	tmpfile=${DIR_DESKTOP_FILES}/sndtest.desktop
	echo "[Desktop Entry]"			> ${tmpfile}
	echo "Encoding=UTF-8"			>>${tmpfile}
	echo "Version=0.9.4"			>>${tmpfile}
	echo "Type=Application"			>>${tmpfile}
	echo "Terminal=true"			>>${tmpfile}
	echo "Name=声音测试"			>>${tmpfile}
	echo "Exec=sndtest"				>>${tmpfile}
	cp2desktop ${tmpfile}

	sudo apt-get install -y ${SWNAME}
fi
