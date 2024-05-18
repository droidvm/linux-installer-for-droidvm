#!/bin/bash

SWNAME=fcitx-table-wbpy

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh

if [ "${action}" == "卸载" ]; then
	rm -rf /etc/autoruns/autoruns_after_gui/inputmethod.desktop
	# sudo apt-get remove -y ${SWNAME}
	apt-get autoremove --purge -y ${SWNAME}
	sudo apt purge --autoremove fcitx-table-wbpy
	sudo apt purge --autoremove fcitx
	sudo apt purge --autoremove fcitx-bin
else

	command -v fcitx5
	if [ $? -eq 0 ]; then
		gxmessage -title "软件冲突"     $'\n软件冲突，安装失败\n系统中已安装过fcitx5系列的输入法\n与当前正在安装的fcitx4系列输入冲突\n请先卸载fcitx5系列的输入法\n\n'  -center
		exit 2
	fi

	sudo apt-get install -y --allow-downgrades ${SWNAME} ${ZZSWMGR_MAIN_DIR}/scripts/res/fcitx-tools_4.2.9.9-1_arm64.deb   # fcitx-tools
	exit_if_fail $? "安装失败"

	# tar -xzf ${ZZSWMGR_MAIN_DIR}/scripts/res/fcitx-tools_4.2.9.9-1_arm64.tar.gz  -C /usr/bin/
	# exit_if_fail $? "工具释放失败: fcitx-tools_4.2.9.9-1_arm64.tar.gz"

	cp -Rf ./ezapp/fcitx5_dict_import_tool /opt/apps/
	exit_if_fail $? "安装失败，无法复制词库导入工具到 /opt/apps/"

	chmod 755 /opt/apps/fcitx5_dict_import_tool/*.py

	echo "正在下载拼音输入的基础词库. . ."
	PYDATA_PATH=./downloads/pinyin-data.tar.gz
	# swUrl=${APP_URL_DLSERVER}/pinyin-data.tar.gz
	swUrl="https://gitee.com/droidvm/fcitx4-pinyin-data/releases/download/v0.01/pinyin-data.tar.gz"
	download_file2 "${PYDATA_PATH}" "${swUrl}"
	exit_if_fail $? "下载失败，网址：${swUrl}"

	echo "正在解压拼音输入的基础词库. . ."
	mkdir -p /opt/apps/fcitx5_dict_import_tool/pinyin-data 2>/dev/null
	tar -xzf ${PYDATA_PATH} --overwrite -C /opt/apps/fcitx5_dict_import_tool/pinyin-data
	exit_if_fail $? "安装失败，软件包：${PYDATA_PATH}"



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
		export XIM=fcitx
		export XMODIFIERS=@im=fcitx
		export GTK_IM_MODULE=fcitx
		export QT_IM_MODULE=fcitx
		export SDL_IM_MODULE=fcitx
		export GLFW_IM_MODULE=fcitx
		export DefaultIMModule=fcitx
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


	gxmessage -title "提示" "安装已完成，但需要重启一次才能运行刚刚安装的输入法"  -center &
fi
