#!/bin/bash

: '

https://github.com/indigo-dc/udocker


'

SWNAME=udocker
SWVER=1.3.16

# 注意安装顺序，后装者依赖前装者
DEB_PATH1=./downloads/${SWNAME}.tar.gz

DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}
app_dir=/opt/apps/${SWNAME}-${SWVER}

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh

function sw_download() {
	tmpdns=`cd /exbin && droidexec ./vm_getHostByName.sh mirror.ghproxy.com`
	exit_if_fail $? "DNS解析失败"
	echo "$tmpdns" >> /etc/hosts

	case "${CURRENT_VM_ARCH}" in
		"arm64")
			swUrl="https://mirror.ghproxy.com/https://github.com/indigo-dc/udocker/releases/download/1.3.16/udocker-1.3.16.tar.gz"
			download_file1 "${DEB_PATH1}" "${swUrl}"
			exit_if_fail $? "下载失败，网址：${swUrl}"
		;;
		"amd64")
			swUrl="https://mirror.ghproxy.com/https://github.com/indigo-dc/udocker/releases/download/1.3.16/udocker-1.3.16.tar.gz"
			download_file1 "${DEB_PATH1}" "${swUrl}"
			exit_if_fail $? "下载失败，网址：${swUrl}"
		;;
		*) exit_unsupport ;;
	esac
}

function sw_install() {

	# mkdir ${ZZSWMGR_APPI_DIR}/alist
	mkdir -p ${app_dir}

	echo "正在解压. . ."
	tar -xzf ${DEB_PATH1} --overwrite -C ${app_dir}/../
	exit_if_fail $? "安装失败，软件包：${DEB_PATH1}"

	# (cd /usr/bin && ln -sf python3 python)
}

function sw_create_desktop_file() {
	echo "正在生成桌面文件"

	# tmpfile=${DIR_DESKTOP_FILES}/${SWNAME}.desktop
	# cat <<- EOF > ${tmpfile}
	# 	[Desktop Entry]
	# 	Name=${SWNAME}
	# 	GenericName=${SWNAME}
	# 	Exec=${SWNAME}
	# 	Terminal=true
	# 	Type=Application
	# EOF
	# cp2desktop ${tmpfile}

	echo "正在生成启动程序"
	tmpfile=/usr/bin/${SWNAME}
	cat <<- EOF > ${tmpfile}
		#!/bin/bash
		export PATH=${app_dir}/udocker:$PATH
		exec ${SWNAME} \$@
	EOF
	chmod 755 ${tmpfile}

	gxmessage -title "提示"     $'\n安装完成\n\n'  -center &
}

if [ "${action}" == "卸载" ]; then
	# echo "暂不支持卸载"
	# exit 1
	rm -rf ${DEB_PATH1}

	rm -rf /usr/bin/${SWNAME}

	rm -rf ${app_dir}

	rm2desktop ${SWNAME}.desktop

	apt-get clean
else
	sw_download
	sw_install
	sw_create_desktop_file
fi

