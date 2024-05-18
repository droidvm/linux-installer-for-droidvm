#!/bin/bash

SWNAME=mkbootudisk
DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh

function sw_install() {
	app_dir=/opt/apps/${SWNAME}


	if [ ! -d /opt/apps/qemu-linux-amd64 ]; then
		echo ""							> /tmp/msg.txt
		echo "请先安装qemu-linux-amd64"	>>/tmp/msg.txt
		echo ""							>>/tmp/msg.txt
		gxmessage -title "提示" -file /tmp/msg.txt -center
		exit 1
	fi

	# if [ ! -f ${app_dir}/winpe.zip ]; then
	# 	gxmessage -title "提示"     $'\n启动文件寄存在gitee(未付费)\n下载速度被限制为500kb/s，所以下载过程会比较久(250M，约9分钟)\n\n请耐心等待！\n\n'  -center  -buttons "我知道了:0,取消安装:1"
	# 	if [ $? -ne 0 ]; then
	# 		echo "您已取消安装"
	# 		exit 1
	# 	fi
	# fi

	apt-get install -y git unzip
	exit_if_fail $? "git安装失败"

	cp -Rf ./ezapp/mkbootudisk /opt/apps/
	exit_if_fail $? "安装失败，无法复制文件到 /opt/apps/"

	chmod 755 ${app_dir}/*

	# DEB_PATH=${app_dir}/winpe.zip
	# swUrl=${APP_URL_DLSERVER}/winpe.zip
	# download_file2 "${DEB_PATH}" "${swUrl}"
	# exit_if_fail $? "下载失败，网址：${swUrl}"

	swUrl=https://gitee.com/droidvm/upan
	download_file3 "${app_dir}/winpe" "${swUrl}"
	exit_if_fail $? "下载失败，网址：${swUrl}"

	DEB_PATH1=${app_dir}/freedos_x86_fat32.zip
	swUrl=https://mirror.ghproxy.com/https://github.com/FDOS/kernel/releases/download/ke2043/ke2043_86f32.zip
	download_file2 "${DEB_PATH1}" "${swUrl}"
	exit_if_fail $? "下载失败，网址：${swUrl}"

	swUrl=https://gitee.com/droidvm/freedos-tools
	download_file3 "${app_dir}/freedos-tools" "${swUrl}"
	exit_if_fail $? "下载失败，网址：${swUrl}"
	rm -rf "${app_dir}/freedos-tools/.git"


	# 把多个 upan.zip.* 压缩包合并成一个压缩包
	cat ${app_dir}/winpe/upan.zip.* > ${app_dir}/winpe.zip
	exit_if_fail $? "无法合并zip文件"


	mkdir -p ${app_dir}/shared/pre_download_debs 2>/dev/null
	cd ${app_dir}/shared/pre_download_debs

	# unzip dosfstools fdisk grub2
	zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/l/lvm2/libdevmapper1.02.1_1.02.175-2.1ubuntu4_amd64.deb
	zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/l/lvm2/dmsetup_1.02.175-2.1ubuntu4_amd64.deb
	zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/r/readline/readline-common_8.1.2-1_all.deb
	zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/r/readline/libreadline8_8.1.2-1_amd64.deb
	zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/u/ucf/ucf_3.0043_all.deb
	zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/d/dosfstools/dosfstools_4.2-1build3_amd64.deb
	zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/g/gettext/gettext-base_0.21-4ubuntu4_amd64.deb
	zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/f/fuse3/libfuse3-3_3.10.5-1build1_amd64.deb
	zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/libp/libpng1.6/libpng16-16_1.6.37-3build5_amd64.deb
	zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/u/util-linux/libfdisk1_2.37.2-4ubuntu3.4_amd64.deb
	zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/u/util-linux/fdisk_2.37.2-4ubuntu3.4_amd64.deb
	zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/e/efivar/libefivar1_37-6ubuntu2_amd64.deb
	zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/e/efivar/libefiboot1_37-6ubuntu2_amd64.deb
	zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/b/brotli/libbrotli1_1.0.9-2build6_amd64.deb
	zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/f/freetype/libfreetype6_2.11.1%2bdfsg-1ubuntu0.2_amd64.deb
	zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/g/grub2/grub-common_2.06-2ubuntu7.2_amd64.deb
	zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/g/grub2/grub2-common_2.06-2ubuntu7.2_amd64.deb
	zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/g/grub2/grub-pc-bin_2.06-2ubuntu7.2_amd64.deb
	zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/g/grub2/grub-pc_2.06-2ubuntu7.2_amd64.deb
	zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/g/grub-gfxpayload-lists/grub-gfxpayload-lists_0.7_amd64.deb
	zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/o/os-prober/os-prober_1.79ubuntu2_amd64.deb
	zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/u/unzip/unzip_6.0-26ubuntu3.2_amd64.deb
	zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/universe/g/grub2/grub2_2.06-2ubuntu7.2_amd64.deb

	cd ${ZZSWMGR_MAIN_DIR}

}

function sw_create_desktop_file() {
	echo "[Desktop Entry]"								> ${DSK_PATH}
	echo "Encoding=UTF-8"								>>${DSK_PATH}
	echo "Version=0.9.4"								>>${DSK_PATH}
	echo "Type=Application"								>>${DSK_PATH}
	echo "Name=制作启动U盘"								>>${DSK_PATH}
	echo "Comment=制作WINPE启动U盘"						>>${DSK_PATH}
	echo "Exec=lxterminal -e ${app_dir}/mkbootudisk.sh"	>> ${DSK_PATH}
	echo "Terminal=false"								>>${DSK_PATH}

	cp2desktop ${DSK_PATH}

	echo "安装已完成"
	gxmessage -title "提示" "安装已完成"  -center
}

if [ "${action}" == "卸载" ]; then
	# echo "暂不支持卸载"
	# exit 1

	set -x	# echo on

	rm -rf ./downloads/${SWNAME}.zip

	rm -rf /opt/apps/${SWNAME}

	rm2desktop ${SWNAME}.desktop

	apt-get clean

	set +x	# echo off
else
	# sw_download
	sw_install
	sw_create_desktop_file
fi
