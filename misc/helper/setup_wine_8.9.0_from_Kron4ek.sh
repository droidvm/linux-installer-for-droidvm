#!/bin/bash

# 设置控制台窗口的标题栏
PS1=$PS1"\[\e]0;安装wine\a\]"


curr_arch=`uname -m`
if [ "${curr_arch}" == "x86_64" ]; then
    sudo apt install -y wine
    exit 0
fi


debug=1
tmp_version="8.9-amd64"
tmp_dir=~/tmp_wine_installer
app_dir=/opt/apps/wine-${tmp_version}


wine32Path=`which wine32 2>>/dev/null`
wine64Path=`which wine64 2>>/dev/null`

if [ -f ${app_dir}/installed ]; then
      gxmessage -title "提示" "wine已安装，继续安装将会覆盖现在有版本，确定要继续吗？"  -center -buttons "确定:1,取消:0"
      if [ $? -ne 1 ]; then
            exit 0
      fi
fi


which box86 >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo ""															> /tmp/msg.txt
    echo "请先安装box86/64 (安装方法为双击桌面上的 安装box 图标)"	>>/tmp/msg.txt
    echo ""															>>/tmp/msg.txt
    gxmessage -title "提示" -file /tmp/msg.txt -center
    exit 0
fi


echo "tmp_dir: ${tmp_dir}"
echo "app_dir: ${app_dir}"

echo "正在安装wine, 需往系统可执行目录写入文件"
echo "请输入密码进行授权"
echo "当前账户的密码默认是:droidvm"
sudo echo "正在安装wine-${tmp_version}"

function exit_if_fail() {
    rlt_code=$1
    fail_msg=$2
    if [ $rlt_code -ne 0 ]; then
      echo "\n错误码: ${rlt_code}, ${fail_msg}"
      read -s -n1 -p "按任意键退出"
      exit $rlt_code
    fi
}


########################################################
mkdir -p ${tmp_dir}
mkdir -p /opt/apps


echo "正在生成下载链接，我们准备从WineHQ网站下载wine: https://dl.winehq.org/wine-builds/"
if [ 1 -eq 1 ]; then
	LNK64="https://github.com/Kron4ek/Wine-Builds/releases/download/8.9/"
	DEB64_1="wine-8.9-amd64.tar.xz"

	echo "正在下载 wine 安装包. . ."
	echo "${LNK64}${DEB64_1} "

	if [ "$debug" != "" ]; then
		# 可以使用讯雷先下载到本地http服务器上
		. /etc/profile
		. ${APP_FILENAME_URLDLSERVER}
		LNK64="${APP_URL_DLSERVER}/wine/"
		echo "将从调试服务器下载: ${LNK64}"
	fi
fi

cd "${tmp_dir}"

echo "正在下载"
if [ 1 -eq 1 ]; then
	if [ ! -f ${DEB64_1} ]; then
		/usr/bin/wget ${LNK64}${DEB64_1}
		download_rlt=$?
		if [ $download_rlt -ne 0 ]; then rm -rf ${DEB64_1}; fi
		exit_if_fail $download_rlt "下载失败 => ${DEB64_1}"
	fi
fi


echo -e "正在解压. . ."
if [ 1 -eq 1 ]; then

	sudo apt install -y xz-utils

	tar -xJf ${DEB64_1} -C ${tmp_dir}
		exit_if_fail $? "解压失败 => ${DEB64_1}"

	echo -e "正在复制文件 mv ${tmp_dir}/wine-${tmp_version} ${app_dir}. . ."
	rm -rf ${app_dir}
	mv -f ${tmp_dir}/wine-${tmp_version} ${app_dir}
	exit_if_fail $? "文件复制失败 \"mv -f ${tmp_dir}/wine-${tmp_version} ${app_dir}\""
	# read -s -n1 -p "按任意键继续 ... "
fi


echo "正在启用 multi-arch ..."
if [ 1 -eq 1 ]; then
	# dpkg --print-architecture
	# dpkg --print-foreign-architectures
	# dpkg --remove-architecture ***
	sudo dpkg --add-architecture armhf && sudo apt-get update
fi


echo "正在安依赖库"
if [ 1 -eq 1 ]; then
	if [ 1 -eq 0 ]; then
		echo "正在安装droidvm整理的依赖库"

		# echo "正在安装 wine-${tmp_version} 的64位依赖库 ..."
		# echo "请注意：已将libjpeg62-turbo:arm64 替换为:libjpeg62:arm64 20230607"
		# echo "请注意：已将libjpeg62-turbo:arm64 去掉                   20230608"
		# sudo apt install -y \
		# 	libasound2:arm64 \
		# 	libc6:arm64 \
		# 	libglib2.0-0:arm64 \
		# 	libgphoto2-6:arm64 \
		# 	libgphoto2-port12:arm64 \
		# 	libgstreamer-plugins-base1.0-0:arm64 \
		# 	libgstreamer1.0-0:arm64 \
		# 	libldap-2.5-0:arm64 \
		# 	libopenal1:arm64 \
		# 	libpcap0.8:arm64 \
		# 	libpulse0:arm64 \
		# 	libsane1:arm64 \
		# 	libudev1:arm64 \
		# 	libunwind8:arm64 \
		# 	libusb-1.0-0:arm64 \
		# 	libx11-6:arm64 \
		# 	libxext6:arm64 \
		# 	ocl-icd-libopencl1:arm64 \
		# 	ocl-icd-libopencl1:arm64 \
		# 	libasound2-plugins:arm64 \
		# 	libncurses6:arm64 \
		# 	libcapi20-3:arm64 \
		# 	libcups2:arm64 \
		# 	libdbus-1-3:arm64 \
		# 	libfontconfig1:arm64 \
		# 	libfreetype6:arm64 \
		# 	libglu1-mesa:arm64 \
		# 	libgnutls30:arm64 \
		# 	libgsm1:arm64 \
		# 	libgssapi-krb5-2:arm64 \
		# 	\
		# 	libkrb5-3:arm64 \
		# 	libodbc1:arm64 \
		# 	libosmesa6:arm64 \
		# 	libpng16-16:arm64 \
		# 	libsdl2-2.0-0:arm64 \
		# 	libtiff5:arm64 \
		# 	libv4l-0:arm64 \
		# 	libxcomposite1:arm64 \
		# 	libxcursor1:arm64 \
		# 	libxfixes3:arm64 \
		# 	libxi6:arm64 \
		# 	libxinerama1:arm64 \
		# 	libxrandr2:arm64 \
		# 	libxrender1:arm64 \
		# 	libxslt1.1:arm64 \
		# 	libxxf86vm1:arm64
		# exit_if_fail $? "64位依赖库安装失败"

		# echo "正在安装 wine-${tmp_version} 32位依赖库 ..."
		# echo "请注意：已将libjpeg62-turbo:armhf 替换为:libjpeg62:armhf 20230607"
		# echo "请注意：已将libjpeg62-turbo:armhf 去掉                   20230608"
		# sudo apt install -y \
		# 	libasound2:armhf \
		# 	libc6:armhf \
		# 	libglib2.0-0:armhf \
		# 	libgphoto2-6:armhf \
		# 	libgphoto2-port12:armhf \
		# 	libgstreamer-plugins-base1.0-0:armhf \
		# 	libgstreamer1.0-0:armhf \
		# 	libldap-2.5-0:armhf \
		# 	libopenal1:armhf \
		# 	libpcap0.8:armhf \
		# 	libpulse0:armhf \
		# 	libsane1:armhf \
		# 	libudev1:armhf \
		# 	libusb-1.0-0:armhf \
		# 	libx11-6:armhf \
		# 	libxext6:armhf \
		# 	ocl-icd-libopencl1:armhf \
		# 	ocl-icd-libopencl1:armhf \
		# 	libasound2-plugins:armhf \
		# 	libncurses6:armhf \
		# 	libcapi20-3:armhf \
		# 	libcups2:armhf \
		# 	libdbus-1-3:armhf \
		# 	libfontconfig1:armhf \
		# 	libfreetype6:armhf \
		# 	libglu1-mesa:armhf \
		# 	libgnutls30:armhf \
		# 	libgsm1:armhf \
		# 	libgssapi-krb5-2:armhf \
		# 	\
		# 	libkrb5-3:armhf \
		# 	libodbc1:armhf \
		# 	libosmesa6:armhf \
		# 	libpng16-16:armhf \
		# 	libsdl2-2.0-0:armhf \
		# 	libtiff5:armhf \
		# 	libv4l-0:armhf \
		# 	libxcomposite1:armhf \
		# 	libxcursor1:armhf \
		# 	libxfixes3:armhf \
		# 	libxi6:armhf \
		# 	libxinerama1:armhf \
		# 	libxrandr2:armhf \
		# 	libxrender1:armhf \
		# 	libxslt1.1:armhf \
		# 	libxxf86vm1:armhf
		# exit_if_fail $? "32位依赖库安装失败"
	else
		echo "正在安装box64开发者整理的依赖库"
		echo "请注意：已将libldap-2.4-2 替换为 libldap-2.5-0"
		sudo apt-get install -y libasound2:armhf libc6:armhf libglib2.0-0:armhf libgphoto2-6:armhf libgphoto2-port12:armhf \
			libgstreamer-plugins-base1.0-0:armhf libgstreamer1.0-0:armhf libldap-2.5-0:armhf libopenal1:armhf libpcap0.8:armhf \
			libpulse0:armhf libsane1:armhf libudev1:armhf libusb-1.0-0:armhf libvkd3d1:armhf libx11-6:armhf libxext6:armhf \
			libasound2-plugins:armhf ocl-icd-libopencl1:armhf libncurses6:armhf libncurses5:armhf libcap2-bin:armhf libcups2:armhf \
			libdbus-1-3:armhf libfontconfig1:armhf libfreetype6:armhf libglu1-mesa:armhf libglu1:armhf libgnutls30:armhf \
			libgssapi-krb5-2:armhf libkrb5-3:armhf libodbc1:armhf libosmesa6:armhf libsdl2-2.0-0:armhf libv4l-0:armhf \
			libxcomposite1:armhf libxcursor1:armhf libxfixes3:armhf libxi6:armhf libxinerama1:armhf libxrandr2:armhf \
			libxrender1:armhf libxxf86vm1 libc6:armhf libcap2-bin:armhf # to run wine-i386 through box86:armhf on aarch64
			exit_if_fail $? "32位依赖库安装失败"

		sudo apt-get install -y libasound2:arm64 libc6:arm64 libglib2.0-0:arm64 libgphoto2-6:arm64 libgphoto2-port12:arm64 \
			libgstreamer-plugins-base1.0-0:arm64 libgstreamer1.0-0:arm64 libldap-2.5-0:arm64 libopenal1:arm64 libpcap0.8:arm64 \
			libpulse0:arm64 libsane1:arm64 libudev1:arm64 libunwind8:arm64 libusb-1.0-0:arm64 libvkd3d1:arm64 libx11-6:arm64 libxext6:arm64 \
			ocl-icd-libopencl1:arm64 libasound2-plugins:arm64 libncurses6:arm64 libncurses5:arm64 libcups2:arm64 \
			libdbus-1-3:arm64 libfontconfig1:arm64 libfreetype6:arm64 libglu1-mesa:arm64 libgnutls30:arm64 \
			libgssapi-krb5-2:arm64 libkrb5-3:arm64 libodbc1:arm64 libosmesa6:arm64 libsdl2-2.0-0:arm64 libv4l-0:arm64 \
			libxcomposite1:arm64 libxcursor1:arm64 libxfixes3:arm64 libxi6:arm64 libxinerama1:arm64 libxrandr2:arm64 \
			libxrender1:arm64 libxxf86vm1:arm64 libc6:arm64 libcap2-bin:arm64
			exit_if_fail $? "64位依赖库安装失败"
			# libjpeg62-turbo:arm64 
	fi
fi


echo " 正在安装 winetricks"
sudo apt install -y winetricks
exit_if_fail $? "winetricks安装失败"
# # winetricks -q corefonts vcrun2010 dotnet20sp1
# # winetricks list-all
# # env WINE=${app_dir}/bin/wine WINEPREFIX=${HOME}/.wine64 winetricks mfc40u 


# echo "正在安装 wine-gecko(浏览器控件), wine-mono(C#运行时)"
if [ 1 -eq 0 ]; then
	# wine-gecko 安装 http://mirrors.ustc.edu.cn/wine/wine/wine-gecko/
	MSI64_gecko=wine-gecko-2.47.4-x86_64.msi
	if [ ! -f ${MSI64_gecko} ]; then
		/usr/bin/wget http://mirrors.ustc.edu.cn/wine/wine/wine-gecko/2.47.4/${MSI64_gecko}
		download_rlt=$?
		if [ $download_rlt -ne 0 ]; then rm -rf ${MSI64_gecko}; fi
		exit_if_fail $download_rlt "下载失败 => ${MSI64_gecko}"
	fi

	MSI32_gecko=wine-gecko-2.47.4-x86.msi
	if [ ! -f ${MSI32_gecko} ]; then
		/usr/bin/wget http://mirrors.ustc.edu.cn/wine/wine/wine-gecko/2.47.4/${MSI32_gecko}
		download_rlt=$?
		if [ $download_rlt -ne 0 ]; then rm -rf ${MSI32_gecko}; fi
		exit_if_fail $download_rlt "下载失败 => ${MSI32_gecko}"
	fi

	env WINEARCH=win32 WINEPREFIX=${HOME}/.wine32 /usr/local/bin/box86 ${app_dir}/bin/wine32 ${MSI32_gecko}
	env WINEARCH=win64 WINEPREFIX=${HOME}/.wine64 /usr/local/bin/box64 ${app_dir}/bin/wine64 start /i ${MSI64_gecko}

	# wine-mono  安装 http://mirrors.ustc.edu.cn/wine/wine/wine-gecko/
	MSI64_mono=wine-mono-8.0.0-x86.msi
	if [ ! -f ${MSI64_mono} ]; then
		/usr/bin/wget http://mirrors.ustc.edu.cn/wine/wine/wine-mono/8.0.0/${MSI64_mono}
		download_rlt=$?
		if [ $download_rlt -ne 0 ]; then rm -rf ${MSI64_mono}; fi
		exit_if_fail $download_rlt "下载失败 => ${MSI64_mono}"
	fi
	env WINEARCH=win64 WINEPREFIX=${HOME}/.wine64 /usr/local/bin/box64 ${app_dir}/bin/wine64 ${MSI64_mono}

fi


echo -e "正在创建文件链接, 请注意：跨CPU架构的wine，都不能直接启动, 在droidvm中是用box86/64来启动 . . ."
if [ 1 -eq 1 ]; then
	rm -rf ~/Desktop/wine.desktop
	rm -rf /usr/share/applications/wine.desktop
	rm -rf /usr/bin/exec32
	rm -rf /usr/bin/exec64
	rm -rf /usr/bin/wine
	rm -rf /usr/bin/wineboot
	rm -rf /usr/bin/winecfg
	rm -rf /usr/bin/wineserver
	sudo ln -s ${app_dir}/bin/wineboot		/usr/bin/wineboot
	sudo ln -s ${app_dir}/bin/winecfg		/usr/bin/winecfg
	sudo ln -s ${app_dir}/bin/wineserver	/usr/bin/wineserver

	echo '#!/bin/bash'																							> ~/exec64
	echo "    echo 'exec64 被调用了 =========================================================================='">>~/exec64
	echo 'if [ $# -eq 0 ]; then'																				>>~/exec64
	echo "    env WINEARCH=win64 WINEPREFIX=${HOME}/.wine64 /usr/local/bin/box64 ${app_dir}/bin/wine64 explorer">>~/exec64
	echo 'else'																									>>~/exec64
	echo "    env WINEARCH=win64 WINEPREFIX=${HOME}/.wine64 /usr/local/bin/box64 ${app_dir}/bin/wine64 \$@"		>>~/exec64
	echo 'fi'																									>>~/exec64

	echo '#!/bin/bash'																							> ~/exec32
	echo "    echo 'exec32 被调用了 =========================================================================='">>~/exec32
	echo 'if [ $# -eq 0 ]; then'																				>>~/exec32
	echo "    env WINEARCH=win32 WINEPREFIX=${HOME}/.wine32 /usr/local/bin/box86 ${app_dir}/bin/wine explorer"	>>~/exec32
	echo 'else'																									>>~/exec32
	echo "    env WINEARCH=win32 WINEPREFIX=${HOME}/.wine32 /usr/local/bin/box86 ${app_dir}/bin/wine \$@"		>>~/exec32
	echo 'fi'																									>>~/exec32

	sudo mv -f ~/exec64  /usr/bin/
	chmod 755 /usr/bin/exec64
	# sudo ln -s /usr/bin/exec64	/usr/bin/wine

	sudo mv -f ~/exec32  /usr/bin/
	chmod 755 /usr/bin/exec32
	# sudo ln -s /usr/bin/exec32	/usr/bin/wine
	# sudo ln -s /usr/bin/exec64	/usr/bin/wine

	# echo "为了能运行 winecfg, 需要设置 WINELOADER 环境变量"
	# echo "export WINELOADER=/usr/bin/exec64"	>>/etc/profile
	# source /etc/profile

	cp -f ${tools_dir}/misc/def_desktop/templates/wine.desktop ~/Desktop/
	echo "Exec=env WINEARCH=win64 WINEPREFIX=${HOME}/.wine64 /usr/local/bin/box64 ${app_dir}/bin/wine64 explorer" >> ~/Desktop/wine.desktop
	cp -f ~/Desktop/wine.desktop /usr/share/applications/
fi


which box64 >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo ""                                         > /tmp/msg.txt
    echo "检测到box64已经安装，是否现在启动wine？"  >>/tmp/msg.txt
    echo "提示：第一次启动wine要初始化，会非常慢"	>>/tmp/msg.txt
    gxmessage -title "提示" -file /tmp/msg.txt -center -buttons "启动:1,取消:0"
    if [ $? -eq 1 ]; then
        exec64 explorer
        # exec64 /sdcard/winrar-x64-621scp.exe
    fi
fi

touch ${app_dir}/installed
rm -rf ${tmp_dir}
echo "wine安装完成"
if [ $? -eq 0 ]; then
	echo "wine安装完成。"													> /tmp/msg.txt
	echo ""																	>>/tmp/msg.txt
	echo "请使用 exec32/exec64 指令运行windows程序, 比如:"					>>/tmp/msg.txt
	echo "exec64 cmd"														>>/tmp/msg.txt
	echo "exec64 explorer"													>>/tmp/msg.txt
	echo "exec64 taskmgr"													>>/tmp/msg.txt
	echo "exec64 winecfg"													>>/tmp/msg.txt
	echo ""																	>>/tmp/msg.txt
	echo "wine配置程序："													>>/tmp/msg.txt
	echo "exec64 winecfg"													>>/tmp/msg.txt
	echo ""																	>>/tmp/msg.txt
	echo "同时请注意总进程数量，不要超过32个(安卓对单个app进程数量的限制)"	>>/tmp/msg.txt
	echo ""																	>>/tmp/msg.txt
	gxmessage -title "提示" -file /tmp/msg.txt  -center
	# read -s -n1 -p "按任意键继续 ... "
fi
