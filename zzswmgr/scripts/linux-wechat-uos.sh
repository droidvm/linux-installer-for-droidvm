#!/bin/bash

: '
微信只对uos发由的linux版本

虚拟电脑中的微信是这么装的：
=============================================================
https://home-store-packages.uniontech.com/appstore/pool/appstore/c/com.tencent.weixin/com.tencent.weixin_2.1.9_arm64.deb
http://mirrors.tuna.tsinghua.edu.cn/debian/pool/main/o/openssl/libssl1.1_1.1.1n-0%2Bdeb10u3_arm64.deb
https://gitee.com/droidvm/linux-installer-for-droidvm/blob/master/zzswmgr/scripts/res/deepin-elf-verify_all.deb

下载并安装上面3个deb包

# 从apt仓库安装libasound2
sudo apt install -y libasound2

# 模拟uos
	cat <<- FILEEND > /etc/lsb-release.uos
		DISTRIB_ID=uos
		DISTRIB_RELEASE=20
		DISTRIB_DESCRIPTION=UnionTech OS 20
		DISTRIB_CODENAME=eagle
	FILEEND

	cat <<- FILEEND > /usr/lib/os-release.uos
		PRETTY_NAME=UnionTech OS Desktop 20 Pro
		NAME=uos
		VERSION_ID=20
		VERSION=20
		ID=uos
		HOME_URL=https://www.chinauos.com/
		BUG_REPORT_URL=http://bbs.chinauos.com
		VERSION_CODENAME=eagle
	FILEEND
	cp -f /etc/lsb-release.uos    /etc/lsb-release
	cp -f /usr/lib/os-release.uos /usr/lib/os-release

# 启动微信
/opt/apps/com.tencent.weixin/files/weixin/weixin --no-sandbox
'


SWNAME=weixin
SWVER=2.1.9

# 注意安装顺序，后装者依赖前装者
DEB_PATH1=./downloads/${SWNAME}-${SWVER}.deb
DEB_PATH2=./downloads/libssl1.1.deb

DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh

# app_dir=/opt/apps/${SWNAME}-${SWVER}
# mkdir -p ${app_dir} 2>/dev/null

function sw_download() {
	case "${CURRENT_VM_ARCH}" in
		"arm64")
			swUrl="https://home-store-packages.uniontech.com/appstore/pool/appstore/c/com.tencent.weixin/com.tencent.weixin_${SWVER}_arm64.deb"
			download_file_axel "${DEB_PATH1}" "${swUrl}"
			exit_if_fail $? "下载失败，网址：${swUrl}"

			swUrl="http://mirrors.tuna.tsinghua.edu.cn/debian/pool/main/o/openssl/libssl1.1_1.1.1n-0%2Bdeb10u3_arm64.deb"
			download_file_axel "${DEB_PATH2}" "${swUrl}"
			exit_if_fail $? "下载失败，网址：${swUrl}"

		;;
		# "amd64")
		# 	swUrl="https://home-store-packages.uniontech.com/appstore/pool/appstore/c/com.tencent.weixin/com.tencent.weixin_2.1.9_amd64.deb"
		# 	download_file2 "${DEB_PATH1}" "${swUrl}"
		# 	exit_if_fail $? "下载失败，网址：${swUrl}"
		# ;;
		*) exit_unsupport ;;
	esac
}

function sw_install() {

	apt-get install -y \
	${ZZSWMGR_MAIN_DIR}/downloads/libssl1.1.deb \
	${ZZSWMGR_MAIN_DIR}/downloads/${SWNAME}-${SWVER}.deb \
	${ZZSWMGR_MAIN_DIR}/scripts/res/deepin-elf-verify_all.deb \
	libasound2
	exit_if_fail $? "安装失败"

	unzip -oq ./scripts/res/uos-fake.zip -d /
	exit_if_fail $? "uos-fake 解压失败"

	cat <<- FILEEND > /etc/lsb-release.uos
		DISTRIB_ID=uos
		DISTRIB_RELEASE=20
		DISTRIB_DESCRIPTION=UnionTech OS 20
		DISTRIB_CODENAME=eagle
	FILEEND

	cat <<- FILEEND > /usr/lib/os-release.uos
		PRETTY_NAME=UnionTech OS Desktop 20 Pro
		NAME=uos
		VERSION_ID=20
		VERSION=20
		ID=uos
		HOME_URL=https://www.chinauos.com/
		BUG_REPORT_URL=http://bbs.chinauos.com
		VERSION_CODENAME=eagle
	FILEEND

}

function sw_create_desktop_file() {

	STARTUP_SCRIPT_FILE=/opt/apps/com.tencent.weixin/files/weixin/weixin.sh
	cat <<- EOF > ${STARTUP_SCRIPT_FILE}
		#!/bin/bash

		cp -f /etc/lsb-release.uos    /etc/lsb-release
		cp -f /usr/lib/os-release.uos /usr/lib/os-release

		WINXIN=`ps -ef | grep weixin | grep -v grep | grep -v weixin.sh | wc -l`
		if [ 0 -ne \$WINXIN ]; then
			pidof weixin | xargs kill -9
			/opt/apps/com.tencent.weixin/files/weixin/weixin --no-sandbox >/dev/null 2>&1
		else
			/opt/apps/com.tencent.weixin/files/weixin/weixin --no-sandbox >/dev/null 2>&1
		fi

		cp -f /etc/lsb-release.ori    /etc/lsb-release
		cp -f /usr/lib/os-release.ori /usr/lib/os-release

	EOF
	chmod a+x ${STARTUP_SCRIPT_FILE}
	cp -f ${STARTUP_SCRIPT_FILE}  /usr/bin/

	echo "正在生成桌面文件"
	tmpfile=${DIR_DESKTOP_FILES}/weixin.desktop # ${SWNAME}.desktop
	# echo "[Desktop Entry]"					> ${tmpfile}
	# echo "Encoding=UTF-8"					>>${tmpfile}
	# echo "Version=0.9.4"					>>${tmpfile}
	# echo "Name=微信"						>>${tmpfile}
	# echo "Exec=weixin.sh"	>>${tmpfile}
	# echo "Terminal=false"					>>${tmpfile}
	# echo "Type=Application"					>>${tmpfile}
	# echo "StartupWMClass=微信"				>>${tmpfile}
	# echo "Categories=Network;"				>>${tmpfile}
	# echo "Comment=微信UOS版"				>>${tmpfile}
	# echo "Icon=weixin"						>>${tmpfile}
	cp2desktop ${tmpfile}

	cat <<- EOF > /tmp/msg.txt

		安装完成.

		【警告】
		proot虚拟系统中的权限是不完整的
		请权衡后再使用此微信客户端！

	EOF
	gxmessage -title "提示" -file /tmp/msg.txt -center
	# gxmessage -title "提示"     $'\n安装完成\n\n'  -center
}

if [ "${action}" == "卸载" ]; then
	# echo "暂不支持卸载"
	# exit 1
	rm -rf ${app_dir} ${DIR_DESKTOP_FILES}/${SWNAME}.desktop
	rm2desktop ${SWNAME}.desktop
else
	sw_download
	sw_install
	sw_create_desktop_file
fi

