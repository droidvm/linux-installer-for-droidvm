#!/bin/bash

SWNAME=TencentDocs
SWVER=1.8.19

# 注意安装顺序，后装者依赖前装者
DEB_PATH1=./downloads/${SWNAME}.deb

DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=tdappdesktop.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}
# app_dir=/opt/Motrix

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh

function sw_download() {
	# tmpdns=`cd /exbin && droidexec ./vm_getHostByName.sh docs.qq.com`
	# exit_if_fail $? "DNS解析失败"
	# echo "$tmpdns" >> /etc/hosts

	case "${CURRENT_VM_ARCH}" in
		"arm64")
			swUrl="https://docs.qq.com/api/package/get?channel_id=30001&version_id=latest&package_name=TencentDocs-arm64.deb"
			download_file_axel "${DEB_PATH1}" "${swUrl}"
			exit_if_fail $? "下载失败，网址：${swUrl}"
		;;
		"amd64")
			swUrl="https://docs.qq.com/api/package/get?channel_id=30001&version_id=latest&package_name=TencentDocs-x64.deb"
			download_file_axel "${DEB_PATH1}" "${swUrl}"
			exit_if_fail $? "下载失败，网址：${swUrl}"
		;;
		*) exit_unsupport ;;
	esac
}

function sw_install() {

	# mkdir ${ZZSWMGR_APPI_DIR}/alist
	# mkdir -p ${app_dir}

	apt-get install -y libasound2
	exit_if_fail $? "依赖包安装失败"

	echo "正在安装. . ."
	install_deb ${DEB_PATH1}
	exit_if_fail $? "安装失败，软件包：${DEB_PATH1}"

}

function sw_create_desktop_file() {
	echo "正在生成桌面文件"


	sed -i 's|Exec="/opt/腾讯文档/tdappdesktop" %U|Exec="/opt/腾讯文档/tdappdesktop"  --no-sandbox %U|'    ${DSK_PATH}

	tmpfile=${DSK_PATH}
	cp2desktop ${tmpfile}

	# tmpfile=${DIR_DESKTOP_FILES}/${SWNAME}.desktop
	# cat <<- EOF > ${tmpfile}
	# 	[Desktop Entry]
	# 	Name=${SWNAME}
	# 	GenericName=${SWNAME}
	# 	Exec=${SWNAME}
	# 	Terminal=false
	# 	Type=Application
	# 	Icon=/usr/share/icons/hicolor/128x128/apps/motrix.png
	# EOF
	# cp2desktop ${tmpfile}

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
	rm -rf /opt/腾讯文档
	rm2desktop ${DSK_FILE}
	apt-get clean
else
	sw_download
	sw_install
	sw_create_desktop_file
fi

