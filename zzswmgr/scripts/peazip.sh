#!/bin/bash

SWNAME=peazip
SWVER=9.7.1

# 注意安装顺序，后装者依赖前装者
DEB_PATH1=./downloads/${SWNAME}.tar.gz

DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}
app_dir=/opt/apps/${SWNAME}

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh

function sw_download() {
	tmpdns=`cd /exbin && droidexec ./vm_getHostByName.sh mirror.ghproxy.com`
	exit_if_fail $? "DNS解析失败"
	echo "$tmpdns" >> /etc/hosts

	case "${CURRENT_VM_ARCH}" in
		"arm64")
			swUrl="https://mirror.ghproxy.com/https://github.com/peazip/PeaZip/releases/download/${SWVER}/peazip_portable-${SWVER}.LINUX.GTK2.aarch64.tar.gz"
			download_file_axel "${DEB_PATH1}" "${swUrl}"
			exit_if_fail $? "下载失败，网址：${swUrl}"
		;;
		"amd64")
			swUrl="https://mirror.ghproxy.com/https://github.com/peazip/PeaZip/releases/download/${SWVER}/peazip_portable-${SWVER}.LINUX.GTK2.x86_64.tar.gz"
			download_file_axel "${DEB_PATH1}" "${swUrl}"
			exit_if_fail $? "下载失败，网址：${swUrl}"
		;;
		*) exit_unsupport ;;
	esac
}

function sw_install() {

	# mkdir ${ZZSWMGR_APPI_DIR}/alist
	mkdir -p ${app_dir}

	# apt-get install -y libasound2
	# exit_if_fail $? "依赖包安装失败"

	echo "正在解压. . ."
	tar -xzf ${DEB_PATH1} --overwrite -C ${app_dir} --strip-components 1
	exit_if_fail $? "安装失败，软件包：${DEB_PATH1}"

	if [ "${APP_LANGUAGE}_${APP_COUNTRY}" == "zh_CN" ]; then
		echo "正在将界面设置为中文简体"
		rm -rf ${app_dir}/res/share/lang/default.txt
		cd ${app_dir}/res/share/lang/ && ln -sf chs.txt default.txt
	fi

}

function sw_create_desktop_file() {
	echo "正在生成桌面文件"

	tmpfile=${DIR_DESKTOP_FILES}/${SWNAME}.desktop
	cat <<- EOF > ${tmpfile}
		[Desktop Entry]
		Name=${SWNAME}
		GenericName=${SWNAME}
		Exec=${app_dir}/peazip
		Terminal=false
		Type=Application
		Icon=${app_dir}/res/share/icons/peazipmac.png
	EOF
	cp2desktop ${tmpfile}

	# echo "正在生成启动脚本"
	# mv -f /usr/bin/${SWNAME} /usr/bin/${SWNAME}.bak
	# tmpfile=/usr/bin/${SWNAME}
	# cat <<- EOF > ${tmpfile}
	# 	#!/bin/bash
	# 	exec ${app_dir}/motrix --no-sandbox
	# EOF
	# exit_if_fail $? "启动脚本生成失败"
	# chmod 755 ${tmpfile}

	gxmessage -title "提示"     $'\n安装完成\n\n'  -center
}

if [ "${action}" == "卸载" ]; then
	# echo "暂不支持卸载"
	# exit 1
	rm -rf ${DEB_PATH1}

	rm -rf /usr/bin/${SWNAME}

	rm -rf /opt/apps/${SWNAME}

	rm2desktop ${SWNAME}.desktop

	apt-get clean
else
	sw_download
	sw_install
	sw_create_desktop_file
fi

