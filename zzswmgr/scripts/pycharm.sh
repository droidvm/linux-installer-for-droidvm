#!/bin/bash


SWNAME=pycharm
DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh


DEB_PATH=./downloads/${SWNAME}.tar.gz
app_dir=/opt/apps

function sw_download() {
	tmpdns=`cd /exbin && droidexec ./vm_getHostByName.sh download-cdn.jetbrains.com.cn`
	exit_if_fail $? "DNS解析失败"
	echo "$tmpdns" >> /etc/hosts

	# if [ "$action" == "重装" ]; then
	# 	echo "正在删除之前下载的安装包"
	# 	rm -rf ${DEB_PATH}
	# fi

	case "${CURRENT_VM_ARCH}" in
		"arm64")
			#swUrl=https://download-cdn.jetbrains.com.cn/python/pycharm-professional-2023.3.3-aarch64.tar.gz
			 swUrl=https://download-cdn.jetbrains.com.cn/python/pycharm-community-2023.3.4-aarch64.tar.gz
			;;
		"amd64")
			#swUrl=https://download-cdn.jetbrains.com.cn/python/pycharm-professional-2023.3.3.tar.gz
			 swUrl=https://download-cdn.jetbrains.com.cn/python/pycharm-community-2023.3.4.tar.gz
			;;
		*) exit_unsupport ;;
	esac
	
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

	dir_tmp=`ls -a ${app_dir}|grep pycharm|tail -n 1`

	app_dir=${app_dir}/${dir_tmp}

}


function sw_create_desktop_file() {

	echo "正在生成桌面文件"
	tmpfile=${DIR_DESKTOP_FILES}/${SWNAME}.desktop
	echo "[Desktop Entry]"			> ${tmpfile}
	echo "Encoding=UTF-8"			>>${tmpfile}
	echo "Version=0.9.4"			>>${tmpfile}
	echo "Type=Application"			>>${tmpfile}
	echo "Terminal=false"			>>${DSK_PATH}
	echo "Name=${SWNAME}"			>>${tmpfile}
	echo "Exec=${app_dir}/bin/pycharm.sh %f"	>> ${tmpfile}
	echo "Icon=${app_dir}/bin/pycharm.png"		>> ${tmpfile}
	cp2desktop ${tmpfile}
}

if [ "${action}" == "卸载" ]; then
	# echo "暂不支持卸载"
	# exit 1

	echo "正在删除之前下载的安装包"
	rm -rf ${DEB_PATH}

	echo "正在删除程序主目录"
	rm -rf ${app_dir}/pycharm*

	echo "正在删除桌面图标"
	tmpfile=${DIR_DESKTOP_FILES}/${SWNAME}.desktop
	rm2desktop ${tmpfile}

	gxmessage -title "提示" "卸载完成"  -center

else
	sw_download
	sw_install
	sw_create_desktop_file
fi
