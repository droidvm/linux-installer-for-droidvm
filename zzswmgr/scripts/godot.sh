#!/bin/bash

SWNAME=godot
DEB_PATH=./downloads/${SWNAME}.zip
DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}
SWVER=4.2.1

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh

function sw_download() {
	# echo "211.97.84.91   mirrors.cloud.tencent.com"           >> /etc/hosts

	case "${CURRENT_VM_ARCH}" in
		"arm64")
				# swUrl=https://mirrors.cloud.tencent.com/AndroidSDK/android-ndk-${SWVER}-linux.zip

				swUrl=https://mirror.ghproxy.com/https://github.com/godotengine/godot/releases/download/${SWVER}-stable/Godot_v${SWVER}-stable_linux.arm64.zip
				;;
		"amd64")
				swUrl=https://mirror.ghproxy.com/https://github.com/godotengine/godot/releases/download/${SWVER}-stable/Godot_v${SWVER}-stable_linux.x86_64.zip
				;;
		*) exit_unsupport ;;
	esac

	download_file2 "${DEB_PATH}" "${swUrl}"
	exit_if_fail $? "下载失败，网址：${swUrl}"

	# 程序图标
	swUrl=https://mirror.ghproxy.com/https://raw.githubusercontent.com/godotengine/godot/master/icon.png
	download_file2 "./downloads/${SWNAME}_icon.png" "${swUrl}"
	exit_if_fail $? "下载失败，网址：${swUrl}"
}

function sw_install() {
	# apt-get install -y make
	# exit_if_fail $? "依赖包安装失败"

	apt-get install -y unzip
	exit_if_fail $? "解压工具unzip安装失败"

	echo "正在解压. . ."
	app_dir=/opt/apps/${SWNAME}-v${SWVER}
	mkdir -p "${app_dir}" 2>/dev/null
	unzip -oq ${DEB_PATH} -d ${app_dir}
	exit_if_fail $? "安装失败，软件包：${DEB_PATH}"

	# for dirname in ndk-demo1 ndk-opengles-demo1 ndk-vulkan-demo1
	# do
	# 	chmod a+x ./scripts/res/$dirname/build.sh
	# 	ls -al    ./scripts/res/$dirname/build.sh
	# done
}

function sw_create_desktop_file() {
	tmpext=arm64
	case "${CURRENT_VM_ARCH}" in
		"arm64")
			tmpext=arm64
			;;
		"amd64")
			tmpext=x86_64
			;;
		*) exit_unsupport ;;
	esac

	if [ -f "./downloads/${SWNAME}_icon.png" ]; then
		mv -f "./downloads/${SWNAME}_icon.png" ${app_dir}/icon.png
	fi

	cat <<- EOF > ${DSK_PATH}
[Desktop Entry]
Name=godot
Comment=
Exec=${app_dir}/Godot_v4.2.1-stable_linux.${tmpext} %F
Icon=${app_dir}/icon.png
Terminal=false
Type=Application
Categories=Graphics;Education;Development;Science;
Keywords=3D;Printing;Slicer;
	EOF

	cp2desktop ${DSK_PATH}
}

if [ "${action}" == "卸载" ]; then
	echo "暂不支持卸载"
	exit 1
else

	sw_download
	sw_install
	sw_create_desktop_file
fi
