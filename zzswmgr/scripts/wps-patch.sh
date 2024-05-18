#!/bin/bash

SWNAME=wps
DEB_PATH=./downloads/${SWNAME}.deb
FT_PATH1=./downloads/ttf-wps-fonts.tar.xz
FT_PATH2=./downloads/freetype-old.deb
DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh

maindeb_installed=0
if [ -d /opt/kingsoft/wps-office ]; then
	maindeb_installed=1
else
	echo ""				> /tmp/msg.txt
	echo "请先安装wps"	>>/tmp/msg.txt
	echo ""				>>/tmp/msg.txt
	gxmessage -title "提示" -file /tmp/msg.txt -center
	exit 1
fi

function sw_download() {

	# echo "204.68.111.105 downloads.sourceforge.net" >> /etc/hosts
	tmpdns=`cd /exbin && droidexec ./vm_getHostByName.sh downloads.sourceforge.net linux.wps.cn`
	exit_if_fail $? "DNS解析失败"
	echo "$tmpdns" >> /etc/hosts

	# download_file_axel "${DEB_PATH}" "${swUrl}"
	# exit_if_fail $? "下载失败(WPS官方禁止自动下载)，您可前往wps官网手动下载安装：https://linux.wps.cn/"

	# 下载必须的字体
	swUrl=https://gitee.com/ak2/ttf-wps-fonts/raw/master/ttf-wps-fonts.tar.xz
	download_file_axel "${FT_PATH1}" "${swUrl}"
	exit_if_fail $? "下载失败，网址：${swUrl}"


	# 字体加粗异常问题的修复
	case "${CURRENT_VM_ARCH}" in
		"arm64")
			swUrl=https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/pool/main/f/freetype/libfreetype6_2.12.1%2Bdfsg-4_arm64.deb
			;;
		"amd64")
			swUrl=https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/f/freetype/libfreetype6_2.12.1%2Bdfsg-4_amd64.deb
			;;
		*) exit_unsupport ;;
	esac
	download_file_axel "${FT_PATH2}" "${swUrl}"
	exit_if_fail $? "下载失败，网址：${swUrl}"

	# # 下载必须的字体
	# swUrl=https://gitee.com/ak2/msttcorefonts/raw/master/msttcorefonts.tar.xz
	# download_file2 "${FT_PATH2}" "${swUrl}"
	# exit_if_fail $? "下载失败，网址：${swUrl}"
}

function sw_install() {
	# # hard code patch for wps-aarch64 reinstall operation
	# if [ -f /usr/share/applications/wps-office-wps.desktop ]; then
	# 	echo "检测到您正在重新安装wps，为避免wps.postinst 出错，此处加了hard code"
	# 	cp -f /usr/share/applications/wps-office-wps.desktop	/usr/share/applications/wps-office-wps-aarch64.desktop
	# 	cp -f /usr/share/applications/wps-office-et.desktop		/usr/share/applications/wps-office-et-aarch64.desktop
	# 	cp -f /usr/share/applications/wps-office-wpp.desktop	/usr/share/applications/wps-office-wpp-aarch64.desktop
	# fi

	echo "正在 dpkg --configure -a"
	dpkg --configure -a

	# 有用户交互部分！！！
	echo "正在安装ms字体"
	aceept_command=debconf-set-selections
	echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | ${aceept_command}
	apt-get install -y ttf-mscorefonts-installer
	exit_if_fail $? "ms字体安装失败"

	echo "正在安装wps字体"
	tar -Jxvf "${FT_PATH1}" --overwrite -C /
	exit_if_fail $? "wps字体安装失败"

	echo "正在更新字体缓存"
	fc-cache -f -v

	echo "正在安装依赖库"
	apt-get install -y libglu1-mesa libxslt-dev bsdmainutils
	exit_if_fail $? "依赖库安装失败"

	rm -rf ./tmp/deb-freetype-old
	dpkg-deb -x "${FT_PATH2}" ./tmp/deb-freetype-old
	exit_if_fail $? "旧版freetype解包失败"

	# droidvm@DroidVM:/opt/kingsoft/wps-office/office6$ ls -al|grep freetype
	# lrwxrwxrwx.  1 droidvm droidvm       34 11月 24 20:07 libfreetype.so -> libfreetype.so.6.12.1
	# lrwxrwxrwx.  1 droidvm droidvm       50  2月 18 19:57 libfreetype.so.6 -> /usr/lib/aarch64-linux-gnu/libfreetype.so.6.20.0
	# -rw-r--r--.  1 droidvm droidvm   576104 11月 24 20:07 libfreetype.so.6.12.1

	echo "正在为wps安装旧版freetype"
	if [ ! -e /opt/kingsoft/wps-office/office6/libfreetype.so.6.bak ]; then
		mv -f /opt/kingsoft/wps-office/office6/libfreetype.so.6 /opt/kingsoft/wps-office/office6/libfreetype.so.6.bak
	fi
	cp -f ./tmp/deb-freetype-old/usr/lib/aarch64-linux-gnu/libfreetype.so.6.18.3 /opt/kingsoft/wps-office/office6/
	cd /opt/kingsoft/wps-office/office6/ && ln -sf libfreetype.so.6.18.3 libfreetype.so.6
	exit_if_fail $? "旧版freetype复制失败"
	echo "旧版freetype安装完成"

}

function sw_create_desktop_file() {
	echo ""
	# gxmessage -title "提示" "安装已完成，但需要重启一次才能运行"  -center
}

if [ "${action}" == "卸载" ]; then
	echo "暂不支持卸载"
	exit 1
else

	sw_download
	sw_install
	sw_create_desktop_file
fi
