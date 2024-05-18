#!/bin/bash

: '



'

SWNAME=steam-win32
DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh

function sw_download() {
	case "${CURRENT_VM_ARCH}" in
		"arm64")

				which box86 >/dev/null 2>&1
				if [ $? -ne 0 ]; then
					echo ""				> /tmp/msg.txt
					echo "请先安装box"	>>/tmp/msg.txt
					echo ""				>>/tmp/msg.txt
					gxmessage -title "提示" -file /tmp/msg.txt -center
					exit 1
				fi

				which exec32 >/dev/null 2>&1
				if [ $? -ne 0 ]; then
					echo ""				> /tmp/msg.txt
					echo "请先安装wine"	>>/tmp/msg.txt
					echo ""				>>/tmp/msg.txt
					gxmessage -title "提示" -file /tmp/msg.txt -center
					exit 1
				fi

				# 注意，这里要安装 【【跨CPU架构的 amd32-linux-steam】】　!!!
				DEB_PATH=./downloads/${SWNAME}.deb

				swUrl=${APP_URL_DLSERVER}/SteamSetup.exe
				swUrl=https://media.st.dl.eccdnx.com/client/installer/SteamSetup.exe
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

function sw_install() {
	case "${CURRENT_VM_ARCH}" in
		"arm64")
				sudo -u ${ZZ_USER_NAME} exec32 "${DEB_PATH}"
				exit_if_fail $? "steam安装失败"
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
				rm2desktop steam-win32.desktop
				rm -rf /usr/share/applications/steam-win32.desktop

				echo '#!/bin/bash'									> ./tmp/steam-win32
				echo "cd ~/\".wine32/drive_c/Program Files/Steam\""	>>./tmp/steam-win32
				echo "exec exec32 steam.exe"						>>./tmp/steam-win32

				mv -f ./tmp/steam-win32  /usr/bin/
				chmod 755 /usr/bin/steam-win32

				tmpfile=${DIR_DESKTOP_FILES}/steam-win32.desktop
				echo "[Desktop Entry]"	> ${tmpfile}
				echo "Encoding=UTF-8"	>>${tmpfile}
				echo "Version=0.9.4"	>>${tmpfile}
				echo "Type=Application"	>>${tmpfile}
				echo "Categories=Game">>${tmpfile}
				echo "Name=steam-win32"	>>${tmpfile}
				echo "Exec=steam-win32"	>> ${tmpfile}
				cp2desktop ${tmpfile}

				echo "steam-win32 安装完成"
				gxmessage -title "提示" "安装已完成，但要等steam升级完后才能运行"  -center
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
	sw_create_desktop_file
fi
