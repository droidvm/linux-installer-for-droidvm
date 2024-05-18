#!/bin/bash

SWNAME=dotnet
DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh

function sw_download() {
	case "${CURRENT_VM_ARCH}" in
		"arm64")
				# app_dir=/opt/apps/${SWNAME}-${tmp_version}
				app_dir=/opt/apps/${SWNAME}
				mkdir -p ${app_dir} 2>/dev/null

				tmp_version="6"
				DEB_PATH=./downloads/${SWNAME}-${tmp_version}.tar.gz
				swUrl=${APP_URL_DLSERVER}/dotnet-sdk-6.0.417-linux-arm64.tar.gz
				swUrl=https://download.visualstudio.microsoft.com/download/pr/03972b46-ddcd-4529-b8e0-df5c1264cd98/285a1f545020e3ddc47d15cf95ca7a33/dotnet-sdk-6.0.417-linux-arm64.tar.gz
				download_file2 "${DEB_PATH}" "${swUrl}"
				exit_if_fail $? "下载失败，网址：${swUrl}"

				tmp_version="3"
				DEB_PATH=./downloads/${SWNAME}-${tmp_version}.tar.gz
				swUrl=${APP_URL_DLSERVER}/dotnet-sdk-3.0.103-linux-arm64.tar.gz
				swUrl=https://download.visualstudio.microsoft.com/download/pr/eb4ffaf1-b0a9-466d-8440-0220dca8f806/48df585d8d978c5418fa514da6a2bd9b/dotnet-sdk-3.0.103-linux-arm64.tar.gz
				download_file2 "${DEB_PATH}" "${swUrl}"
				exit_if_fail $? "下载失败，网址：${swUrl}"

				;;
		# "amd64")
		# 		echo "不需要单独下载"
		# 		;;
		*) exit_unsupport ;;
	esac

}

function sw_install_depends() {
	echo "正在安装依赖库"
	sudo apt-get install -y libicu72
	exit_if_fail $? "依赖库安装失败"
}

function sw_install() {
	case "${CURRENT_VM_ARCH}" in
		"arm64")
				# sudo apt-get install -y xz-utils
				# exit_if_fail $? "解压工具xz安装失败"

				echo "正在解压. . ."
				tmp_version="6"
				DEB_PATH=./downloads/${SWNAME}-${tmp_version}.tar.gz
				tar -xzf ${DEB_PATH} --overwrite -C ${app_dir}
				exit_if_fail $? "安装失败，软件包：${DEB_PATH}"

				tmp_version="3"
				DEB_PATH=./downloads/${SWNAME}-${tmp_version}.tar.gz
				tar -xzf ${DEB_PATH} --overwrite -C ${app_dir}
				exit_if_fail $? "安装失败，软件包：${DEB_PATH}"

				sw_install_depends

				;;
		"amd64")
				exit_unsupport
				;;
		*) exit_unsupport ;;
	esac
}

function sw_create_desktop_file() {
	echo ""

	echo '#!/bin/bash'> ./tmp/exec64

	cat <<- EOF >  ./tmp/dotnet
	#!/bin/bash
	export DOTNET_ROOT=${app_dir}
	exec ${app_dir}/dotnet \$@
	EOF
	mv -f ./tmp/dotnet  /usr/bin/
	chmod 755 /usr/bin/dotnet

	cat <<- EOF >> /etc/autoruns/installed_sw_env.sh
		export DOTNET_ROOT=${app_dir}
	EOF


	gxmessage -title "dotnet提示" "安装完成，请重启一次以使 DOTNET_ROOT 环境变量生效"  -center

}

if [ "${action}" == "卸载" ]; then
	echo "暂不支持卸载"
	exit 1
else
	sw_download
	sw_install
	sw_create_desktop_file
fi
