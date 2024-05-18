#!/bin/bash

SWNAME=chrome
SWVER=${tmp_version}

DEB_PATH1=./downloads/${SWNAME}-ffmpeg-extra.deb
DEB_PATH2=./downloads/${SWNAME}-chromium.deb
DEB_PATH3=./downloads/${SWNAME}-l10n.deb

DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh

function sw_download() {
	case "${CURRENT_VM_ARCH}" in
		"arm64")
			PPA_URL=https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/pool/universe/c/chromium-browser/

			# tmp_version=107.0.5304.62
			# tmp_version="90.0.4430.72-0ubuntu0.16.04.1"
			tmp_version="112.0.5615.49-0ubuntu0.18.04.1"

			fn1="chromium-browser_${tmp_version}_arm64.deb"
			fn2="chromium-browser-l10n_${tmp_version}_all.deb"
			fn3="chromium-codecs-ffmpeg-extra_${tmp_version}_arm64.deb"
			fn4="chromium-codecs-ffmpeg_${tmp_version}_arm64.deb"

			swUrl="${PPA_URL}/${fn1}"
			download_file2 "${DEB_PATH1}" "${swUrl}"
			exit_if_fail $? "下载失败，网址：${swUrl}"

			swUrl="${PPA_URL}/${fn2}"
			download_file2 "${DEB_PATH2}" "${swUrl}"
			exit_if_fail $? "下载失败，网址：${swUrl}"

			swUrl="${PPA_URL}/${fn3}"
			download_file2 "${DEB_PATH3}" "${swUrl}"
			exit_if_fail $? "下载失败，网址：${swUrl}"
		;;
		"amd64")
			PPA_URL=https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/pool/universe/c/chromium-browser/

			# tmp_version=108.0.5359.40
			tmp_version="112.0.5615.49-0ubuntu0.18.04.1"

			fn1="chromium-browser_${tmp_version}_amd64.deb"
			fn2="chromium-browser-l10n_${tmp_version}_all.deb"
			fn3="chromium-codecs-ffmpeg-extra_${tmp_version}_amd64.deb"
			fn4="chromium-codecs-ffmpeg_${tmp_version}_amd64.deb"

			swUrl="${PPA_URL}/${fn1}"
			download_file2 "${DEB_PATH1}" "${swUrl}"
			exit_if_fail $? "下载失败，网址：${swUrl}"

			swUrl="${PPA_URL}/${fn2}"
			download_file2 "${DEB_PATH2}" "${swUrl}"
			exit_if_fail $? "下载失败，网址：${swUrl}"

			swUrl="${PPA_URL}/${fn3}"
			download_file2 "${DEB_PATH3}" "${swUrl}"
			exit_if_fail $? "下载失败，网址：${swUrl}"
		;;
		*) exit_unsupport ;;
	esac


	# https://packages.tmoe.me/chromium-dev/ubuntu/pool/main/c/chromium-browser/chromium-browser_${tmp_version}-0ubuntu1~ppa1~22.10.1_amd64.deb
	# https://packages.tmoe.me/chromium-dev/ubuntu/pool/main/c/chromium-browser/chromium-codecs-ffmpeg-extra_${tmp_version}-0ubuntu1~ppa1~22.10.1_amd64.deb
	# https://packages.tmoe.me/chromium-dev/ubuntu/pool/main/c/chromium-browser/chromium-browser-l10n_${tmp_version}-0ubuntu1~ppa1~22.10.1_all.deb

}

function sw_install() {

	sudo apt-get install -y libva2 \
	${ZZSWMGR_MAIN_DIR}/${DEB_PATH1} \
	${ZZSWMGR_MAIN_DIR}/${DEB_PATH2} \
	${ZZSWMGR_MAIN_DIR}/${DEB_PATH3}
	exit_if_fail $? "安装失败"

	# if [ ! -e "/usr/share/doc/libva2/copyright" ]; then
	# 	apt-get install -y libva2
	# 	exit_if_fail $? "依赖包安装失败"
	# fi

	# # DEB_PATH=${DEB_PATH1}
	# # install_deb ${DEB_PATH}
	# # exit_if_fail $? "安装失败，软件包：${DEB_PATH}"

	# # DEB_PATH=${DEB_PATH2}
	# # install_deb ${DEB_PATH}
	# # exit_if_fail $? "安装失败，软件包：${DEB_PATH}"

	# # DEB_PATH=${DEB_PATH3}
	# # install_deb ${DEB_PATH}

	# install_deb ${DEB_PATH1} ${DEB_PATH2} ${DEB_PATH3}
	# exit_if_fail $? "安装失败，软件包：${DEB_PATH}"

	# # apt-get --fix-broken install -y
	# # exit_if_fail $? "安装失败"

	rm -rf ${DIR_DESKTOP_FILES}/chromium-browser.desktop

}

function sw_create_desktop_file() {
# TMP_BIN_FILE=/usr/bin/chromium-browser-nosandbox
# cat <<- EOF > ${TMP_BIN_FILE}
# #!/bin/bash

# # enable virgl
# # GALLIUM_DRIVER=virpipe MESA_GL_VERSION_OVERRIDE=4.0 exec /usr/bin/chromium-browser --no-sandbox "\$@"

# exec /usr/bin/chromium-browser --no-sandbox "\$@"
# EOF
# chmod 755 ${TMP_BIN_FILE}

	# STARTUP_SCRIPT_FILE=${app_dir}/${SWNAME}
	STARTUP_SCRIPT_FILE=/usr/bin/${SWNAME}
	cat <<- EOF > ${STARTUP_SCRIPT_FILE}
		#!/bin/bash

		# enable virgl
		# GALLIUM_DRIVER=virpipe MESA_GL_VERSION_OVERRIDE=4.0 exec /usr/bin/chromium-browser --no-sandbox "\$@"

		exec /usr/bin/chromium-browser --no-sandbox --gtk-version=2 "\$@"
	EOF
	chmod a+x ${STARTUP_SCRIPT_FILE}

cat <<- EOF > ${DSK_PATH}
[Desktop Entry]
Version=1.0
Name=Chrome
GenericName=Web Browser
Exec=${SWNAME} www.baidu.com
Terminal=false
X-MultipleArgs=false
Type=Application
Icon=chromium-browser
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml_xml;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
Actions=NewWindow;Incognito;TempProfile
X-AppInstall-Package=chromium-browser

[Desktop Action NewWindow]
Name=Open a New Window
Exec=${SWNAME} www.baidu.com

[Desktop Action Incognito]
Name=Open a New Window in incognito mode
Exec=${SWNAME} --incognito www.baidu.com

[Desktop Action TempProfile]
Name=Open a New Window with a temporary profile
Exec=${SWNAME} --temp-profile www.baidu.com
EOF
	cp2desktop ${DSK_PATH}
	cp -rf  ${DSK_PATH} ${DIR_DESKTOP_FILES}/chromium-browser.desktop

	# update-alternatives --display x-www-browser
	# update-alternatives --config x-www-browser
	# ls -l /usr/bin/x-www-browser
	# ln -sf /usr/bin/chrome /etc/alternatives/x-www-browser
	# xdg-settings get default-web-browser

	# 用于命令行下 open https://www.***.com
	sudo update-alternatives --remove x-www-browser /usr/bin/chromium-browser
	sudo update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/${SWNAME} 210
	sudo update-alternatives --set x-www-browser /usr/bin/${SWNAME}
	sudo ln -sf /usr/bin/${SWNAME} /etc/alternatives/x-www-browser

	# 这个可以让chrome不再显示“不是您的默认浏览器”
	sudo -u ${ZZ_USER_NAME} xdg-settings set default-web-browser chromium-browser.desktop

	gxmessage -title "提示"     $'\n安装完成\n请在桌面上的软件目录中打开chrome\n大陆无法使用google搜索，打开浏览器后请切换默认的搜索引擎\n\n'  -center        # 一定要是单引号

	if [ -f ./scripts/res/chrome.pref/Bookmarks ]; then
		sudo -u ${ZZ_USER_NAME} mkdir -p ${ZZ_USER_HOME}/.config/chromium/Default
		sudo -u ${ZZ_USER_NAME} cp -f ./scripts/res/chrome.pref/Bookmarks ${ZZ_USER_HOME}/.config/chromium/Default/Bookmarks
	fi

	if [ -f ./scripts/res/chrome.pref/Preferences ]; then
		sudo -u ${ZZ_USER_NAME} mkdir -p ${ZZ_USER_HOME}/.config/chromium/Default
		sudo -u ${ZZ_USER_NAME} cp -f ./scripts/res/chrome.pref/Preferences ${ZZ_USER_HOME}/.config/chromium/Default/Preferences
	fi

}

if [ "${action}" == "卸载" ]; then
	apt-get remove chromium-browser chromium-browser-l10n chromium-codecs-ffmpeg chromium-codecs-ffmpeg-extra
else
	sw_download
	sw_install
	sw_create_desktop_file
fi
