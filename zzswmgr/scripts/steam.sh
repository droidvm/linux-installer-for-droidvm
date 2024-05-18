#!/bin/bash

: '

dpkg-deb -x  steam_latest.deb undeb

objdump -x ~/.local/share/Steam/ubuntu12_32/steamui.so | grep NEEDED
objdump -x ~/.local/share/Steam/ubuntu12_32/steam | grep NEEDED
objdump -x ~/.local/share/Steam/ubuntu12_32/steamui.so | grep NEEDED


'

SWNAME=steam
DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh

function sw_download() {
	case "${CURRENT_VM_ARCH}" in
		"arm64")

				sysvipc_function_test=`ps ax|grep 'proot --shm-helper'|grep -v grep`
				echo "sysvipc_function_test: ${sysvipc_function_test}"
				if [ "${sysvipc_function_test}" == "" ]; then
					echo ""											> /tmp/msg.txt
					echo "请先开启proot-sysvipc功能："				>>/tmp/msg.txt
					echo "步骤：开始->控制台->proot-sysvipc功能"	>>/tmp/msg.txt
					echo ""											>>/tmp/msg.txt
					gxmessage -title "提示" -file /tmp/msg.txt -center
					exit 1
				fi

				which box86 >/dev/null 2>&1
				if [ $? -ne 0 ]; then
					echo ""				> /tmp/msg.txt
					echo "请先安装box"	>>/tmp/msg.txt
					echo ""				>>/tmp/msg.txt
					gxmessage -title "提示" -file /tmp/msg.txt -center
					exit 1
				fi

				# 注意，这里要安装 【【跨CPU架构的 amd32-linux-steam】】　!!!
				DEB_PATH=./downloads/${SWNAME}.deb

				swUrl=${APP_URL_DLSERVER}/steam_latest.deb
				download_file2 "${DEB_PATH}" "${swUrl}"
				exit_if_fail $? "下载失败，网址：${swUrl}"
				;;
		"amd64")
				# echo "不需要单独下载"
				exit_unsupport
				;;
		*) exit_unsupport ;;
	esac

}

function sw_install_depends() {
	echo "正在安装32位依赖库"

	sudo apt-get install -y libc6:armhf libsdl2-2.0-0:armhf libsdl2-image-2.0-0:armhf libsdl2-mixer-2.0-0:armhf \
		libsdl2-ttf-2.0-0:armhf libopenal1:armhf libpng16-16:armhf libfontconfig1:armhf libxcomposite1:armhf \
		libbz2-1.0:armhf libxtst6:armhf libsm6:armhf libice6:armhf libgl1:armhf libxinerama1:armhf libxdamage1:armhf \
		libappindicator1:armhf \
		 libncurses6:armhf
		#libncurses5:armhf
		exit_if_fail $? "32位依赖库安装失败"
}

function sw_install() {
	case "${CURRENT_VM_ARCH}" in
		"arm64")
				sudo apt-get install -y xz-utils file xterm gnome-terminal konsole zenity  libappindicator1
				exit_if_fail $? "依赖工具安装失败"


				# echo "正在解压跨CPU架构的wine32/64. . ."
				# # tar -xJf ${DEB_PATH} --overwrite -C /opt/apps/
				# dpkg-deb -x  ${DEB_PATH} ./tmp/undeb_${SWNAME}
				# exit_if_fail $? "解压失败，软件包：${DEB_PATH}"

				echo "正在启用 multi-arch ..."
				dpkg --add-architecture armhf && sudo apt-get update
				exit_if_fail $? "multi-arch 多CPU架构功能启用失败"

				echo "正在安装"
				sudo dpkg -i ${DEB_PATH}
				exit_if_fail $? "deb包安装失败"

				sw_install_depends


				rm -rf ~/.local/share/Steam
				sudo -u ${ZZ_USER_NAME} box86 steam
				exit_if_fail $? "steam升级失败"

				mv -f /usr/bin/steam /usr/bin/steam_old
				echo '#!/bin/bash'									> ./tmp/steam
				echo "export STEAMOS=1"								>>./tmp/steam
				echo "export STEAM_RUNTIME=1"						>>./tmp/steam
				echo "export DBUS_FATAL_WARNINGS=0"					>>./tmp/steam
				echo "exec /usr/local/bin/box86 ~/.local/share/Steam/ubuntu12_32/steam"	>>./tmp/steam
				mv -f ./tmp/steam  /usr/bin/
				chmod 755 /usr/bin/steam

				echo "在命令行也可以通过如下指令运行steam："
				echo "export BOX86_LOG=1"
				echo "steam"

				# libappindicator.so.1, libtier0_s.so
				# 查询so文件属于哪个包: apt-file search libappindicator.so
				;;
		"amd64")
				# sudo apt-get install -y wine
				false
				exit_if_fail $? "amd64版安装失败"
				;;
		*) exit_unsupport ;;
	esac
}

function sw_create_desktop_file() {
	case "${CURRENT_VM_ARCH}" in
		"arm64")
				rm2desktop wine32.desktop
				rm2desktop wine64.desktop
				rm -rf /usr/share/applications/wine32.desktop
				rm -rf /usr/share/applications/wine64.desktop
				rm -rf /usr/bin/exec32
				rm -rf /usr/bin/exec64
				rm -rf /usr/bin/wine
				rm -rf /usr/bin/wineboot
				rm -rf /usr/bin/winecfg
				rm -rf /usr/bin/wineserver
				ln -s ${app_dir}/bin/wineboot		/usr/bin/wineboot
				ln -s ${app_dir}/bin/winecfg		/usr/bin/winecfg
				ln -s ${app_dir}/bin/wineserver	/usr/bin/wineserver

				# export app_dir=/opt/apps/wine-8.9-amd64
				echo '#!/bin/bash'																								> ./tmp/exec64
				echo "export WINEARCH=win64"																					>>./tmp/exec64
				echo "export WINEPREFIX=\${HOME}/.wine64"																		>>./tmp/exec64
				echo "    echo \"WINEPREFIX=\${WINEPREFIX}\", 64位"																>>./tmp/exec64
				echo "whoami"																									>>./tmp/exec64
				echo 'if [ $# -eq 0 ]; then'																					>>./tmp/exec64
				echo "    exec /usr/local/bin/box64 ${app_dir}/bin/wine64 explorer"												>>./tmp/exec64
				echo 'else'																										>>./tmp/exec64
				echo "    exec /usr/local/bin/box64 ${app_dir}/bin/wine64 \$@"													>>./tmp/exec64
				echo 'fi'																										>>./tmp/exec64


				echo '#!/bin/bash'																								> ./tmp/exec32
				echo "export WINEARCH=win32"																					>>./tmp/exec32
				echo "export WINEPREFIX=\${HOME}/.wine32"																		>>./tmp/exec32
				echo "    echo \"WINEPREFIX=\${WINEPREFIX}\", 32位"																>>./tmp/exec32
				echo "whoami"																									>>./tmp/exec32
				echo 'if [ $# -eq 0 ]; then'																					>>./tmp/exec32
				echo "    exec /usr/local/bin/box86 ${app_dir}/bin/wine explorer"												>>./tmp/exec32
				echo 'else'																										>>./tmp/exec32
				echo "    exec /usr/local/bin/box86 ${app_dir}/bin/wine \$@"													>>./tmp/exec32
				echo 'fi'																										>>./tmp/exec32

				mv -f ./tmp/exec64  /usr/bin/
				chmod 755 /usr/bin/exec64
				# ln -s /usr/bin/exec64	/usr/bin/wine

				mv -f ./tmp/exec32  /usr/bin/
				chmod 755 /usr/bin/exec32
				# ln -s /usr/bin/exec32	/usr/bin/wine
				# ln -s /usr/bin/exec64	/usr/bin/wine

				# echo "为了能运行 winecfg, 需要设置 WINELOADER 环境变量"
				# echo "export WINELOADER=/usr/bin/exec64"	>>/etc/profile
				# source /etc/profile

				tmpfile=${DIR_DESKTOP_FILES}/wine32.desktop
				echo "[Desktop Entry]"	> ${tmpfile}
				echo "Encoding=UTF-8"	>>${tmpfile}
				echo "Version=0.9.4"	>>${tmpfile}
				echo "Type=Application"	>>${tmpfile}
				echo "Categories=System">>${tmpfile}
				echo "MimeType=application/x-dosexec;application/x-ms-dos-executable;application/x-ms-shortcut;application/x-msi;application/vnd.microsoft.portable-executable"	>>${tmpfile}
				echo "Name=wine32"		>>${tmpfile}
				echo "Exec=exec32 %f"	>> ${tmpfile}
				cp2desktop ${tmpfile}


				tmpfile=${DIR_DESKTOP_FILES}/wine64.desktop
				echo "[Desktop Entry]"	> ${tmpfile}
				echo "Encoding=UTF-8"	>>${tmpfile}
				echo "Version=0.9.4"	>>${tmpfile}
				echo "Type=Application"	>>${tmpfile}
				echo "Categories=System">>${tmpfile}
				echo "MimeType=application/x-dosexec;application/x-ms-dos-executable;application/x-ms-shortcut;application/x-msi;application/vnd.microsoft.portable-executable"	>>${tmpfile}
				echo "Name=wine64"		>>${tmpfile}
				echo "Exec=exec64 %f"	>> ${tmpfile}
				cp2desktop ${tmpfile}



				if [ "${APP_LANGUAGE}_${APP_COUNTRY}" == "zh_CN" ]; then
					echo "正在复制中文字体"

					mkdir -p /home/droidvm/.wine32/drive_c/windows/Fonts
					mkdir -p /home/droidvm/.wine64/drive_c/windows/Fonts
					cp -f /usr/share/fonts/truetype/droid/NotoSansCJK-Regular.ttc /home/droidvm/.wine32/drive_c/windows/Fonts/simsun.ttc
					cp -f /usr/share/fonts/truetype/droid/NotoSansCJK-Regular.ttc /home/droidvm/.wine64/drive_c/windows/Fonts/simsun.ttc

					# "Droid Sans Fallback" 或者 "Noto Sans Mono CJK SC" 和 dpi
					cat <<- EOF >  ./tmp/wine_init_config.reg
					REGEDIT4
					[HKEY_CURRENT_USER\Software\Wine\Fonts\Replacements]
					"DFKai-SB"="Noto Sans Mono CJK SC"
					"FangSong"="Noto Sans Mono CJK SC"
					"KaiTi"="Noto Sans Mono CJK SC"
					"Microsoft JhengHei"="Noto Sans Mono CJK SC"
					"Microsoft YaHei"="Noto Sans Mono CJK SC"
					"MingLiU"="Noto Sans Mono CJK SC"
					"NSimSun"="Noto Sans Mono CJK SC"
					"PMingLiU"="Noto Sans Mono CJK SC"
					"SimHei"="Noto Sans Mono CJK SC"
					"SimKai"="Noto Sans Mono CJK SC"
					"SimSun"="Noto Sans Mono CJK SC"

					[HKEY_LOCAL_MACHINE\System\CurrentControlSet\Hardware Profiles\Current\Software\Fonts]
					"LogPixels"=dword:00000096
					EOF
					cp -f  ./tmp/wine_init_config.reg /home/droidvm/.wine32/drive_c/wine_init_config.reg
					cp -f  ./tmp/wine_init_config.reg /home/droidvm/.wine64/drive_c/wine_init_config.reg
					sudo -u ${ZZ_USER_NAME} exec32 regedit ./tmp/wine_init_config.reg
					exit_if_fail $? "wine32 中文字体导入失败"

					sudo -u ${ZZ_USER_NAME} exec64 regedit ./tmp/wine_init_config.reg
					exit_if_fail $? "wine64 中文字体导入失败"

					rm -rf ./tmp/wine_init_config.reg
				else
					echo "非中文语言"

					# 调整dpi
					cat <<- EOF >  ./tmp/wine_init_config.reg
					REGEDIT4
					[HKEY_LOCAL_MACHINE\System\CurrentControlSet\Hardware Profiles\Current\Software\Fonts]
					"LogPixels"=dword:00000096
					EOF
					cp -f  ./tmp/wine_init_config.reg /home/droidvm/.wine32/drive_c/wine_init_config.reg
					cp -f  ./tmp/wine_init_config.reg /home/droidvm/.wine64/drive_c/wine_init_config.reg
					sudo -u ${ZZ_USER_NAME} exec32 regedit ./tmp/wine_init_config.reg
					exit_if_fail $? "wine32 dpi设置失败"

					sudo -u ${ZZ_USER_NAME} exec64 regedit ./tmp/wine_init_config.reg
					exit_if_fail $? "wine64 dpi设置失败"

					rm -rf ./tmp/wine_init_config.reg
				fi



				echo "请使用 exec32/exec64 指令运行windows程序, 比如:"
				echo "exec64 cmd"
				echo "exec64 explorer"
				echo "exec64 taskmgr"
				echo "exec64 winecfg"

				echo "wine配置程序："
				echo "exec64 winecfg"
				;;
		"amd64")
				# todo
				echo "桌面快捷方式待创建。。。"
				;;
		*) exit_unsupport ;;
	esac
}

if [ "${action}" == "卸载" ]; then
	echo "暂不支持卸载"
	exit 1
else
	sw_download
	sw_install
	# sw_create_desktop_file
fi
