#!/bin/bash

SWNAME=xunleidownloader
DEB_PATH=./downloads/${SWNAME}.deb
DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh

function sw_download() {
	echo "暂不可用"
	exit 0

	# https://bbs.deepin.org/zh/post/205101
	case "${CURRENT_VM_ARCH}" in
		"arm64") swUrl=http://archive.kylinos.cn/kylin/partner/pool/com.xunlei.download_1.0.0.1_arm64.deb ;;
		"amd64") swUrl=http://archive.kylinos.cn/kylin/partner/pool/com.xunlei.download_1.0.0.1_amd64.deb ;;
		*) exit_unsupport ;;
	esac

	download_file2 "${DEB_PATH}" "${swUrl}"
	exit_if_fail $? "下载失败，网址：${swUrl}"
}

function sw_install() {
	apt-get install -y libasound2 libasound2-data libxss1
	exit_if_fail $? "依赖包安装失败"

	install_deb ${DEB_PATH}
	exit_if_fail $? "安装失败，软件包：${DEB_PATH}"

	# export LD_LIBRARY_PATH=/opt/apps/com.xunlei.download/files:$LD_LIBRARY_PATH
	# /opt/apps/com.xunlei.download/files/thunder
	# /opt/apps/com.xunlei.download/files/start.sh
	# /opt/apps/com.xunlei.download/files/thunder -start
}

function sw_create_desktop_file() {
	cat <<- EOF > ${DSK_PATH}
	[Desktop Entry]
	Name=Code No Sandbox
	Comment=Code Editing. No sandbox. Redefined.
	GenericName=Text Editor
	Exec=/usr/share/code/code --no-sandbox --unity-launch --user-data-dir=~/.vscode %F
	Icon=vscode
	Type=Application
	StartupNotify=false
	StartupWMClass=Code
	Categories=TextEditor;Development;IDE;
	MimeType=text/plain;inode/directory;application/x-code-workspace;
	Actions=new-empty-window;
	Keywords=vscode;

	X-Desktop-File-Install-Version=0.26

	[Desktop Action new-empty-window]
	Name=New Empty Window
	Exec=/usr/share/code/code --no-sandbox --new-window %F
	Icon=com.visualstudio.code
	EOF

	# [ -f /usr/bin/code_ori ] || 
	sudo mv -f /usr/bin/code /usr/bin/code_ori
	cat <<- EOF > /usr/bin/code
	#!/bin/bash
	exec /usr/bin/code_ori --no-sandbox  \$@
	EOF
	chmod 755 /usr/bin/code
}

if [ "${action}" == "卸载" ]; then
	echo "暂不支持卸载"
	exit 1
else

	sw_download
	sw_install
	sw_create_desktop_file

fi
