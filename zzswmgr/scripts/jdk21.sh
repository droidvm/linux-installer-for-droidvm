#!/bin/bash

: '


'

SWNAME=jdk21
DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh


function sw_download() {

	# echo "23.36.48.85	download.oracle.com" >> /etc/hosts
	tmpdns=`cd /exbin && droidexec ./vm_getHostByName.sh download.oracle.com`
	exit_if_fail $? "DNS解析失败"
	echo "$tmpdns" >> /etc/hosts

	DEB_PATH=./downloads/${SWNAME}.tar.gz

	case "${CURRENT_VM_ARCH}" in
		"arm64")
				swUrl=https://download.oracle.com/java/21/latest/jdk-21_linux-aarch64_bin.tar.gz
				download_file_axel "${DEB_PATH}" "${swUrl}"
				exit_if_fail $? "下载失败，网址：${swUrl}"
				;;
		"amd64")
				swUrl=https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.tar.gz
				download_file_axel "${DEB_PATH}" "${swUrl}"
				exit_if_fail $? "下载失败，网址：${swUrl}"
				;;
		*) exit_unsupport ;;
	esac

}

function sw_install() {
	case "${CURRENT_VM_ARCH}" in
		"arm64")
				echo "正在解压. . ."
				tar -zxvf ${DEB_PATH} -C /opt/apps/
				exit_if_fail $? "安装失败，软件包：${DEB_PATH}"

				;;
		"amd64")
				echo "正在解压. . ."
				tar -zxvf ${DEB_PATH} -C /opt/apps/
				exit_if_fail $? "安装失败，软件包：${DEB_PATH}"
				;;
		*) exit_unsupport ;;
	esac
}

function sw_create_desktop_file() {

	dir_tmp=`ls -a /opt/apps/|grep jdk-|tail -n 1`
	app_dir=/opt/apps/${dir_tmp}

	cat <<- EOF >> /etc/autoruns/installed_sw_env.sh

		export JAVA_HOME=${app_dir}
		export CLASSPATH=\$JAVA_HOME/lib

		JAVA_BINDIR=\${JAVA_HOME}/bin
		if [[ \$PATH != *\${JAVA_BINDIR}* ]]
		then
			export PATH=\$PATH:\${JAVA_BINDIR}
		fi
	EOF

	echo "安装已完成"
	gxmessage -title "提示" "安装完成，请重启一次以使 JAVA 环境变量生效"  -center
}

if [ "${action}" == "卸载" ]; then
	echo "暂不支持卸载"
	exit 1
else
	sw_download
	sw_install
	sw_create_desktop_file
fi
