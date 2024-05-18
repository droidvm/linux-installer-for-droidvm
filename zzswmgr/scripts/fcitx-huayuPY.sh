#!/bin/bash

SWNAME=fcitx-huayuPY
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
	command -v fcitx5
	if [ $? -eq 0 ]; then
		gxmessage -title "软件冲突"     $'\n软件冲突，安装失败\n系统中已安装过fcitx5系列的输入法\n与当前正在安装的fcitx4系列输入冲突\n请先卸载fcitx5系列的输入法\n\n'  -center
		exit 2
	fi


	app_dir=/opt/apps/${SWNAME}-${SWVER}

	# tmpdns=`cd /exbin && droidexec ./vm_getHostByName.sh pinyin.thunisoft.com`
	# exit_if_fail $? "DNS解析失败"
	# echo "$tmpdns" >> /etc/hosts


	case "${CURRENT_VM_ARCH}" in
		"arm64")
			# 链接不固定，而且是加密生成的链接，无法在shell中获取
			swUrl="https://pinyin.thunisoft.com/webapi/v1/downloadSetupFile?os=kylin&cpu=arm"
			download_file2 "${DEB_PATH1}" "${swUrl}"
			exit_if_fail $? "下载失败，网址：${swUrl}"
		;;
		"amd64")
			swUrl="https://pinyin.thunisoft.com/webapi/v1/downloadSetupFile?os=kylin&cpu=x86"
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



	# if [ -f /exbin/autoruns/services_after_gui/fcitx.sh ]; then
	# 	cp -f "/exbin/autoruns/services_after_gui/fcitx.sh"  "/etc/autoruns/autoruns_after_gui/"
	# fi

	# if [ -f /exbin/autoruns/autoruns_after_gui/fcitx.sh ]; then
	# 	cp -f "/exbin/autoruns/autoruns_after_gui/fcitx.sh"  "/etc/autoruns/autoruns_after_gui/"
	# fi

	# 移除旧版的自启动文件
	if [ -f /etc/autoruns/services_after_gui/fcitx.sh ]; then
		rm -rf /etc/autoruns/services_after_gui/fcitx.sh
	fi

	if [ -f /etc/autoruns/autoruns_after_gui/fcitx.sh ]; then
		rm -rf /etc/autoruns/autoruns_after_gui/fcitx.sh
	fi

	install_deb ${DEB_PATH1} # ${DEB_PATH2} ${DEB_PATH3}
	exit_if_fail $? "安装失败，软件包：${DEB_PATH}"

	apt-get install -f
	exit_if_fail $? "安装失败，软件包：${DEB_PATH}"


	cat <<- EOF >> /etc/autoruns/installed_sw_env.sh

		export XMODIFIERS=@im=fcitx
		export GTK_IM_MODULE=fcitx
		export QT_IM_MODULE=fcitx
		export SDL_IM_MODULE=fcitx
	EOF

	# 添加到自启动目录
	tmpfile=/etc/autoruns/autoruns_after_gui/inputmethod.desktop
	cat <<- EOF > ${tmpfile}
		[Desktop Entry]
		Name=启动输入法
		GenericName=启动输入法
		Exec=${tools_dir}/vm_start_inputmethod.sh
		Terminal=false
		Type=Application
	EOF

}

function sw_create_desktop_file() {

	cat <<- EOF > /tmp/msg.txt
		安装完成，但需要重启一次才会生效。
	EOF
	gxmessage -title "提示" -file /tmp/msg.txt -center &
}

if [ "${action}" == "卸载" ]; then
	# echo "暂不支持卸载"
	# exit 1
	rm -rf /etc/autoruns/autoruns_after_gui/inputmethod.desktop
	apt-get autoremove --purge -y huayupy
else
	sw_download
	sw_install
	sw_create_desktop_file

	# cat <<- EOF > /tmp/msg.txt
	# 	搜狗官网禁止自动下载
	# 	请使用浏览器访问 https://shurufa.sogou.com/linux
	# 	自行下载安装 ${CURRENT_VM_ARCH} 版本
	# 	下载完成后点击安装包即可安装!
	# EOF
	# gxmessage -title "提示" -file /tmp/msg.txt -center

fi

