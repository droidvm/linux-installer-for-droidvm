#!/bin/bash

SWNAME=idea
DEB_PATH=./downloads/${SWNAME}.tar.gz
DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh

function sw_download() {

	# tmpdns=`cd /exbin && droidexec ./vm_getHostByName.sh aka.ms go.microsoft.com`
	# exit_if_fail $? "DNS解析失败"
	# echo "$tmpdns" >> /etc/hosts

	which java >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		echo ""						> /tmp/msg.txt
		echo "请先安装jdk21、box"	>>/tmp/msg.txt
		echo ""						>>/tmp/msg.txt
		gxmessage -title "提示" -file /tmp/msg.txt -center
		exit 1
	fi

	which box64 >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		echo ""						> /tmp/msg.txt
		echo "请先安装jdk21、box"	>>/tmp/msg.txt
		echo ""						>>/tmp/msg.txt
		gxmessage -title "提示" -file /tmp/msg.txt -center
		exit 1
	fi

	case "${CURRENT_VM_ARCH}" in
		"arm64") swUrl=https://download-cdn.jetbrains.com.cn/idea/ideaIC-2023.3.4-aarch64.tar.gz ;;
		"amd64") swUrl=https://download-cdn.jetbrains.com.cn/idea/ideaIC-2023.3.4-aarch64.tar.gz ;;
		*) exit_unsupport ;;
	esac

	download_file2 "${DEB_PATH}" "${swUrl}"
	exit_if_fail $? "下载失败，网址：${swUrl}"

	# commandlinetools/sdk安装器 2024.03.06, 来自：https://developer.android.google.cn/codelabs/basic-android-kotlin-compose-install-android-studio?hl=zh-cn#6
	dlpkg2=commandlinetools-linux.zip
	swUrl=https://googledownloads.cn/android/repository/commandlinetools-linux-11076708_latest.zip
	download_file2 "${dlpkg2}" "${swUrl}"
	exit_if_fail $? "下载失败，网址：${dlpkg2}"

}

function sw_install() {

	sudo apt-get install -y unzip 
	exit_if_fail $? "解压工具unzip安装失败"

	# echo "正在解压. . ."
	# tar -pxzf ${DEB_PATH} --overwrite -C /opt/apps/
	# exit_if_fail $? "安装失败，软件包：${DEB_PATH}"

	dir_tmp=`ls -a /opt/apps/|grep idea|tail -n 1`
	app_dir=/opt/apps/${dir_tmp}

	mkdir -p /opt/apps/commandlinetools 2>/dev/null
	unzip -oq ${dlpkg2} -d /opt/apps/commandlinetools
	exit_if_fail $? "解压失败，软件包：${dlpkg2}"



	# # dpkg -i ${DEB_PATH} || apt-get install -y ${DEB_PATH}
	# install_deb ${DEB_PATH}
	# exit_if_fail $? "安装失败，软件包：${DEB_PATH}"

	# # apt-get --fix-broken install -y
	# # exit_if_fail $? "安装失败，软件包：${DEB_PATH}"

	# rm -rf ${DIR_DESKTOP_FILES}/code-url-handler.desktop
	# rm -rf ${DIR_DESKTOP_FILES}/code.desktop

	# # /usr/share/code/code --no-sandbox --unity-launch --user-data-dir=~/.vscode
	# # file_path_watcher_inotify.cc(86)] Failed to read /proc/sys/fs/inotify/max_user_watches
}

function sw_create_desktop_file() {
	echo ""

	cat <<- EOF > ${DSK_PATH}
	[Desktop Entry]
	Name=IDEA
	Comment=IntelliJ IDEA
	GenericName=Text Editor
	Exec=${app_dir}/bin/idea.sh %F
	Icon=${app_dir}/bin/idea.svg
	Type=Application
	StartupNotify=false
	Categories=TextEditor;Development;IDE;
	MimeType=text/plain;inode/directory;application/x-code-workspace;
	Actions=new-empty-window;
	Keywords=idea;
	EOF
	cp2desktop ${DSK_PATH}

	# # [ -f /usr/bin/code_ori ] || 
	# sudo mv -f /usr/bin/code /usr/bin/code_ori
	# cat <<- EOF > /usr/bin/code
	# #!/bin/bash
	# exec /usr/bin/code_ori --no-sandbox  \$@
	# EOF
	# chmod 755 /usr/bin/code
}

if [ "${action}" == "卸载" ]; then
	# sudo apt-get remove -y code #${SWNAME}
	echo "暂不支持卸载"
	exit 1
else
	sw_download
	sw_install
	sw_create_desktop_file
fi
