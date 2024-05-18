#!/bin/bash

SWNAME=fcitx5
DIR_DESKTOP_FILES=/usr/share/applications

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh

PKGS="fcitx5 fcitx5-chinese-addons libime-bin fcitx5-frontend-gtk3 fcitx5-frontend-gtk2 fcitx5-frontend-qt5 kde-config-fcitx5 fcitx5-frontend-all"

# sudo apt install -y -o APT::Install-Suggests=true fcitx5-frontend-all


if [ "${action}" == "卸载" ]; then
	rm -rf /etc/autoruns/autoruns_after_gui/inputmethod.desktop
	# sudo apt-get remove -y ${SWNAME}fcitx5-gtk
	apt-get autoremove --purge -y ${PKGS}
else
	sudo apt-get install -y ${PKGS}
	exit_if_fail $? "安装失败"

	cp -Rf ./ezapp/fcitx5_dict_import_tool /opt/apps/
	exit_if_fail $? "安装失败，无法复制词库导入工具到 /opt/apps/"

	chmod 755 /opt/apps/fcitx5_dict_import_tool/*.py

	# 输入面板的主题/显示风格
	# swUrl=https://gitee.com/wangzewenxi/fcitx5-sogou-themes
	# download_file3 "./tmp/fcitx5_theme" "${swUrl}"
	# ~/.local/share/fcitx5/themes/


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

	cat <<- EOF >> /etc/autoruns/installed_sw_env.sh

		export XIM_PROGRAM=fcitx
		export XIM=fcitx5
		export XMODIFIERS=@im=fcitx5
		export GTK_IM_MODULE=fcitx5
		export QT_IM_MODULE=fcitx5
		export SDL_IM_MODULE=fcitx5
		export GLFW_IM_MODULE=fcitx5
		export DefaultIMModule=fcitx5
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

	tmpfile=${DIR_DESKTOP_FILES}/fcitx5DI.desktop
	cat <<- EOF > ${tmpfile}
		[Desktop Entry]
		Name=拼音词库
		GenericName=拼音词库
		Exec=/opt/apps/fcitx5_dict_import_tool/fcitx5DI.py
		Terminal=false
		Type=Application
		Icon=/opt/apps/fcitx5_dict_import_tool/ic_imphrasetool.png
	EOF
	cp2desktop ${tmpfile}

	gxmessage -title "提示" "安装已完成，但需要重启一次才能运行刚刚安装的输入法"  -center &
fi
