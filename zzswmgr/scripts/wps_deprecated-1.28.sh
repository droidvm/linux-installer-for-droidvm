#!/bin/bash

SWNAME=wps
DEB_PATH=./downloads/${SWNAME}.deb
FT_PATH1=./downloads/ttf-wps-fonts.tar.xz
DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh

function sw_download() {

	# echo "204.68.111.105 downloads.sourceforge.net" >> /etc/hosts
	tmpdns=`cd /exbin && droidexec ./vm_getHostByName.sh downloads.sourceforge.net linux.wps.cn`
	exit_if_fail $? "DNS解析失败"
	echo "$tmpdns" >> /etc/hosts

	echo "下载脚本的录制指令："
	echo "/exbin/tools/zzswmgr/ezapp/zzllq/bin/python -m playwright codegen --target python -o 'dl_script.py' -b chromium https://linux.wps.cn"

	cat << EOF > ./tmp/msg.html
	请不要操作，正在下载安装包，下载完成后浏览器会自动关闭，仅仅是响应稍微有点慢
EOF

	case "${CURRENT_VM_ARCH}" in
		"arm64")

cat << EOF > ./tmp/dl_wps_via_playwright.py
from playwright.sync_api import Playwright, sync_playwright, expect


def run(playwright: Playwright) -> None:
    browser = playwright.chromium.launch(headless=False)
    context = browser.new_context()
    page = context.new_page()
    page.goto("https://linux.wps.cn/")
    page.get_by_role("link", name="立即下载").click()
    with page.expect_download() as download_info:
        page.get_by_role("link", name="For ARM").first.click()
    download = download_info.value

    # 下载文件
    print(download.path())
    print(download.url)

    name = download.suggested_filename # get suggested name
    file = f"${DEB_PATH}" # ./downloads/{name}" # file path
    download.save_as(file) # download file

    page.close()

    # ---------------------
    context.close()
    browser.close()


with sync_playwright() as playwright:
    run(playwright)
EOF
			
			;;
		"amd64")

cat << EOF > ./tmp/dl_wps_via_playwright.py
from playwright.sync_api import Playwright, sync_playwright, expect


def run(playwright: Playwright) -> None:
    browser = playwright.chromium.launch(headless=False)
    context = browser.new_context()
    page = context.new_page()
    page.goto("https://linux.wps.cn/")
    page.get_by_role("link", name="立即下载").click()
    with page.expect_download() as download_info:
        page.get_by_role("link", name="For X64").first.click()
    download = download_info.value

    # 下载文件
    print(download.path())
    print(download.url)

    name = download.suggested_filename # get suggested name
    file = f"${DEB_PATH}" # ./downloads/{name}" # file path
    download.save_as(file) # download file

    page.close()

    # ---------------------
    context.close()
    browser.close()


with sync_playwright() as playwright:
    run(playwright)
EOF

			;;
		*) exit_unsupport ;;
	esac


	if [ ! -f ${DEB_PATH} ]; then

		gxmessage -title "是否要自动下载 ${SWNAME} 安装包？" $'\n自动下载需要先安装chrome-爬虫版\n\n'  -center -buttons "选择安装包:0,自动下载:1,取消安装:2"
		case "$?" in
			"0")
				if [ -d /home/${ZZ_USER_NAME}/Downloads ]; then
					deb_user=$(cd /home/${ZZ_USER_NAME}/Downloads && yad --width=800 --height=400  --title="请选择您下载的wps安装包" --file-selection --center)
				else
					deb_user=$(cd /home/${ZZ_USER_NAME}/          && yad --width=800 --height=400  --title="请选择您下载的wps安装包" --file-selection --center)
				fi
				if [ "${deb_user}" == "" ]; then
					echo "您已取消安装"
					exit 1
				fi

				cp -f ${deb_user} ${DEB_PATH}
				exit_if_fail $? "无法复制您安装包"
				;;
			"1")
				which chrome >/dev/null 2>&1
				if [ $? -ne 0 ]; then
					echo ""									> /tmp/msg.txt
					echo "需通过chrome爬虫版下载wps安装包"	>>/tmp/msg.txt
					echo "请先在软件管家中安装chrome"		>>/tmp/msg.txt
					echo ""									>>/tmp/msg.txt
					gxmessage -title "提示" -file /tmp/msg.txt -center
					exit 1
				fi

				if [ ! -x ${ZZSWMGR_MAIN_DIR}/ezapp/zzllq/bin/python ] ; then
					echo ""									> /tmp/msg.txt
					echo "需通过chrome爬虫版下载wps安装包"	>>/tmp/msg.txt
					echo "请先在软件管家中安装chrome"		>>/tmp/msg.txt
					echo ""									>>/tmp/msg.txt
					gxmessage -title "提示" -file /tmp/msg.txt -center
					exit 1
				fi

				gxmessage -title "提示" $'\n即将打开浏览器并自动下载安装包\n下载完成浏览器会自动关闭\n\n安装完成前请您不要操作！\n\n'  -center -buttons "我知道了:0,取消安装:1"
				if [ $? -ne 0 ]; then
					echo "您已取消安装"
					exit 1
				fi

				sudo -u ${ZZ_USER_NAME} ${ZZSWMGR_MAIN_DIR}/ezapp/zzllq/bin/python ./tmp/dl_wps_via_playwright.py
				if [ $? -ne 0 ]; then
					echo "wps安装包下载失败"
					rm -rf ${DEB_PATH}
					false
					exit_if_fail $? "下载失败"
				fi
				;;
			*) 
				echo "您已取消安装"
				exit 1
				;;
		esac

	else
		echo "已下载过wps安装包"
	fi

	# download_file_axel "${DEB_PATH}" "${swUrl}"
	# exit_if_fail $? "下载失败(WPS官方禁止自动下载)，您可前往wps官网手动下载安装：https://linux.wps.cn/"

	# 下载必须的字体
	swUrl=https://gitee.com/ak2/ttf-wps-fonts/raw/master/ttf-wps-fonts.tar.xz
	download_file_axel "${FT_PATH1}" "${swUrl}"
	exit_if_fail $? "下载失败，网址：${swUrl}"

	# # 下载必须的字体
	# swUrl=https://gitee.com/ak2/msttcorefonts/raw/master/msttcorefonts.tar.xz
	# download_file2 "${FT_PATH2}" "${swUrl}"
	# exit_if_fail $? "下载失败，网址：${swUrl}"
}

function sw_install() {
	# hard code patch for wps-aarch64 reinstall operation
	if [ -f /usr/share/applications/wps-office-wps.desktop ]; then
		echo "检测到您正在重新安装wps，为避免wps.postinst 出错，此处加了hard code"
		cp -f /usr/share/applications/wps-office-wps.desktop	/usr/share/applications/wps-office-wps-aarch64.desktop
		cp -f /usr/share/applications/wps-office-et.desktop		/usr/share/applications/wps-office-et-aarch64.desktop
		cp -f /usr/share/applications/wps-office-wpp.desktop	/usr/share/applications/wps-office-wpp-aarch64.desktop
	fi

	sudo dpkg --configure -a

	# 有用户交互部分！！！
	aceept_command=debconf-set-selections
	echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | ${aceept_command}
	sudo apt-get install -y ttf-mscorefonts-installer
	exit_if_fail $? "ms字体安装失败"

	tar -Jxvf "${FT_PATH1}" --overwrite -C /
	exit_if_fail $? "wps字体安装失败"

	# 更新字体缓存
	sudo fc-cache -f -v

	sudo apt-get install -y libglu1-mesa libxslt-dev bsdmainutils ${ZZSWMGR_MAIN_DIR}/${DEB_PATH}
	exit_if_fail $? "安装失败"

	# dpkg -i ${DEB_PATH} || apt-get install -y ${DEB_PATH}
	# install_deb ${DEB_PATH}
	# exit_if_fail $? "安装失败，软件包：${DEB_PATH}"

	# 默认的界面语言
	# cat ${HOME}/.config/Kingsoft/Office.conf|grep languages

	# apt-get --fix-broken install -y
	# exit_if_fail $? "安装失败，软件包：${DEB_PATH}"

	# rm -rf ${DIR_DESKTOP_FILES}/code-url-handler.desktop
	# rm -rf ${DIR_DESKTOP_FILES}/code.desktop

	# /opt/kingsoft/wps-office/office6/wps
	# /opt/kingsoft/wps-office/office6/wpsoffice
	# /opt/kingsoft/wps-office/office6/et

	# 错误1：找不到 libproviders.so 
	# 是因为虚拟电脑使用的rootfs较新，带的openssl也较新, export OPENSSL_CONF=/dev/null 可以不报此错误

	# 错误2：Some formula symbols might not be displayed correctly due to missing fonts. 缺失字体
	# https://gitee.com/ak2/ttf-wps-fonts
	# https://gitee.com/ak2/msttcorefonts

	# 错误3：backup fail/backup目录不可设置，backup功能不可关闭
	# 还是proot环境不能处理 mount 映射，导致wps把备份目录识别成只读的(/home/droidvm/.local/share/Kingsoft/office6/data/backup)
}

function sw_create_desktop_file() {
	echo ""
# cat <<- EOF > ${DSK_PATH}
# [Desktop Entry]
# Name=Code No Sandbox
# Comment=Code Editing. No sandbox. Redefined.
# GenericName=Text Editor
# Exec=/usr/share/code/code --no-sandbox --unity-launch --user-data-dir=~/.vscode %F
# Icon=vscode
# Type=Application
# StartupNotify=false
# StartupWMClass=Code
# Categories=TextEditor;Development;IDE;
# MimeType=text/plain;inode/directory;application/x-code-workspace;
# Actions=new-empty-window;
# Keywords=vscode;

# X-Desktop-File-Install-Version=0.26

# [Desktop Action new-empty-window]
# Name=New Empty Window
# Exec=/usr/share/code/code --no-sandbox --new-window %F
# Icon=com.visualstudio.code
# EOF
}

if [ "${action}" == "卸载" ]; then
	echo "暂不支持卸载"
	exit 1
else

	sw_download
	sw_install
	sw_create_desktop_file
fi
