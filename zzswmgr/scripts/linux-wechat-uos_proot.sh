#!/bin/bash

: '
微信只对uos发由的linux版本
但此版本，在proot-ubuntu中无法运行
所以搞了个 debian-rootfs 来运行
'


SWNAME=wechat-uos
SWVER=2.1.9

# 注意安装顺序，后装者依赖前装者
DEB_PATH1=./downloads/${SWNAME}-${SWVER}.deb
DEB_PATH2=./downloads/debian-bookworm-rootfs.tar.xz
DEB_PATH3=./downloads/libssl1.1.deb
DEB_PATH4=./downloads/openssl_3.1.4-2_arm64.deb

DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh

app_dir=/opt/apps/${SWNAME}-${SWVER}
mkdir -p ${app_dir} 2>/dev/null

function sw_download() {
	case "${CURRENT_VM_ARCH}" in
		"arm64")
			swUrl="https://home-store-packages.uniontech.com/appstore/pool/appstore/c/com.tencent.weixin/com.tencent.weixin_${SWVER}_arm64.deb"
			download_file2 "${DEB_PATH1}" "${swUrl}"
			exit_if_fail $? "下载失败，网址：${swUrl}"

			wget https://mirrors.tuna.tsinghua.edu.cn/lxc-images/images/debian/bookworm/arm64/default/ -O index.html  2>&1
			IMAGE_TMP_FIELD=$(busybox cat index.html |grep 'title="20'|grep 'href="20'|awk -v FS="\"" '{print $4}'|head -c 16)
			IMAGE_TMP_FIELD="https://mirrors.tuna.tsinghua.edu.cn/lxc-images/images/debian/bookworm/arm64/default/${IMAGE_TMP_FIELD}/rootfs.tar.xz"
			echo "DEBIAN ROOTFS 下载地址：$IMAGE_TMP_FIELD"
			download_file2 "${DEB_PATH2}" "${IMAGE_TMP_FIELD}"
			exit_if_fail $? "下载失败，网址：${IMAGE_TMP_FIELD}"

			swUrl="http://mirrors.tuna.tsinghua.edu.cn/debian/pool/main/o/openssl/libssl1.1_1.1.1n-0%2Bdeb10u3_arm64.deb"
			download_file2 "${DEB_PATH3}" "${swUrl}"
			exit_if_fail $? "下载失败，网址：${swUrl}"

			swUrl="https://mirrors.tuna.tsinghua.edu.cn/debian/pool/main/o/openssl/openssl_3.1.4-2_arm64.deb"
			download_file2 "${DEB_PATH4}" "${swUrl}"
			exit_if_fail $? "下载失败，网址：${swUrl}"

			tmp_wdir=`pwd`
			cd ./downloads
			apt-get download ca-certificates
			exit_if_fail $? "下载失败，网址：ca-certificates"
			cd ${tmp_wdir}

			cp -f ./scripts/res/deepin-elf-verify_all.deb ./downloads/

		;;
		# "amd64")
		# 	swUrl="https://home-store-packages.uniontech.com/appstore/pool/appstore/c/com.tencent.weixin/com.tencent.weixin_2.1.9_amd64.deb"
		# 	download_file2 "${DEB_PATH1}" "${swUrl}"
		# 	exit_if_fail $? "下载失败，网址：${swUrl}"
		# ;;
		*) exit_unsupport ;;
	esac
}

function sw_install() {

	sudo apt-get install -y xz-utils unzip
	exit_if_fail $? "解压工具xz安装失败"

	if [ ! -d /exbin/vm/debian ]; then
		echo "正在解压 debian rootfs. . ."
		mkdir -p /exbin/vm/debian 2>/dev/null
		tar -xJf ${DEB_PATH2} --overwrite -C /exbin/vm/debian
		if [ $? -ne 0 ]; then
			rm -rf /exbin/vm/debian
			false
			exit_if_fail $? "安装失败，无法解压：${DEB_PATH2}"
		fi
	fi

	echo "正在解压 uos-fake . . ."
	unzip -oq ./scripts/res/uos-fake.zip -d /exbin/vm/debian/
	exit_if_fail $? "uos-fake 安装失败"

	STARTUP_SCRIPT_FILE=/exbin/vm/debian/start_debian.sh
	cat <<- EOF > ${STARTUP_SCRIPT_FILE}
		#!/system/bin/sh
		echo "正在安卓端通过proot加载debian-rootfs"
		echo "CONSOLE_ENV: \$CONSOLE_ENV"
		export CONSOLE_ENV=android
		pwd
		echo "CONSOLE_ENV: \$CONSOLE_ENV"
		echo -e "\n\n\n"
		. ./tools/vm_config.sh
		pwd
		# ls -al ./tools/
		echo "CONSOLE_ENV: \$CONSOLE_ENV"
		set|grep PROOT
		LINUX_DIR=\${app_home}/vm/debian
		unset LD_PRELOAD
		command="\${PROOT_BINARY_DIR}/proot"
		command+=" --link2symlink"
		command+=" --kill-on-exit"
		command+=" -0"
		command+=" -r \$LINUX_DIR"
        command+=" -L"
		command+=" -b /apex"
		command+=" -b /linkerconfig"
		command+=" -b /system -b /dev -b /:/host-rootfs"
		command+=" -b /dev/urandom:/dev/random"
		command+=" -b /dev"
		command+=" -b /proc"
		command+=" -b /proc/self/fd:/dev/fd"
		command+=" -b /proc/self/fd/0:/dev/stdin"
		command+=" -b /proc/self/fd/1:/dev/stdout"
		command+=" -b /proc/self/fd/2:/dev/stderr"
		command+=" -b \${tools_dir}/fake_proc/.loadavg:/proc/loadavg"
		command+=" -b \${tools_dir}/fake_proc/.stat:/proc/stat"
		command+=" -b \${tools_dir}/fake_proc/.uptime:/proc/uptime"
		command+=" -b \${tools_dir}/fake_proc/.version:/proc/version"
		command+=" -b \${tools_dir}/fake_proc/.vmstat:/proc/vmstat"
		command+=" -b \${tools_dir}/zzswmgr/downloads:/downloads"
		command+=" -b /sys"
		command+=" -b \$PROOT_TMP_DIR:/dev/shm"
		command+=" -b \$app_home:/exbin"
		command+=" -b \$app_home"    # 映射了这个目录后 dotnet 才可以运行！
		command+=" -b /sdcard"
		command+=" -b /storage"     # 安卓外接的otg U盘会挂在这个路径下，权限与 /sdcard 共享
		command+=" -w /root"
		command+=" /usr/bin/env -i"
		command+=" HOME=/root"
		command+=" TMPDIR=/tmp"
		command+=" PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games:/exbin"
		command+=" TERM=vt100"	#不同的终端类型支持不同的功能，比如：终端文字着色，光标随意定位。。。，不设置的话不能在终端中运行 reset 指令
		command+=" LANG=C.UTF-8"
		command+=" /autorun_debian.sh"
	    \$command 2>&1
	EOF
	chmod a+x ${STARTUP_SCRIPT_FILE}

	STARTUP_SCRIPT_FILE=/exbin/vm/debian/autorun_debian.sh
	cat <<- EOF > ${STARTUP_SCRIPT_FILE}
		#!/bin/bash

		echo "debian 加载完成"

		function exit_if_fail() {
			rlt_code=\$1
			fail_msg=\$2
			if [ \$rlt_code -ne 0 ]; then
			echo -e "错误码: \${rlt_code}\n\${fail_msg}"
			# read -s -n1 -p "按任意键退出"
			exit \$rlt_code
			fi
		}

		apt list --installed|grep ca-certificates
		if [ \$? -ne 0 ]; then
			echo "正在将debian的apt软件仓库切换成国内的仓库"
			apt-get install -y /downloads/openssl_3.1.4-2_arm64.deb
			apt-get install -y /downloads/ca-certificates*.deb

			cp -f /etc/apt/sources.list	/etc/apt/sources.list.bak_debian
			cp -f /etc/apt/sources.list.bak_tsinghua /etc/apt/sources.list
			apt update

			cp -f /etc/lsb-release    /etc/lsb-release.debian
			cp -f /usr/lib/os-release /usr/lib/os-release.debian
		fi

		if [ ! -x /opt/apps/com.tencent.weixin/files/weixin/weixin ]; then
			apt-get install -y \
			/downloads/libssl1.1.deb \
			/downloads/deepin-elf-verify_all.deb \
			/downloads/${SWNAME}-${SWVER}.deb \
			libasound2 ttf-wqy-microhei
			exit_if_fail $? "依赖包安装失败"

			cp -f /autorun_startwx.sh /autorun_debian.sh
			echo "微信安装完成"
		else
			cp -f /autorun_startwx.sh /autorun_debian.sh
			echo "微信安装完成"
		fi

		# echo "正在启动 bash"
		# bash
	EOF
	chmod a+x ${STARTUP_SCRIPT_FILE}

	STARTUP_SCRIPT_FILE=/exbin/vm/debian/autorun_startwx.sh
	cat <<- EOF > ${STARTUP_SCRIPT_FILE}
		#!/bin/bash

		echo "debian 加载完成"

		if [ -x /opt/apps/com.tencent.weixin/files/weixin/weixin ]; then
			cat <<- FILEEND > /etc/lsb-release.uos
				DISTRIB_ID=uos
				DISTRIB_RELEASE=20
				DISTRIB_DESCRIPTION=UnionTech OS 20
				DISTRIB_CODENAME=eagle
			FILEEND

			cat <<- FILEEND > /usr/lib/os-release.uos
				PRETTY_NAME=UnionTech OS Desktop 20 Pro
				NAME=uos
				VERSION_ID=20
				VERSION=20
				ID=uos
				HOME_URL=https://www.chinauos.com/
				BUG_REPORT_URL=http://bbs.chinauos.com
				VERSION_CODENAME=eagle
			FILEEND

			cp -f /etc/lsb-release.uos    /etc/lsb-release
			cp -f /usr/lib/os-release.uos /usr/lib/os-release
			export DISPLAY=127.0.0.1${DISPLAY}
			/opt/apps/com.tencent.weixin/files/weixin/weixin --no-sandbox
			echo "wx返回值：$?"
			cp -f /etc/lsb-release.debian    /etc/lsb-release
			cp -f /usr/lib/os-release.debian /usr/lib/os-release

			# echo "正在启动 bash"
			# bash
		else
			echo "微信未安装"
		fi
	EOF
	chmod a+x ${STARTUP_SCRIPT_FILE}

	
	STARTUP_SCRIPT_FILE=${app_dir}/weixin.sh
	cat <<- EOF > ${STARTUP_SCRIPT_FILE}
		#!/bin/bash
		# 在安卓端运行!
		exec droidexec ./vm/debian/start_debian.sh
	EOF
	chmod a+x ${STARTUP_SCRIPT_FILE}


	cat <<- EOF > /exbin/vm/debian/etc/apt/sources.list.bak_tsinghua
		# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
		deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free non-free-firmware
		# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free non-free-firmware

		deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware
		# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware

		deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-backports main contrib non-free non-free-firmware
		# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-backports main contrib non-free non-free-firmware

		deb https://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
		# deb-src https://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
	EOF

	echo "" >/etc/resolv.conf
	echo "# dns.google.com" >>/etc/resolv.conf
	echo "nameserver 8.8.8.8" >>/etc/resolv.conf

	# 获取安卓端dns，填到虚拟系统中
	echo "" >>/etc/resolv.conf
	echo "# copy form android side" >>/etc/resolv.conf
	ip route list table 0|grep default|grep via|awk '{print "nameserver "$3}' >>/etc/resolv.conf
	cat <<- EOF >> /exbin/vm/debian/etc/resolv.conf
		# others
		nameserver 223.5.5.5
		nameserver 223.6.6.6
		nameserver 2400:3200::1
		nameserver 2400:3200:baba::1
		nameserver 114.114.114.114
		nameserver 114.114.115.115
		nameserver 240c::6666
		nameserver 240c::6644

		options single-request-reopen
		options timeout:2
		options attempts:3
		options rotate
		options use-vc      # 走TCP
	EOF

	cat <<- EOF > /exbin/vm/debian/etc/hosts
		# IPv4.
		127.0.0.1   localhost.localdomain localhost

		# IPv6.
		::1         localhost.localdomain localhost ip6-localhost ip6-loopback
		fe00::0     ip6-localnet
		ff00::0     ip6-mcastprefix
		ff02::1     ip6-allnodes
		ff02::2     ip6-allrouters
		ff02::3     ip6-allhosts

		# IPv4. add by droidvm

		112.74.190.222  home-store-packages.uniontech.com
		112.86.231.46	droidvmres-1316343437.cos.ap-shanghai.myqcloud.com
		180.76.198.77	gitee.com
		180.76.198.77	foruda.gitee.com
		39.155.141.16	mirrors.bfsu.edu.cn
		218.104.71.170	mirrors.ustc.edu.cn
		101.6.15.130	mirrors.tuna.tsinghua.edu.cn
		185.125.190.36	ports.ubuntu.com
		185.125.190.39	ports.ubuntu.com
		91.189.91.82	security.ubuntu.com
		91.189.91.81	security.ubuntu.com
		185.125.190.36	security.ubuntu.com
		185.125.190.39	security.ubuntu.com
		91.189.91.83	security.ubuntu.com
		151.101.2.132   security.debian.org
		151.101.2.132   deb.debian.org

		# IPv6. add by droidvm
		2402:f000:1:400::2				pypi.tuna.tsinghua.edu.cn
		2402:f000:1:400::2				mirror.tuna.tsinghua.edu.cn
		2620:2d:4000:1::16              archive.ubuntu.com
		2408:8748:b500:214:3::3e5		mirrors.aliyun.com
		# 2409:8700:2482:710::fe55:2840 mirrors.bfsu.edu.cn
		# 2001:da8:d800:95::110         mirrors.ustc.edu.cn
		# 2402:f000:1:400::2            mirrors.tuna.tsinghua.edu.cn
		# 2620:2d:4000:1::16            ports.ubuntu.com
		# 2620:2d:4000:1::19            security.ubuntu.com
	EOF

	# 在安卓端运行!
	lxterminal -e droidexec ./vm/debian/start_debian.sh

}

function sw_create_desktop_file() {

	echo "正在生成桌面文件"
	tmpfile=${DIR_DESKTOP_FILES}/${SWNAME}.desktop
	echo "[Desktop Entry]"					> ${tmpfile}
	echo "Encoding=UTF-8"					>>${tmpfile}
	echo "Version=0.9.4"					>>${tmpfile}
	echo "Name=微信"						>>${tmpfile}
	echo "Exec=${app_dir}/weixin.sh"		>>${tmpfile}
	echo "Terminal=false"					>>${tmpfile}
	echo "Type=Application"					>>${tmpfile}
	echo "StartupWMClass=微信"				>>${tmpfile}
	echo "Categories=Network;"				>>${tmpfile}
	echo "Comment=微信UOS版"				>>${tmpfile}
	echo "Icon=weixin"						>>${tmpfile}
	cp2desktop ${tmpfile}

	cat <<- EOF > /tmp/msg.txt

		安装完成.

		【警告】
		proot虚拟系统中的权限是不完整的
		请权衡后再使用此微信客户端！

	EOF
	gxmessage -title "提示" -file /tmp/msg.txt -center
	# gxmessage -title "提示"     $'\n安装完成\n\n'  -center
}

if [ "${action}" == "卸载" ]; then
	# echo "暂不支持卸载"
	# exit 1
	rm -rf ${app_dir} /exbin/vm/debian ${DIR_DESKTOP_FILES}/${SWNAME}.desktop
	rm2desktop ${SWNAME}.desktop
else
	sw_download
	sw_install
	sw_create_desktop_file
fi

