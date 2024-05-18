#!/bin/bash

action=$1
if [ "$action" == "" ]; then action=安装; fi

SWNAME=tcc
swVer=2.4.2

SWMGR_DIR=`pwd`


. ./scripts/common.sh


function sw_download() {

	( apt list --installed|grep dpkg-dev) || apt-get -y install dpkg-dev
	exit_if_fail $? "dpkg-dev安装失败"

	# # ndk installed?
	# [ -d $NDK_DIR ]
	# exit_if_fail $? "android-ndk 路径错误: ${NDK_DIR}\n(用于安卓的 ${SWNAME} , 必须使用android-ndk编译)"

	zz_enable_src_apt

	dir_tmp=`ls -a  ${ZZSWMGR_TEMP_DIR}|grep tcc-|tail -n 1`
	export SRC_DIR="${ZZSWMGR_TEMP_DIR}/${dir_tmp}"

	if [ ! -d ${SRC_DIR} ]; then
		cd ${ZZSWMGR_TEMP_DIR}
		apt-get source ${SWNAME}
		exit_if_fail $? "从apt仓库下载源码失败, 源码项目名称：${SWNAME}"

		dir_tmp=`ls -a  ${ZZSWMGR_TEMP_DIR}|grep tcc-|tail -n 1`
		export SRC_DIR="${ZZSWMGR_TEMP_DIR}/${dir_tmp}"

		# sudo apt build-dep -y -aarmhf ${SWNAME} # 可以指定架构
		sudo apt build-dep -y ${SWNAME}
		exit_if_fail $? "源码项目编译过程的依赖库/依赖程序安装失败"
	fi
	echo "SRC_DIR: ${SRC_DIR}"

}

function sw_compile() {
	cd ${SRC_DIR}
	pwd

	echo "正在配置源码，启用交叉编译功能"
	./configure --enable-cross
	exit_if_fail $? "源码配置失败"

	echo "正在编译"
	make clean
	make -j12
	sudo make install
	exit_if_fail $? "编译失败"

	echo ""
	echo "编译完成"
	echo "头文件路径：/usr/local/include"
	echo "库文件路径：/usr/local/lib"
	echo "编译器路径：/usr/local/bin"
	echo ""
	echo "win32平台相关路径"
	echo "/usr/local/lib/tcc/win32/include"
	echo "/usr/local/lib/tcc/win32/lib"

	echo ""
	echo -e "运行以下指令可查看刚刚编译的tcc支持哪些平台和CPU架构：\nls -al /usr/local/bin/|grep tcc"

	echo ""
	echo "示例："
	echo "i386-win32-tcc   test.c -o test32.exe"
	echo "x86_64-win32-tcc test.c -o test64.exe"

	: '
	i386-win32-tcc   main.c -o test32.exe
	x86_64-win32-tcc main.c -o test64.exe
	'

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
