#!/bin/bash

SWNAME=wps-pro
DEB_PATH=./downloads/${SWNAME}.deb
FT_PATH1=./downloads/ttf-wps-fonts.tar.xz
DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh

function sw_download() {

	# echo "204.68.111.105 downloads.sourceforge.net" >> /etc/hosts
	tmpdns=`cd /exbin && droidexec ./vm_getHostByName.sh downloads.sourceforge.net linux.wps.cn`
	exit_if_fail $? "DNS解析失败"
	echo "$tmpdns" >> /etc/hosts

	case "${CURRENT_VM_ARCH}" in
		"arm64") swUrl="https://zunyun01.store.deepinos.org.cn/aarch64-store/office/cn.wps.wps-office-pro/cn.wps.wps-office-pro_11.8.2.1132.AK.preload.sw.withsn_arm64.deb" ;;
		"amd64") swUrl="https://zunyun01.store.deepinos.org.cn/amd64-store/office/cn.wps.wps-office-pro/cn.wps.wps-office-pro_11.8.2.1132.AK.preload.sw.withsn_amd64.deb" ;;
		*) exit_unsupport ;;
	esac

	download_file2 "${DEB_PATH}" "${swUrl}"
	exit_if_fail $? "下载失败，网址：${swUrl}"

	# 下载必须的字体
	swUrl=https://gitee.com/ak2/ttf-wps-fonts/raw/master/ttf-wps-fonts.tar.xz
	download_file_axel "${FT_PATH1}" "${swUrl}"
	exit_if_fail $? "下载失败，网址：${swUrl}"

	# # 下载必须的字体
	# swUrl=https://gitee.com/ak2/msttcorefonts/raw/master/msttcorefonts.tar.xz
	# download_file2 "${FT_PATH2}" "${swUrl}"
	# exit_if_fail $? "下载失败，网址：${swUrl}"
}

function sw_install() {

	# 有用户交互部分！！！
	aceept_command=debconf-set-selections
	echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | ${aceept_command}
	sudo apt-get install -y ttf-mscorefonts-installer
	exit_if_fail $? "ms字体安装失败"

	tar -Jxvf "${FT_PATH1}" --overwrite -C /
	exit_if_fail $? "wps字体安装失败"

	# 更新字体缓存
	sudo fc-cache -f -v

	sudo apt-get install -y libglu1-mesa libxslt-dev bsdmainutils ${ZZSWMGR_MAIN_DIR}/${DEB_PATH} \
	${ZZSWMGR_MAIN_DIR}/scripts/res/deepin-elf-verify_all.deb
	exit_if_fail $? "安装失败"

	# dpkg -i ${DEB_PATH} || apt-get install -y ${DEB_PATH}
	# install_deb ${DEB_PATH}
	# exit_if_fail $? "安装失败，软件包：${DEB_PATH}"

	# 默认的界面语言
	# cat ${HOME}/.config/Kingsoft/Office.conf|grep languages

	# apt-get --fix-broken install -y
	# exit_if_fail $? "安装失败，软件包：${DEB_PATH}"

	# rm -rf ${DIR_DESKTOP_FILES}/code-url-handler.desktop
	# rm -rf ${DIR_DESKTOP_FILES}/code.desktop

	# /opt/kingsoft/wps-office/office6/wps
	# /opt/kingsoft/wps-office/office6/wpsoffice
	# /opt/kingsoft/wps-office/office6/et

	# 错误1：找不到 libproviders.so 
	# 是因为虚拟电脑使用的rootfs较新，带的openssl也较新, export OPENSSL_CONF=/dev/null 可以不报此错误

	# 错误2：Some formula symbols might not be displayed correctly due to missing fonts. 缺失字体
	# https://gitee.com/ak2/ttf-wps-fonts
	# https://gitee.com/ak2/msttcorefonts

	# 错误3：backup fail/backup目录不可设置，backup功能不可关闭
	# 还是proot环境不能处理 mount 映射，导致wps把备份目录识别成只读的(/home/droidvm/.local/share/Kingsoft/office6/data/backup)
}

function sw_create_desktop_file() {
	echo ""
# cat <<- EOF > ${DSK_PATH}
# [Desktop Entry]
# Name=Code No Sandbox
# Comment=Code Editing. No sandbox. Redefined.
# GenericName=Text Editor
# Exec=/usr/share/code/code --no-sandbox --unity-launch --user-data-dir=~/.vscode %F
# Icon=vscode
# Type=Application
# StartupNotify=false
# StartupWMClass=Code
# Categories=TextEditor;Development;IDE;
# MimeType=text/plain;inode/directory;application/x-code-workspace;
# Actions=new-empty-window;
# Keywords=vscode;

# X-Desktop-File-Install-Version=0.26

# [Desktop Action new-empty-window]
# Name=New Empty Window
# Exec=/usr/share/code/code --no-sandbox --new-window %F
# Icon=com.visualstudio.code
# EOF
}

if [ "${action}" == "卸载" ]; then
	apt-get purge cn.wps.wps-office-pro -y
	apt-get -y autoremove --purge cn.wps.wps-office-pro
	rm2desktop wps-office*
	rm -rf /usr/share/applications/wps-office*
	rm -rf /opt/kingsoft/cn.wps.wps-office-pro
	rm -rf /home/${ZZ_USER_NAME}/.local/share/Kingsoft
	rm -rf /home/${ZZ_USER_NAME}/.config/Kingsoft

	# echo "暂不支持卸载"
	# exit 1
else

	sw_download
	sw_install
	sw_create_desktop_file
fi
