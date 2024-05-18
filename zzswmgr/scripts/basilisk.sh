#!/bin/bash

# 官网：https://www.basilisk-browser.org/
# https://archive.basilisk-browser.org/2023.12.09/beta/linux/aarch64/gtk3/basilisk-20231209010841.linux-aarch64-gtk3.tar.xz

. ./scripts/common.sh


SWNAME=basilisk
PATH_SAVETO=./downloads/${SWNAME}.tar.xz
DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}
BIN_FILE=${ZZSWMGR_APPI_DIR}/basilisk/basilisk

action=$1
if [ "$action" == "" ]; then action=安装; fi

function sw_download() {
	# echo "149.28.108.249     www.basilisk-browser.org" >> /etc/hosts
	# echo "149.28.108.249 archive.basilisk-browser.org" >> /etc/hosts
	# echo "2001:19f0:9002:35:5400:4ff:fe17:ec48     www.basilisk-browser.org" >> /etc/hosts
	# echo "2001:19f0:9002:35:5400:4ff:fe17:ec48 archive.basilisk-browser.org" >> /etc/hosts
	tmpdns=`cd /exbin && droidexec ./vm_getHostByName.sh www.basilisk-browser.org archive.basilisk-browser.org`
	exit_if_fail $? "DNS解析失败"
	echo "$tmpdns" >> /etc/hosts
	
	swUrl="https://www.basilisk-browser.org/download.shtml"
	wget ${swUrl} -O ./downloads/download.shtml
	exit_if_fail $? "下载失败，网址：${swUrl}"

	case "${CURRENT_VM_ARCH}" in
		"arm64")
			# swUrl="${APP_URL_DLSERVER}/basilisk-20230718194432.linux-aarch64-gtk3.tar.xz"
			swUrl=`grep -o "\"http[^\>]*\"" ./downloads/download.shtml|grep -o "http[^\"]*"|grep linux|grep gtk3|grep aarch64`
			download_file2 "${PATH_SAVETO}" "${swUrl}"
			exit_if_fail $? "下载失败，网址：${swUrl}"
		;;
		"amd64")
			# swUrl="${APP_URL_DLSERVER}/basilisk-20230718135122.linux-x86_64.tar.xz"
			swUrl=`grep -o "\"http[^\>]*\"" ./downloads/download.shtml|grep -o "http[^\"]*"|grep linux|grep gtk3|grep x86_64`
			download_file2 "${PATH_SAVETO}" "${swUrl}"
			exit_if_fail $? "下载失败，网址：${swUrl}"
		;;
		*) exit_unsupport ;;
	esac
}

function sw_install() {
	 sudo apt-get install -y xz-utils
	 exit_if_fail $? "解压工具xz安装失败"

	tar -xJf ${PATH_SAVETO}  --overwrite -C /opt/apps
	exit_if_fail $? "安装失败，软件包：${PATH_SAVETO}"
}

function sw_create_desktop_file() {

cat <<- EOF > ${DSK_PATH}
[Desktop Entry]
Version=0.9.4
Encoding=UTF-8
Type=Application
Categories=System
Categories=Network;WebBrowser;
Terminal=false
Icon=/opt/apps/basilisk/browser/icons/mozicon128.png
MimeType=text/html;text/xml;application/xhtml_xml;x-scheme-handler/http;x-scheme-handler/https;
Name=Basilisk Web Browser
Name[zh_CN]=Basilisk 网页浏览器
Name[zh_HK]=Basilisk 網頁瀏覽器
Name[zh_TW]=Basilisk 網頁瀏覽器
GenericName=Web Browser
Exec=${BIN_FILE}
EOF

update-alternatives --set x-www-browser ${BIN_FILE}
xdg-settings set default-web-browser ${DSK_FILE}


}

if [ "${action}" == "卸载" ]; then
	rm -rf ${ZZSWMGR_APPI_DIR}/basilisk
else
	sw_download
	sw_install
	sw_create_desktop_file
fi
