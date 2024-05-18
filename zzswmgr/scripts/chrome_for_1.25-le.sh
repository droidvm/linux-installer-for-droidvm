#!/bin/bash

SWNAME=chrome2
SWVER=${tmp_version}
PPA_URL=https://packages.tmoe.me/chromium-dev/ubuntu/pool/main/c/chromium-browser

# 注意安装顺序，后装者依赖前装者
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
			tmp_version=107.0.5304.62
			swUrl="${PPA_URL}/chromium-browser_${tmp_version}-0ubuntu1~ppa1~22.10.1_arm64.deb"
			swUrl="${APP_URL_DLSERVER}/chrome-arm64-chromium.deb"
			download_file2 "${DEB_PATH1}" "${swUrl}"
			exit_if_fail $? "下载失败，网址：${swUrl}"

			swUrl="${PPA_URL}/chromium-codecs-ffmpeg-extra_${tmp_version}-0ubuntu1~ppa1~22.10.1_arm64.deb"
			swUrl="${APP_URL_DLSERVER}/chrome-arm64-ffmpeg-extra.deb"
			download_file2 "${DEB_PATH2}" "${swUrl}"
			exit_if_fail $? "下载失败，网址：${swUrl}"

			swUrl="${PPA_URL}/chromium-browser-l10n_${tmp_version}-0ubuntu1~ppa1~22.10.1_all.deb"
			swUrl="${APP_URL_DLSERVER}/chrome-arm64-l10n.deb"
			download_file2 "${DEB_PATH3}" "${swUrl}"
			exit_if_fail $? "下载失败，网址：${swUrl}"
		;;
		"amd64")
			tmp_version=108.0.5359.40
			swUrl="${PPA_URL}/chromium-browser_${tmp_version}-0ubuntu1~ppa1~22.10.1_amd64.deb"
			swUrl="${APP_URL_DLSERVER}/chrome-amd64-chromium.deb"
			download_file2 "${DEB_PATH1}" "${swUrl}"
			exit_if_fail $? "下载失败，网址：${swUrl}"

			swUrl="${PPA_URL}/chromium-codecs-ffmpeg-extra_${tmp_version}-0ubuntu1~ppa1~22.10.1_amd64.deb"
			swUrl="${APP_URL_DLSERVER}/chrome-amd64-ffmpeg-extra.deb"
			download_file2 "${DEB_PATH2}" "${swUrl}"
			exit_if_fail $? "下载失败，网址：${swUrl}"

			swUrl="${PPA_URL}/chromium-browser-l10n_${tmp_version}-0ubuntu1~ppa1~22.10.1_all.deb"
			swUrl="${APP_URL_DLSERVER}/chrome-amd64-l10n.deb"
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
	if [ ! -e "/usr/share/doc/libva2/copyright" ]; then
		apt-get install -y libva2
		exit_if_fail $? "依赖包安装失败"
	fi

	# DEB_PATH=${DEB_PATH1}
	# install_deb ${DEB_PATH}
	# exit_if_fail $? "安装失败，软件包：${DEB_PATH}"

	# DEB_PATH=${DEB_PATH2}
	# install_deb ${DEB_PATH}
	# exit_if_fail $? "安装失败，软件包：${DEB_PATH}"

	# DEB_PATH=${DEB_PATH3}
	# install_deb ${DEB_PATH}

	install_deb ${DEB_PATH1} ${DEB_PATH2} ${DEB_PATH3}
	exit_if_fail $? "安装失败，软件包：${DEB_PATH}"

	# apt-get --fix-broken install -y
	# exit_if_fail $? "安装失败"

	rm -rf ${DIR_DESKTOP_FILES}/chromium-browser.desktop

}

function sw_create_desktop_file() {
TMP_BIN_FILE=/usr/bin/chromium-browser-nosandbox
cat <<- EOF > ${TMP_BIN_FILE}
#!/bin/bash

# enable virgl
# GALLIUM_DRIVER=virpipe MESA_GL_VERSION_OVERRIDE=4.0 exec /usr/bin/chromium-browser --no-sandbox "\$@"

exec /usr/bin/chromium-browser --no-sandbox "\$@"
EOF
chmod 755 ${TMP_BIN_FILE}

cat <<- EOF > ${DSK_PATH}
[Desktop Entry]
Version=1.0
Name=Chrome2
GenericName=Web Browser
Exec=/usr/bin/chromium-browser-nosandbox %U
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
Exec=/usr/bin/chromium-browser-nosandbox %U

[Desktop Action Incognito]
Name=Open a New Window in incognito mode
Exec=/usr/bin/chromium-browser-nosandbox --incognito %U

[Desktop Action TempProfile]
Name=Open a New Window with a temporary profile
Exec=/usr/bin/chromium-browser-nosandbox --temp-profile %U
EOF
	cp2desktop ${DSK_PATH}

	update-alternatives --set x-www-browser ${TMP_BIN_FILE}
	xdg-settings set default-web-browser ${DSK_FILE}

	gxmessage -title "提示"     $'\n安装完成\n请在桌面上的软件目录中打开chrome\n大陆无法使用google搜索，打开浏览器后请切换默认的搜索引擎\n\n'  -center        # 一定要是单引号


}

if [ "${action}" == "卸载" ]; then
	apt-get remove chromium-browser chromium-browser-l10n chromium-codecs-ffmpeg chromium-codecs-ffmpeg-extra
else
	sw_download
	sw_install
	sw_create_desktop_file
fi
