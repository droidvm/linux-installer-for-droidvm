#!/bin/bash


SWNAME=qemu-linux-amd64
DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh

DEB_PATH=./downloads/${SWNAME}_kernel_amd64.tar.gz
TAR_PATH=./downloads/${SWNAME}_rootfs_amd64.tar.gz
app_dir=/opt/apps/${SWNAME}

function sw_download() {

	# if [ "$action" == "重装" ]; then
	# 	echo "正在删除之前下载的安装包"
	# 	rm -rf ${DEB_PATH} ${TAR_PATH}
	# fi

	# 2024.05.13 废弃了
	# # swUrl=${APP_URL_DLSERVER}/qemu-linux-amd64.zip
	# swUrl=https://gitee.com/droidvm/build_mylinux/releases/download/v0.01/qemu-linux-amd64.zip
	# download_file2 "${DEB_PATH}" "${swUrl}"
	# exit_if_fail $? "下载失败，网址：${swUrl}"

	# kernel with usbip compile-in
	swUrl=https://gitee.com/droidvm/build_mylinux/releases/download/v0.02/linux-amd64.tar.gz
	download_file2 "${DEB_PATH}" "${swUrl}"
	exit_if_fail $? "下载失败，网址：${swUrl}"

	# base-rootfs
	swUrl=https://mirror.tuna.tsinghua.edu.cn/ubuntu-cdimage/ubuntu-base/releases/jammy/release/ubuntu-base-22.04-base-amd64.tar.gz
	download_file2 "${TAR_PATH}" "${swUrl}"
	exit_if_fail $? "下载失败，网址：${swUrl}"

	# PRE_DL_PKGS="ca-certificates udev wget usb.ids usbutils unzip dosfstools fdisk grub2"
	# apt-get install --print-uris -y ${PRE_DL_PKGS}|grep ^\'http|awk '{print $1}'
	echo ""
    echo "apt 安装的同时显示下载链接"
    echo "apt-get install --print-uris -y 包名"


	mkdir -p ${app_dir}/shared/pre_download_debs 2>/dev/null
	cd ${app_dir}/shared/pre_download_debs

	# ca-certificates
	zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/o/openssl/libssl3_3.0.2-0ubuntu1.15_amd64.deb
	zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/o/openssl/openssl_3.0.2-0ubuntu1.15_amd64.deb
	zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/c/ca-certificates/ca-certificates_20230311ubuntu0.22.04.1_all.deb

	# # udev wget usb.ids usbutils
	# zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/s/systemd/libudev1_249.11-0ubuntu3.12_amd64.deb
	# zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/k/kmod/libkmod2_29-1ubuntu1_amd64.deb
	# zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/s/systemd/udev_249.11-0ubuntu3.12_amd64.deb
	# zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/libp/libpsl/libpsl5_0.21.0-1.2build2_amd64.deb
	# zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/libu/libusb-1.0/libusb-1.0-0_1.0.25-1ubuntu2_amd64.deb
	# zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/p/publicsuffix/publicsuffix_20211207.1025-1_all.deb
	# zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/u/usb.ids/usb.ids_2022.04.02-1_all.deb
	# zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/u/usbutils/usbutils_014-1build1_amd64.deb
	# zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/w/wget/wget_1.21.2-2ubuntu1_amd64.deb
	# zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/s/systemd-hwe/systemd-hwe-hwdb_249.11.5_all.deb

	# # unzip dosfstools fdisk grub2
	# zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/l/lvm2/libdevmapper1.02.1_1.02.175-2.1ubuntu4_amd64.deb
	# zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/l/lvm2/dmsetup_1.02.175-2.1ubuntu4_amd64.deb
	# zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/r/readline/readline-common_8.1.2-1_all.deb
	# zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/r/readline/libreadline8_8.1.2-1_amd64.deb
	# zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/u/ucf/ucf_3.0043_all.deb
	# zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/d/dosfstools/dosfstools_4.2-1build3_amd64.deb
	# zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/g/gettext/gettext-base_0.21-4ubuntu4_amd64.deb
	# zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/f/fuse3/libfuse3-3_3.10.5-1build1_amd64.deb
	# zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/libp/libpng1.6/libpng16-16_1.6.37-3build5_amd64.deb
	# zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/u/util-linux/libfdisk1_2.37.2-4ubuntu3.4_amd64.deb
	# zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/u/util-linux/fdisk_2.37.2-4ubuntu3.4_amd64.deb
	# zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/e/efivar/libefivar1_37-6ubuntu2_amd64.deb
	# zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/e/efivar/libefiboot1_37-6ubuntu2_amd64.deb
	# zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/b/brotli/libbrotli1_1.0.9-2build6_amd64.deb
	# zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/f/freetype/libfreetype6_2.11.1%2bdfsg-1ubuntu0.2_amd64.deb
	# zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/g/grub2/grub-common_2.06-2ubuntu7.2_amd64.deb
	# zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/g/grub2/grub2-common_2.06-2ubuntu7.2_amd64.deb
	# zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/g/grub2/grub-pc-bin_2.06-2ubuntu7.2_amd64.deb
	# zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/g/grub2/grub-pc_2.06-2ubuntu7.2_amd64.deb
	# zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/g/grub-gfxpayload-lists/grub-gfxpayload-lists_0.7_amd64.deb
	# zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/o/os-prober/os-prober_1.79ubuntu2_amd64.deb
	# zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/main/u/unzip/unzip_6.0-26ubuntu3.2_amd64.deb
	# zzget https://mirrors.tuna.tsinghua.edu.cn/ubuntu/pool/universe/g/grub2/grub2_2.06-2ubuntu7.2_amd64.deb

	cd ${ZZSWMGR_MAIN_DIR}

}


function edit_rootfs() {
SW_SOURCE_X86="
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse

deb http://security.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse
# deb-src http://security.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse

# 预发布软件源，不建议启用
# deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-proposed main restricted universe multiverse
# # deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-proposed main restricted universe multiverse
"

VM_NAMESERVER="
nameserver 8.8.8.8
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
"

	DIR_ROOTFS=${app_dir}/rootfs
	DIR_KNLMOD=${app_dir}/kernel/kernel-related/kernel_modules
	DIR_KNLAPP=${app_dir}/kernel/kernel-related/kernel_userapp

	sudo cp -R ${app_dir}/utils/* ${DIR_ROOTFS}/
	exit_if_fail $? "启动脚本 复制失败"

	# sudo mkdir -p ${DIR_ROOTFS}/var/cache/pre_download_debs 2>/dev/null
	# sudo cp -Rf ${app_dir}/pre_download_debs/* ${DIR_ROOTFS}/var/cache/pre_download_debs/
	# exit_if_fail $? "deb 安装包复制失败"

	echo "正在复制 内核密相关模块(在编译内核模块时生成)"
	sudo cp -R ${DIR_KNLMOD}/* ${DIR_ROOTFS}/usr/
	exit_if_fail $? "内核密相关模块 复制失败"

	echo "正在复制 内核密相关软件(在编译内核软件时生成)"
	sudo cp -R ${DIR_KNLAPP}/* ${DIR_ROOTFS}/usr/
	exit_if_fail $? "内核密相关软件 复制失败"

    sudo echo "${SW_SOURCE_X86}"   > ${DIR_ROOTFS}/etc/apt/sources.list.cn.amd64
    exit_if_fail $? "软件下载仓库地址 修改失败"

    echo "zzvm" >  ${DIR_ROOTFS}/etc/hostname
    exit_if_fail $? "hostname 修改失败"

    sudo chmod 666                      ${DIR_ROOTFS}/etc/resolv.conf
    sudo echo "${VM_NAMESERVER}"       >${DIR_ROOTFS}/etc/resolv.conf
    exit_if_fail $? "DNS服务器 修改失败"

}

function rootfs2qemuImg() {
	IMG_ROOTFS=${app_dir}/virhd-amd64.img
	VHDIMGSIZE=999M
	qemu-img create  -f raw  ${IMG_ROOTFS}    ${VHDIMGSIZE}
    exit_if_fail $? "qemuImg 创建失败"

	sudo mkfs.ext4 -L rootfs ${IMG_ROOTFS} -d ${DIR_ROOTFS}
    exit_if_fail $? "qemuImg 格盘失败"

	# qemu-img convert -f raw  ${IMG_ROOTFS} -O qcow2 ${IMG_ROOTFS}.qcow2
    # exit_if_fail $? "qemuImg 格式失败"
	# apt-get install --print-uris -y ca-certificates udev wget usb.ids usbutils

}


function sw_install() {
	# apt-get install -y unzip
	# exit_if_fail $? "解压工具unzip安装失败"

	# echo "正在解压. . ."
	# mkdir -p ${app_dir} 2>/dev/null
	# unzip -oq ${DEB_PATH} -d ${app_dir}
	# exit_if_fail $? "安装失败，软件包：${DEB_PATH}"


	apt-get install -y qemu-system-x86
	exit_if_fail $? "qemu-system安装失败"

	mkdir -p ${app_dir}/shared 2>/dev/null
	cp -Rf ./ezapp/qemu-linux-amd64 /opt/apps/
	exit_if_fail $? "安装失败，无法复制文件到 /opt/apps/"

	chmod 755 ${app_dir}/qemu-linux-amd64.sh
	chmod 755 ${app_dir}/utils/*

	echo "正在解压内核. . ."
	mkdir -p ${app_dir}/kernel 2>/dev/null
	tar -xzf ${DEB_PATH} --overwrite -C ${app_dir}/kernel
	exit_if_fail $? "安装失败，软件包：${DEB_PATH}"

	echo "正在解压rootfs. . ."
	mkdir -p ${app_dir}/rootfs 2>/dev/null
	tar -xzf ${TAR_PATH} --overwrite -C ${app_dir}/rootfs
	exit_if_fail $? "安装失败，软件包：${TAR_PATH}"

	edit_rootfs
	rootfs2qemuImg
}


function sw_create_desktop_file() {
	echo "正在生成桌面文件"
	tmpfile=${DIR_DESKTOP_FILES}/${SWNAME}.desktop
	echo "[Desktop Entry]"			> ${tmpfile}
	echo "Encoding=UTF-8"			>>${tmpfile}
	echo "Version=0.9.4"			>>${tmpfile}
	echo "Type=Application"			>>${tmpfile}
	echo "Terminal=true"			>>${tmpfile}
	echo "Name=小型linux"			>>${tmpfile}
	echo "Exec=${app_dir}/qemu-linux-amd64.sh %f"	>> ${tmpfile}
	cp2desktop ${tmpfile}
}

if [ "${action}" == "卸载" ]; then
	# echo "暂不支持卸载"
	# exit 1

	set -x	# echo on
	apt-get autopurge -y qemu-system-x86
	rm -rf ${app_dir}
	rm -rf ${DEB_PATH} ${TAR_PATH}
	rm2desktop ${SWNAME}.desktop
	apt-get clean
	set +x	# echo off

else
	sw_download
	sw_install
	sw_create_desktop_file
fi
