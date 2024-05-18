#!/bin/bash

SWNAME=sougou
SWVER=4.2.1.145

# 注意安装顺序，后装者依赖前装者
DEB_PATH1=./downloads/${SWNAME}-${SWVER}.deb

DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh


function sw_download() {
	app_dir=/opt/apps/${SWNAME}-${SWVER}

	case "${CURRENT_VM_ARCH}" in
		"arm64")
			# 链接不固定，而且是加密生成的链接，无法在shell中获取
			swUrl=https://ime-sec.gtimg.com/202401170112/633d14adc3f448e0b39ab5731810bb1e/pc/dl/gzindex/1680521473/sogoupinyin_4.2.1.145_arm64.deb
			download_file2 "${DEB_PATH1}" "${swUrl}"
			exit_if_fail $? "下载失败，网址：${swUrl}"
		;;
		"amd64")
			swUrl=https://ime-sec.gtimg.com/202401170129/bc8859cc88cf3e014d4cab6a60886c14/pc/dl/gzindex/1680521603/sogoupinyin_4.2.1.145_amd64.deb
			download_file2 "${DEB_PATH1}" "${swUrl}"
			exit_if_fail $? "下载失败，网址：${swUrl}"
		;;
		*) exit_unsupport ;;
	esac
}

function sw_install() {
	# apt-get install -y unzip
	# exit_if_fail $? "unzip安装失败"

	# mkdir -p ${app_dir} 2>/dev/null
	# exit_if_fail $? "无法创建目录: ${app_dir}"

	# unzip -oq ${DEB_PATH1} -d ${app_dir}
	# exit_if_fail $? "安装失败，软件包：${DEB_PATH1}"

	install_deb ${DEB_PATH1} # ${DEB_PATH2} ${DEB_PATH3}
	exit_if_fail $? "安装失败，软件包：${DEB_PATH}"

	apt-get install -f
	exit_if_fail $? "安装失败，软件包：${DEB_PATH}"

}

function sw_create_desktop_file() {

	cat <<- EOF > /tmp/msg.txt
		安装完成，但需要重启一次才会生效。
	EOF
	gxmessage -title "提示" -file /tmp/msg.txt -center
}

if [ "${action}" == "卸载" ]; then
	echo "暂不支持卸载"
	exit 1
else
	# sw_download
	# sw_install
	# sw_create_desktop_file

	cat <<- EOF > /tmp/msg.txt
		搜狗官网禁止自动下载
		请使用浏览器访问 https://shurufa.sogou.com/linux
		自行下载安装 ${CURRENT_VM_ARCH} 版本
		下载完成后点击安装包即可安装!
	EOF
	gxmessage -title "提示" -file /tmp/msg.txt -center

fi

