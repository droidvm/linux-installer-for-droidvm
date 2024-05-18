#!/bin/bash

action=$1
if [ "$action" == "" ]; then action=安装; fi

SWNAME=jwm
swVer=2.4.2

SWMGR_DIR=`pwd`
TMPDIR=${SWMGR_DIR}/tmp

abis="arm64-v8a"  #arm64-v8a armeabi-v7a x86_64 x86
NDK_DIR=/media/lenovo/sw/downloads/android-ndk-r23b
NDK_DIR=/opt/apps/android-ndk-r25c
NDK_DIR=/mnt/d/downloads/android-ndk-r23b


. ./scripts/common.sh


function sw_download() {

	sudo apt-get -y install dpkg-dev
	exit_if_fail $? "dpkg-dev安装失败"

	# # ndk installed?
	# [ -d $NDK_DIR ]
	# exit_if_fail $? "android-ndk 路径错误: ${NDK_DIR}\n(用于安卓的 ${SWNAME} , 必须使用android-ndk编译)"

	zz_enable_src_apt

	export SRC_DIR="${TMPDIR}/${SWNAME}-${swVer}"
	echo "SRC_DIR: ${SRC_DIR}"
	# exit 1

	if [ ! -d ${SRC_DIR} ]; then
		cd ${TMPDIR}
		apt-get source ${SWNAME}
		exit_if_fail $? "从apt仓库下载源码失败, 源码项目名称：${SWNAME}"

		# sudo apt build-dep -y -aarmhf ${SWNAME} # 可以指定架构
		sudo apt build-dep -y ${SWNAME}
		exit_if_fail $? "源码项目编译过程的依赖库/依赖程序安装失败"

		echo "正在修改源码"
		cd ${SRC_DIR}
		patch -p1 < ${SWMGR_DIR}/scripts/res/libfm.patch
		exit_if_fail $? "源码修改失败：${SWNAME}"

		# # 有些项目的源码，修改后需要 commit 才能编译, 比如 libfm, 实测 weston 不需要，反而还省点事了
		# # dpkg-source --commit
	else
		echo "正在修改源码"
		cd ${SRC_DIR}
		patch -p1 < ${SWMGR_DIR}/scripts/res/libfm.patch
		exit_if_fail $? "源码修改失败：${SWNAME}"
	fi


}

function sw_compile() {

	command -v patchelf >/dev/null 2>&1 || sudo apt-get install -y patchelf
	exit_if_fail $? "patchelf 安装失败"

	export BOX64_NOBANNER=1
	export BOX64_LOG=0
	export BOX64_DYNAREC_LOG=0

	for abi in ${abis}
	do
		echo -e "\n当前架构: ${abi}"
		mkrlt=2
		case "${abi}" in
			"arm64-v8a")
				CPLARCH=aarch64
				OS_ARCH=arm64
				;;
			"armeabi-v7a")
				CPLARCH=armv7a
				OS_ARCH=arm32
				;;
			"x86_64")
				CPLARCH=x86_64
				OS_ARCH=amd64
				;;
			"x86")
				CPLARCH=i686
				OS_ARCH=amd32
				;;
			*)
				echo "不支持的abi: |${abi}|"
				exit 2
				;;
		esac

		export INSTALL_DIR="${SRC_DIR}/release/${OS_ARCH}"
		mkdir -p "$INSTALL_DIR"

		cd ${SRC_DIR}
		pwd

		echo "正在编译"
		# dpkg-buildpackage -nc -us -uc -j12 -aarmhf # 可以指定架构
		dpkg-buildpackage -nc -us -uc -j12
		exit_if_fail $? "编译失败"

		echo "正在打包"
		cp  -f ${SRC_DIR}/../ jwm_${swVer}-1_arm64.deb		${INSTALL_DIR}/
		echo "编译完成，请查看：$INSTALL_DIR"

	done
}

function sw_create_desktop_file() {
	echo ""
}

if [ "${action}" == "卸载" ]; then
	echo "暂不支持卸载"
	exit 1
else

	sw_download
	sw_compile
	sw_create_desktop_file
fi
