#!/bin/bash

: '

https://www.jianshu.com/p/6d45af6d8966
https://www.bilibili.com/read/cv14624341/   # 在基于Debian系统的主机上安装及使用Klipper
https://gitee.com/mirrors_Gottox/octo4a/blob/master/scripts/setup-klipper.sh
https://gitee.com/miroky/klipper/blob/master/scripts/install-ubuntu-22.04.sh

'

SWNAME=HMCL
DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}
SWVER=3.5.5

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh


function sw_download() {
	case "${CURRENT_VM_ARCH}" in
		"arm64")

				which java >/dev/null 2>&1
				if [ $? -ne 0 ]; then
					echo ""				> /tmp/msg.txt
					echo "请先安装jdk21">>/tmp/msg.txt
					echo ""				>>/tmp/msg.txt
					gxmessage -title "提示" -file /tmp/msg.txt -center
					exit 1
				fi

				app_dir=/opt/apps/${SWNAME}
				DEB_PATH=${app_dir}/${SWNAME}-${SWVER}.jar
				mkdir -p ${app_dir} 2>/dev/null

				swUrl=${APP_URL_DLSERVER}/HMCL-${SWVER}.jar
				download_file2 "${DEB_PATH}" "${swUrl}"
				exit_if_fail $? "下载失败，网址：${swUrl}"

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
				echo ""
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
				rm2desktop hmcl.desktop
				rm -rf /usr/bin/hmcl3d

				STARTUP_SCRIPT_FILE=${app_dir}/hmcl3d
				cat <<- EOF > ${STARTUP_SCRIPT_FILE}
					#!/bin/bash
					export GALLIUM_DRIVER=virpipe
					export MESA_GL_VERSION_OVERRIDE=4.0
					exec java -jar ${DEB_PATH} \$@
				EOF
				chmod 755 ${STARTUP_SCRIPT_FILE}
				cp -f ${STARTUP_SCRIPT_FILE}  /usr/bin/

				echo "正在生成桌面文件"
				tmpfile=${DIR_DESKTOP_FILES}/hmcl.desktop
				echo "[Desktop Entry]"			> ${tmpfile}
				echo "Encoding=UTF-8"			>>${tmpfile}
				echo "Version=0.9.4"			>>${tmpfile}
				echo "Type=Application"			>>${tmpfile}
				echo "Name=HMCL"				>>${tmpfile}
				echo "Exec=java -jar ${DEB_PATH}"	>> ${tmpfile}
				cp2desktop ${tmpfile}

				tmpfile=${DIR_DESKTOP_FILES}/hmcl3d.desktop
				echo "[Desktop Entry]"			> ${tmpfile}
				echo "Encoding=UTF-8"			>>${tmpfile}
				echo "Version=0.9.4"			>>${tmpfile}
				echo "Type=Application"			>>${tmpfile}
				echo "Name=HMCL带加速"			>>${tmpfile}
				echo "Exec=hmcl3d"				>> ${tmpfile}
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
