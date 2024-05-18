#!/bin/bash

SWNAME=rustdesk
DEB_PATH=./downloads/${SWNAME}.deb
DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh

function sw_download() {
	case "${CURRENT_VM_ARCH}" in
		"arm64") swUrl=https://github.com/rustdesk/rustdesk/releases/download/1.2.3/rustdesk-1.2.3-aarch64.deb ;;
		"amd64") swUrl=https://github.com/rustdesk/rustdesk/releases/download/1.2.3/rustdesk-1.2.3-x86_64.deb ;;
		*) exit_unsupport ;;
	esac

	download_file2 "${DEB_PATH}" "${swUrl}"
	exit_if_fail $? "下载失败，网址：${swUrl}"
}

function sw_install() {
	sudo apt-get install -y libappindicator3-1
	exit_if_fail $? "依赖库安装失败"

	install_deb ${DEB_PATH}
	exit_if_fail $? "安装失败，软件包：${DEB_PATH}"
}

function sw_create_desktop_file() {
	cat <<- EOF > /usr/bin/rustdesk
		#!/bin/bash
		export XDG_SESSION_ID=droidvm
		unset GALLIUM_DRIVER
		unset MESA_GL_VERSION_OVERRIDE
		unset LANG
		unset LANGUAGE
		unset LC_ALL
		unset LC_CTYPE
		unset LC_MESSAGE
		exec /usr/lib/rustdesk/rustdesk \$@
	EOF
	chmod a+x /usr/bin/rustdesk
}

if [ "${action}" == "卸载" ]; then
	echo "暂不支持卸载"
	exit 1
else

	sw_download
	sw_install
	sw_create_desktop_file
fi
