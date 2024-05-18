#!/bin/bash

: '

ls -al \
/usr/lib/binfmt.d/    \
/usr/share/binfmts/   \
/etc/binfmt.d/        \
/var/lib/binfmts/

cp -f /etc/binfmt.d/box*.conf /usr/lib/binfmt.d/
cp -f /etc/binfmt.d/box*.conf /usr/share/binfmts/


https://blog.csdn.net/SHIGUANGTUJING/article/details/89291732

中文乱码处理，检查以下两点：

1). 环境变量
droidvm@localhost:/usr/bin$ set|grep LANG
APP_LANGUAGE=zh
LANG=zh_CN.UTF-8
LANGUAGE=zh_CN.UTF-8

2). 系统中已安装的字体文件：
fc-list  :lang=zh|grep SC		# SC 一般是大陆简体中文，其它的东亚字体简称还有HK,TC,JP, KR

ls -al ~/.wine32/drive_c/windows/Fonts | grep simsun

如果没有 simsun 字符，因为微软专利的原因，不能对公开放下载，需要自己找：
cd Windows\fonts
md C:\tmpfonts
copy simsun* C:\tmpfonts\


如果感觉wine中字体太小，可以 wine64 winecfg 中设置（“显示”标签中选择适当的dpi即可）。


export WINEARCH=win64
export WINEPREFIX=${HOME}/.wine
env WINEDLLOVERRIDES="mscoree,mshtml=" wine64 cmd
export WINEPATH=~/.wine
export WINEPREFIX=~/.wine
export WINEARCH=win32
wineboot --init



'

SWNAME=wine
SWVER=8.9
DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}

VAR_WINE32="WINEPREFIX=~/.wine32 WINEARCH=win32 "
VAR_WINE64="WINEPREFIX=~/.wine64 WINEARCH=win64 "

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh

function sw_download() {

	# echo "129.151.136.35 mirror.ghproxy.com"           >> /etc/hosts
	tmpdns=`cd /exbin && droidexec ./vm_getHostByName.sh mirror.ghproxy.com`
	exit_if_fail $? "DNS解析失败"
	echo "$tmpdns" >> /etc/hosts


	echo "正在下载dxvk"
	swUrl=https://mirror.ghproxy.com/https://github.com/doitsujin/dxvk/releases/download/v2.3/dxvk-2.3.tar.gz
	zip_dxvk=./downloads/dxvk.tar.gz
	download_file2 "${zip_dxvk}" "${swUrl}"
	exit_if_fail $? "下载失败，网址：${swUrl}"

	echo "正在下载茶壶演示程序"
	demoapp=./downloads/demoapp.zip
	swUrl=${APP_URL_DLSERVER}/EnvMapping_DX9.zip
	download_file2 "${demoapp}" "${swUrl}"
	exit_if_fail $? "下载失败，网址：${swUrl}"

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

				# 注意，这里要安装 【【跨CPU架构的 amd64 wine】】　!!!
				# ======================================================================
				# 在arm64 linux中，box 启动 "异构wine" , "异构wine" 再启动 windows exe
				# box 本身运行于arm64 linux中, 启动的wine却是amd64架构的wine，即异构wine
				# box 就是干这个事的，用来在arm linux中启动x86架构的程序
				tmp_version="${SWVER}-amd64"
				DEB_PATH=./downloads/${SWNAME}-${tmp_version}.tar.xz
				app_dir=/opt/apps/${SWNAME}-${tmp_version}

				# 两个下载地址:
				# https://dl.winehq.org/wine-builds/				# 相当慢，而且据测试在proot环境中，此系列的wine版本总是会有莫名其妙的问题
				# https://github.com/Kron4ek/Wine-Builds/releases/	# github, 都懂的，经常无法访问，不使用vpn的话，能不能从这里下载到文件全看运气

				# swUrl=https://github.com/Kron4ek/Wine-Builds/releases/download/8.9/wine-8.9-amd64.tar.xz
				# swUrl=${APP_URL_DLSERVER}/wine/wine-8.9-amd64.tar.xz
				# swUrl=${APP_URL_DLSERVER}/wine-8.9-amd64.tar.xz
				# swUrl=${APP_URL_DLSERVER}/wine-8.9-amd64.tar.xz
				swUrl=https://mirror.ghproxy.com/https://github.com/Kron4ek/Wine-Builds/releases/download/${SWVER}/wine-${SWVER}-amd64.tar.xz
				download_file2 "${DEB_PATH}" "${swUrl}"
				exit_if_fail $? "下载失败，网址：${swUrl}"
				;;
		"amd64")
				echo "不需要单独下载"
				;;
		*) exit_unsupport ;;
	esac

}

function sw_install_depends() {
	echo "正在安装box64开发者整理的依赖库"
	echo "LINUX_ROOTFS_VER: $LINUX_ROOTFS_VER"

	tmp_libs=libldap-2.5-0

	
	if [ "${ROOTFS_CODENAME}" == "kinetic" ]; then
		tmp_libs=libldap-2.5-0
		echo "请注意：已将libldap-2.4-2 替换为 ${tmp_libs}"
		sudo apt-get install -y libasound2:armhf libc6:armhf libglib2.0-0:armhf libgphoto2-6:armhf libgphoto2-port12:armhf \
			libgstreamer-plugins-base1.0-0:armhf libgstreamer1.0-0:armhf ${tmp_libs}:armhf libopenal1:armhf libpcap0.8:armhf \
			libpulse0:armhf libsane1:armhf libudev1:armhf libusb-1.0-0:armhf libvkd3d1:armhf libx11-6:armhf libxext6:armhf \
			libasound2-plugins:armhf ocl-icd-libopencl1:armhf libncurses6:armhf libncurses5:armhf libcap2-bin:armhf libcups2:armhf \
			libdbus-1-3:armhf libfontconfig1:armhf libfreetype6:armhf libglu1-mesa:armhf libglu1:armhf libgnutls30:armhf \
			libgssapi-krb5-2:armhf libkrb5-3:armhf libodbc1:armhf libosmesa6:armhf libsdl2-2.0-0:armhf libv4l-0:armhf \
			libxcomposite1:armhf libxcursor1:armhf libxfixes3:armhf libxi6:armhf libxinerama1:armhf libxrandr2:armhf \
			libxrender1:armhf libxxf86vm1 libc6:armhf libcap2-bin:armhf # to run wine-i386 through box86:armhf on aarch64
			exit_if_fail $? "32位依赖库安装失败"

		sudo apt-get install -y libasound2:arm64 libc6:arm64 libglib2.0-0:arm64 libgphoto2-6:arm64 libgphoto2-port12:arm64 \
			libgstreamer-plugins-base1.0-0:arm64 libgstreamer1.0-0:arm64 ${tmp_libs}:arm64 libopenal1:arm64 libpcap0.8:arm64 \
			libpulse0:arm64 libsane1:arm64 libudev1:arm64 libunwind8:arm64 libusb-1.0-0:arm64 libvkd3d1:arm64 libx11-6:arm64 libxext6:arm64 \
			ocl-icd-libopencl1:arm64 libasound2-plugins:arm64 libncurses6:arm64 libncurses5:arm64 libcups2:arm64 \
			libdbus-1-3:arm64 libfontconfig1:arm64 libfreetype6:arm64 libglu1-mesa:arm64 libgnutls30:arm64 \
			libgssapi-krb5-2:arm64 libkrb5-3:arm64 libodbc1:arm64 libosmesa6:arm64 libsdl2-2.0-0:arm64 libv4l-0:arm64 \
			libxcomposite1:arm64 libxcursor1:arm64 libxfixes3:arm64 libxi6:arm64 libxinerama1:arm64 libxrandr2:arm64 \
			libxrender1:arm64 libxxf86vm1:arm64 libc6:arm64 libcap2-bin:arm64
			exit_if_fail $? "64位依赖库安装失败"
			# libjpeg62-turbo:arm64 
	fi

	if [ "${ROOTFS_CODENAME}" == "lunar" ]; then
		tmp_libs=libldap-common
		echo "请注意：已将libldap-2.4-2 替换为 ${tmp_libs}"
		sudo apt-get install -y libasound2:armhf libc6:armhf libglib2.0-0:armhf libgphoto2-6:armhf libgphoto2-port12:armhf \
			libgstreamer-plugins-base1.0-0:armhf libgstreamer1.0-0:armhf ${tmp_libs}:armhf libopenal1:armhf libpcap0.8:armhf \
			libpulse0:armhf libsane1:armhf libudev1:armhf libusb-1.0-0:armhf libvkd3d1:armhf libx11-6:armhf libxext6:armhf \
			libasound2-plugins:armhf ocl-icd-libopencl1:armhf libncurses6:armhf libncurses5:armhf libcap2-bin:armhf libcups2:armhf \
			libdbus-1-3:armhf libfontconfig1:armhf libfreetype6:armhf libglu1-mesa:armhf libglu1:armhf libgnutls30:armhf \
			libgssapi-krb5-2:armhf libkrb5-3:armhf libodbc1:armhf libosmesa6:armhf libsdl2-2.0-0:armhf libv4l-0:armhf \
			libxcomposite1:armhf libxcursor1:armhf libxfixes3:armhf libxi6:armhf libxinerama1:armhf libxrandr2:armhf \
			libxrender1:armhf libxxf86vm1 libc6:armhf libcap2-bin:armhf # to run wine-i386 through box86:armhf on aarch64
			exit_if_fail $? "32位依赖库安装失败"

		sudo apt-get install -y libasound2:arm64 libc6:arm64 libglib2.0-0:arm64 libgphoto2-6:arm64 libgphoto2-port12:arm64 \
			libgstreamer-plugins-base1.0-0:arm64 libgstreamer1.0-0:arm64 ${tmp_libs}:arm64 libopenal1:arm64 libpcap0.8:arm64 \
			libpulse0:arm64 libsane1:arm64 libudev1:arm64 libunwind8:arm64 libusb-1.0-0:arm64 libvkd3d1:arm64 libx11-6:arm64 libxext6:arm64 \
			ocl-icd-libopencl1:arm64 libasound2-plugins:arm64 libncurses6:arm64 libncurses5:arm64 libcups2:arm64 \
			libdbus-1-3:arm64 libfontconfig1:arm64 libfreetype6:arm64 libglu1-mesa:arm64 libgnutls30:arm64 \
			libgssapi-krb5-2:arm64 libkrb5-3:arm64 libodbc1:arm64 libosmesa6:arm64 libsdl2-2.0-0:arm64 libv4l-0:arm64 \
			libxcomposite1:arm64 libxcursor1:arm64 libxfixes3:arm64 libxi6:arm64 libxinerama1:arm64 libxrandr2:arm64 \
			libxrender1:arm64 libxxf86vm1:arm64 libc6:arm64 libcap2-bin:arm64
			exit_if_fail $? "64位依赖库安装失败"
			# libjpeg62-turbo:arm64 
	fi

	if [ "${ROOTFS_CODENAME}" == "mantic" ]; then
		tmp_libs=libldap-common
		# odbc
		# libncurses
		echo "请注意：已将libldap-2.4-2 替换为 ${tmp_libs}"
		sudo apt-get install -y libasound2:armhf libc6:armhf libglib2.0-0:armhf libgphoto2-6:armhf libgphoto2-port12:armhf \
			libgstreamer-plugins-base1.0-0:armhf libgstreamer1.0-0:armhf ${tmp_libs}:armhf libopenal1:armhf libpcap0.8:armhf \
			libpulse0:armhf libsane1:armhf libudev1:armhf libusb-1.0-0:armhf libvkd3d1:armhf libx11-6:armhf libxext6:armhf \
			libasound2-plugins:armhf ocl-icd-libopencl1:armhf libncurses6:armhf libcap2-bin:armhf libcups2:armhf \
			libdbus-1-3:armhf libfontconfig1:armhf libfreetype6:armhf libglu1-mesa:armhf libglu1:armhf libgnutls30:armhf \
			libgssapi-krb5-2:armhf libkrb5-3:armhf libodbc2:armhf libosmesa6:armhf libsdl2-2.0-0:armhf libv4l-0:armhf \
			libxcomposite1:armhf libxcursor1:armhf libxfixes3:armhf libxi6:armhf libxinerama1:armhf libxrandr2:armhf \
			libxrender1:armhf libxxf86vm1 libc6:armhf libcap2-bin:armhf # to run wine-i386 through box86:armhf on aarch64
			exit_if_fail $? "32位依赖库安装失败"

		sudo apt-get install -y libasound2:arm64 libc6:arm64 libglib2.0-0:arm64 libgphoto2-6:arm64 libgphoto2-port12:arm64 \
			libgstreamer-plugins-base1.0-0:arm64 libgstreamer1.0-0:arm64 ${tmp_libs}:arm64 libopenal1:arm64 libpcap0.8:arm64 \
			libpulse0:arm64 libsane1:arm64 libudev1:arm64 libunwind8:arm64 libusb-1.0-0:arm64 libvkd3d1:arm64 libx11-6:arm64 libxext6:arm64 \
			ocl-icd-libopencl1:arm64 libasound2-plugins:arm64 libncurses6:arm64 libcups2:arm64 \
			libdbus-1-3:arm64 libfontconfig1:arm64 libfreetype6:arm64 libglu1-mesa:arm64 libgnutls30:arm64 \
			libgssapi-krb5-2:arm64 libkrb5-3:arm64 libodbc2:arm64 libosmesa6:arm64 libsdl2-2.0-0:arm64 libv4l-0:arm64 \
			libxcomposite1:arm64 libxcursor1:arm64 libxfixes3:arm64 libxi6:arm64 libxinerama1:arm64 libxrandr2:arm64 \
			libxrender1:arm64 libxxf86vm1:arm64 libc6:arm64 libcap2-bin:arm64
			exit_if_fail $? "64位依赖库安装失败"
			# libjpeg62-turbo:arm64 
	fi

}

function sw_install() {
	case "${CURRENT_VM_ARCH}" in
		"arm64")
				sudo apt-get install -y xz-utils file unzip 
				exit_if_fail $? "解压工具xz安装失败"

				echo "正在解压跨CPU架构的wine32/64. . ."
				tar -xJf ${DEB_PATH} --overwrite -C /opt/apps/
				exit_if_fail $? "安装失败，软件包：${DEB_PATH}"

				echo "正在启用 multi-arch ..."
				dpkg --add-architecture armhf && sudo apt-get update
				exit_if_fail $? "依赖包安装失败"

				sw_install_depends

				echo " 正在安装 winetricks, winetricks 用于安装wine缺失的dll文件"
				sudo apt-get install -y winetricks
				exit_if_fail $? "winetricks安装失败"

				echo " 正在解压 wine 中运行的dxvk库"
				tar -xzf ${zip_dxvk} --overwrite -C /opt/apps/
				exit_if_fail $? "安装失败，软件包：${zip_dxvk}"

				echo " 正在安装 wine 中运行的3D茶壶测试程序"
				mkdir -p /opt/apps/wine3demo 2>/dev/null
				unzip -oq ${demoapp} -d /opt/apps/wine3demo
				exit_if_fail $? "解压失败，软件包：${demoapp}"

				# mono csharp runtime: https://mirrors.ustc.edu.cn/wine/wine/wine-mono/
				# gecko webBrowserCOM: https://blog.csdn.net/u010164190/article/details/106785069

				;;
		"amd64")
				sudo apt-get install -y wine
				exit_if_fail $? "依赖包安装失败"
				;;
		*) exit_unsupport ;;
	esac
}

function generate_regfile_zh_CN() {
	# "Droid Sans Fallback" 或者 "Noto Sans Mono CJK SC", 或者 "WenQuanYi Micro Hei" 和 dpi
	cat <<- EOF >   ${app_dir}/wine_init_config_zh_CN.reg
		REGEDIT4
		[HKEY_CURRENT_USER\Software\Wine\Fonts\Replacements]
		"DFKai-SB"="WenQuanYi Micro Hei"
		"FangSong"="WenQuanYi Micro Hei"
		"KaiTi"="WenQuanYi Micro Hei"
		"Microsoft JhengHei"="WenQuanYi Micro Hei"
		"Microsoft YaHei"="WenQuanYi Micro Hei"
		"MingLiU"="WenQuanYi Micro Hei"
		"SimSun"="WenQuanYi Micro Hei"
		"PMingLiU"="WenQuanYi Micro Hei"
		"SimHei"="WenQuanYi Micro Hei"
		"SimKai"="WenQuanYi Micro Hei"
		"SimSun"="WenQuanYi Micro Hei"


		[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\FontLink\SystemLink]
		"Lucida Sans Unicode"="WenQuanYi Micro Hei"
		"Microsoft Sans Serif"="WenQuanYi Micro Hei"
		"MS Sans Serif"="WenQuanYi Micro Hei"
		"Tahoma"="WenQuanYi Micro Hei"
		"Tahoma Bold"="WenQuanYi Micro Hei"
		"SimSun"="WenQuanYi Micro Hei"
		"Arial"="WenQuanYi Micro Hei"
		"Arial Black"="WenQuanYi Micro Hei"
		

		[HKEY_LOCAL_MACHINE\System\CurrentControlSet\Hardware Profiles\Current\Software\Fonts]
		"LogPixels"=dword:00000096
	EOF
}

function generate_regfile_EN() {
	# "Droid Sans Fallback" 或者 "Noto Sans Mono CJK SC", 或者 "WenQuanYi Micro Hei" 和 dpi
	cat <<- EOF >   ${app_dir}/wine_init_config_EN.reg
		REGEDIT4
		[HKEY_LOCAL_MACHINE\System\CurrentControlSet\Hardware Profiles\Current\Software\Fonts]
		"LogPixels"=dword:00000096
	EOF
}

function wineinit() {
	init_regfile_path=
	initmsg=

	cat <<- EOF >   ${app_dir}/winereset.sh
			#!/bin/bash

			action=\$1

			# \${action} 为空表示重置，其它代表初始化
			if [ "\${action}" == "" ]; then
				echo ""													> /tmp/msg.txt
				echo "重置wine将删除主目录下的.wine文件夹，且不可恢复!"	>>/tmp/msg.txt
				echo "确定要将wine重置吗"								>>/tmp/msg.txt
				echo ""													>>/tmp/msg.txt

				gxmessage -title "请确认" -file /tmp/msg.txt -center -buttons "确定:1,取消:0"
				if [ \$? -ne 1 ]; then
					exit 0
				fi
			fi

			function exit_if_fail() {
				rlt_code=\$1
				fail_msg=\$2
				if [ \$rlt_code -ne 0 ]; then
				echo -e "错误码: \${rlt_code}\n\${fail_msg}"
				if [ "\${action}" == "" ]; then
					gxmessage -title "提示" "错误码: \${rlt_code}\n\${fail_msg}"  -center
				fi
				# read -s -n1 -p "按任意键退出"
				exit \$rlt_code
				fi
			}

			rm -rf ~/.wine
			rm -rf ~/.wine32
			rm -rf ~/.wine64

	EOF

	if [ "${APP_LANGUAGE}_${APP_COUNTRY}" == "zh_CN" ]; then
		# echo "正在复制中文字体"

		echo " 正在安装 ttf-wqy-microhei 中文字体"
		sudo apt-get install -y ttf-wqy-microhei
		exit_if_fail $? "中文字体 ttf-wqy-microhei 安装失败"

		generate_regfile_zh_CN

		cat <<- EOF >>   ${app_dir}/winereset.sh
			export app_dir=/opt/apps/wine-8.9-amd64
			echo "正在初始化wine32..."
			${VAR_WINE32} WINEDLLOVERRIDES="mscoree,mshtml=" ${app_dir}/bin/wine   wineboot --init

			echo "正在初始化wine64..."
			${VAR_WINE64} WINEDLLOVERRIDES="mscoree,mshtml=" ${app_dir}/bin/wine64 wineboot --init

			mkdir -p ~/.wine32/drive_c/windows/Fonts
			mkdir -p ~/.wine64/drive_c/windows/Fonts
			cp -f /usr/share/fonts/truetype/wqy/wqy-microhei.ttc ~/.wine32/drive_c/windows/Fonts/simsun.ttc
			cp -f /usr/share/fonts/truetype/wqy/wqy-microhei.ttc ~/.wine64/drive_c/windows/Fonts/simsun.ttc

			initmsg="中文字体导入及dpi设置失败, 用户：${ZZ_USER_NAME}"
			init_regfile_path=${app_dir}/wine_init_config_zh_CN.reg

			${VAR_WINE32} WINEDLLOVERRIDES="mscoree,mshtml=" ${app_dir}/bin/wine   regedit \${init_regfile_path}
			# exit_if_fail \$? "wine32 \${initmsg}"

			${VAR_WINE64} WINEDLLOVERRIDES="mscoree,mshtml=" ${app_dir}/bin/wine64 regedit \${init_regfile_path}
			# exit_if_fail \$? "wine64 \${initmsg}"
		EOF

	else
		echo "非中文语言"

		generate_regfile_EN

		cat <<- EOF >>   ${app_dir}/winereset.sh
			echo "wine nitializing..."
			initmsg="fail on dpi setting, username: ${ZZ_USER_NAME}"
			init_regfile_path=${app_dir}/wine_init_config_EN.reg

			${VAR_WINE32} WINEDLLOVERRIDES="mscoree,mshtml=" ${app_dir}/bin/wine   regedit \${init_regfile_path}
			# exit_if_fail \$? "wine32 \${initmsg}"

			${VAR_WINE64} WINEDLLOVERRIDES="mscoree,mshtml=" ${app_dir}/bin/wine64 regedit \${init_regfile_path}
			# exit_if_fail \$? "wine64 \${initmsg}"
		EOF
	fi

	cat <<- EOF >>   ${app_dir}/winereset.sh
			if [ -d /opt/apps/dxvk-2.3/x64 ]; then
				cp -f /opt/apps/dxvk-2.3/x64/*.dll  ~/.wine64/drive_c/windows/system32/
				# cp -f /opt/apps/dxvk-2.3/x64/*.dll  ~/.wine32/drive_c/windows/system32/
			fi
			if [ -d /opt/apps/dxvk-2.3/x32 ]; then
				cp -f /opt/apps/dxvk-2.3/x32/*.dll  ~/.wine64/drive_c/windows/syswow64/
				cp -f /opt/apps/dxvk-2.3/x32/*.dll  ~/.wine32/drive_c/windows/system32/
			fi

			if [ "\${action}" == "" ]; then
				gxmessage -title "提示" "wine已重置"  -center
			fi
	EOF
	chmod a+x ${app_dir}/winereset.sh

	sudo -u ${ZZ_USER_NAME} ${app_dir}/winereset.sh init
	exit_if_fail $? "wine 初始化失败"
}

function sw_create_desktop_file() {
	case "${CURRENT_VM_ARCH}" in
		"arm64")
				rm -rf /usr/bin/wine*

				for ii in 32 64
				do
					PATH2WINE="${app_dir}/bin/wine${ii}"
					if [ "${ii}" == "32" ]; then
						PATH2WINE="${app_dir}/bin/wine"
					fi;
					cat <<- EOF > /usr/bin/wine${ii}
						#!/bin/bash
						export WINEARCH=win${ii}
						export WINEPREFIX=\${HOME}/.wine${ii}
						if [ \$# -eq 0 ]; then
							WINEPREFIX=~/.wine${ii} WINEARCH=win${ii}  exec ${PATH2WINE} explorer
						else
							WINEPREFIX=~/.wine${ii} WINEARCH=win${ii}  exec ${PATH2WINE} \$@
						fi
					EOF
					chmod a+x /usr/bin/wine${ii}
				done

				cat <<- EOF > /usr/bin/winexe
					#!/bin/bash
					if [ \$# -eq 0 ]; then
						exit 0
					fi
					is32bit=\`file \$1|grep PE32|grep 80386\`
					if [ "\$is32bit" != "" ]; then
						curr_wine=wine32
					else
						curr_wine=wine64
					fi
					cd \`dirname \$1\`
					currdir=\`pwd\`
					gxmessage -title "\${curr_wine} 3D加速" \$'\n准备启动：'\$1$'\n当前目录：'\${currdir}\$'\n\n要启用3D加速吗？\n\n'  -center -buttons "不启用:0,启用virgl-3D:1,取消:2"
					case "\$?" in
						"0")
							;;
						"2")
							exit 0
							;;
						*)
							export GALLIUM_DRIVER=virpipe
							export MESA_GL_VERSION_OVERRIDE=4.0
						;;
					esac
					exec \${curr_wine} \$@
				EOF
				chmod a+x /usr/bin/winexe

				wineinit

				# # 新增应用程序分类
				# mkdir -p ~/.config/menus/applications-merged/
				# 创建应用程序分类：    https://wiki.archlinux.org/title/Wine
				# /etc/xdg/menus
				# /usr/share/desktop-directories/
				# ~/.config/menus/applications-merged/  # 验证OK

				tmpfile=${DIR_DESKTOP_FILES}/winexe.desktop
				echo "[Desktop Entry]"	> ${tmpfile}
				echo "Encoding=UTF-8"	>>${tmpfile}
				echo "Version=0.9.4"	>>${tmpfile}
				echo "Type=Application"	>>${tmpfile}
				echo "Categories=System">>${tmpfile}
				echo "MimeType=application/x-dosexec;application/x-ms-dos-executable;application/x-ms-shortcut;application/x-msi;application/vnd.microsoft.portable-executable"	>>${tmpfile}
				echo "Terminal=false"	>>${tmpfile}
				echo "Name=运行exe软件"	>>${tmpfile}
				echo "Exec=winexe $F"	>> ${tmpfile}
				# cp2desktop ${tmpfile}

				tmpfile=${DIR_DESKTOP_FILES}/wine32.desktop
				echo "[Desktop Entry]"	> ${tmpfile}
				echo "Encoding=UTF-8"	>>${tmpfile}
				echo "Version=0.9.4"	>>${tmpfile}
				echo "Type=Application"	>>${tmpfile}
				echo "Categories=System">>${tmpfile}
				echo "MimeType=application/x-dosexec;application/x-ms-dos-executable;application/x-ms-shortcut;application/x-msi;application/vnd.microsoft.portable-executable"	>>${tmpfile}
				echo "Name=wine32"		>>${tmpfile}
				echo "Exec=wine32 explorer"	>> ${tmpfile}
				cp2desktop ${tmpfile}

				tmpfile=${DIR_DESKTOP_FILES}/wine64.desktop
				echo "[Desktop Entry]"	> ${tmpfile}
				echo "Encoding=UTF-8"	>>${tmpfile}
				echo "Version=0.9.4"	>>${tmpfile}
				echo "Type=Application"	>>${tmpfile}
				echo "Categories=System">>${tmpfile}
				echo "MimeType=application/x-dosexec;application/x-ms-dos-executable;application/x-ms-shortcut;application/x-msi;application/vnd.microsoft.portable-executable"	>>${tmpfile}
				echo "Name=wine64"		>>${tmpfile}
				echo "Exec=wine64 explorer"	>> ${tmpfile}
				cp2desktop ${tmpfile}

				tmpfile=${DIR_DESKTOP_FILES}/cmd32.desktop
				echo "[Desktop Entry]"	> ${tmpfile}
				echo "Encoding=UTF-8"	>>${tmpfile}
				echo "Version=0.9.4"	>>${tmpfile}
				echo "Type=Application"	>>${tmpfile}
				echo "Categories=System">>${tmpfile}
				echo "Terminal=true"	>>${tmpfile}
				echo "Name=CMD32"		>>${tmpfile}
				echo "Exec=wine32 cmd"	>> ${tmpfile}
				cp2desktop ${tmpfile}

				tmpfile=${DIR_DESKTOP_FILES}/cmd64.desktop
				echo "[Desktop Entry]"	> ${tmpfile}
				echo "Encoding=UTF-8"	>>${tmpfile}
				echo "Version=0.9.4"	>>${tmpfile}
				echo "Type=Application"	>>${tmpfile}
				echo "Categories=System">>${tmpfile}
				echo "Terminal=true"	>>${tmpfile}
				echo "Name=CMD64"		>>${tmpfile}
				echo "Exec=wine64 cmd"	>> ${tmpfile}
				cp2desktop ${tmpfile}

				tmpfile=${DIR_DESKTOP_FILES}/wine32cfg.desktop
				echo "[Desktop Entry]"	> ${tmpfile}
				echo "Encoding=UTF-8"	>>${tmpfile}
				echo "Version=0.9.4"	>>${tmpfile}
				echo "Type=Application"	>>${tmpfile}
				echo "Categories=System">>${tmpfile}
				echo "Name=配置wine32"	>>${tmpfile}
				echo "Exec=wine32  winecfg"	>> ${tmpfile}

				tmpfile=${DIR_DESKTOP_FILES}/wine64cfg.desktop
				echo "[Desktop Entry]"	> ${tmpfile}
				echo "Encoding=UTF-8"	>>${tmpfile}
				echo "Version=0.9.4"	>>${tmpfile}
				echo "Type=Application"	>>${tmpfile}
				echo "Categories=System">>${tmpfile}
				echo "Name=配置wine64"	>>${tmpfile}
				echo "Exec=wine64 winecfg"	>> ${tmpfile}

				tmpfile=${DIR_DESKTOP_FILES}/wine_reset.desktop
				echo "[Desktop Entry]"	> ${tmpfile}
				echo "Encoding=UTF-8"	>>${tmpfile}
				echo "Version=0.9.4"	>>${tmpfile}
				echo "Type=Application"	>>${tmpfile}
				echo "Categories=System">>${tmpfile}
				echo "Terminal=true"	>>${tmpfile}
				echo "Name=重置wine"	>>${tmpfile}
				echo "Exec=${app_dir}/winereset.sh"	>> ${tmpfile}

				echo "请使用 wine32/wine64 指令运行windows程序, 比如:"
				echo "wine64 cmd"
				echo "wine64 explorer"
				echo "wine64 taskmgr"
				echo "wine64 winecfg"

				echo "wine配置程序："
				echo "wine64 winecfg"

				#启动茶壶测试程序
				sudo -u ${ZZ_USER_NAME} winexe /opt/apps/wine3demo/CubeMap.exe &
				;;
		"amd64")
				# todo
				echo "桌面快捷方式待创建。。。"
				;;
		*) exit_unsupport ;;
	esac
}

if [ "${action}" == "卸载" ]; then
	# echo "暂不支持卸载"
	# exit 1

	set -x	# echo on

	apt-get autopurge -y wine
	rm2desktop wine*.desktop
	rm2desktop cmd32.desktop
	rm2desktop cmd64.desktop

	rm -rf ./downloads/wine*
	rm -rf ./downloads/dxvk.tar.gz
	rm -rf ./downloads/demoapp.zip
	rm -rf /usr/bin/wine*
	rm -rf /opt/apps/wine*
	rm -rf /opt/apps/dxvk*
	rm -rf /home/${ZZ_USER_NAME}/.wine*

	# 移除armhf架构的包
	apt-get autopurge -y --allow-remove-essential `dpkg --get-selections | grep ":armhf" | awk '{print $1}'`

	# 移除armhf架构的软件仓库
	dpkg --remove-architecture armhf

	apt update

	apt-get clean

	set +x	# echo off

else
	sw_download
	sw_install
	sw_create_desktop_file
fi
