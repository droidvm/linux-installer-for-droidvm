#!/bin/bash

SWNAME=vscode
DEB_PATH=./downloads/${SWNAME}.deb
DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh

function sw_download() {

	tmpdns=`cd /exbin && droidexec ./vm_getHostByName.sh aka.ms go.microsoft.com`
	exit_if_fail $? "DNS解析失败"
	echo "$tmpdns" >> /etc/hosts

	# echo "23.45.57.205                 aka.ms"           >> /etc/hosts
	# echo "23.206.6.100                 go.microsoft.com" >> /etc/hosts
	# echo "2a02:26f0:2b00:99d::2c1a     go.microsoft.com" >> /etc/hosts
	# echo "2a02:26f0:2b00:980::2c1a     go.microsoft.com" >> /etc/hosts

	case "${CURRENT_VM_ARCH}" in
		"arm64") swUrl=https://aka.ms/linux-arm64-deb ;;
		"amd64") swUrl=https://go.microsoft.com/fwlink/?LinkID=760868 ;;
		*) exit_unsupport ;;
	esac

	download_file2 "${DEB_PATH}" "${swUrl}"
	exit_if_fail $? "下载失败，网址：${swUrl}"
}

function sw_install() {
	# apt-get install -y libasound2 libasound2-data xdg-utils xdg-utils
	# exit_if_fail $? "依赖包安装失败"

	# dpkg -i ${DEB_PATH} || apt-get install -y ${DEB_PATH}
	install_deb ${DEB_PATH}
	exit_if_fail $? "安装失败，软件包：${DEB_PATH}"

	# apt-get --fix-broken install -y
	# exit_if_fail $? "安装失败，软件包：${DEB_PATH}"

	rm -rf ${DIR_DESKTOP_FILES}/code-url-handler.desktop
	rm -rf ${DIR_DESKTOP_FILES}/code.desktop

	# /usr/bin/code_ori --no-sandbox --unity-launch --user-data-dir=~/.vscode
	# file_path_watcher_inotify.cc(86)] Failed to read /proc/sys/fs/inotify/max_user_watches
}

function sw_create_desktop_file() {
	# STR_FORCE_GTK2="--gtk-version=2 --unity-launch "
	STR_FORCE_GTK2=""
	ZZVM_ARGS="--no-sandbox --unity-launch ${STR_FORCE_GTK2} --user-data-dir=${ZZ_USER_HOME}/.vscode"

	cat <<- EOF > ${DSK_PATH}
	[Desktop Entry]
	Name=VSCode
	Comment=Code Editing. No sandbox. Redefined.
	GenericName=Text Editor
	Exec=/usr/bin/code_ori ${ZZVM_ARGS} %F
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
	Exec=/usr/bin/code_ori ${ZZVM_ARGS} --new-window %F
	Icon=com.visualstudio.code
	EOF
	cp2desktop ${DSK_PATH}

	# [ -f /usr/bin/code_ori ] || 
	sudo mv -f /usr/bin/code /usr/bin/code_ori
	cat <<- EOF > /usr/bin/code
	#!/bin/bash
	exec /usr/bin/code_ori ${ZZVM_ARGS} \$@
	EOF
	chmod 755 /usr/bin/code
}

if [ "${action}" == "卸载" ]; then
	sudo apt-get remove -y code #${SWNAME}
else

	sw_download
	sw_install
	sw_create_desktop_file
fi







