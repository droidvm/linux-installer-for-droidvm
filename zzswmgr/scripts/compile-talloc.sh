#!/bin/bash

# 2.3.3 还没有适配android，源码还得改一下
# 2.4.0 版本的源码已经可以直接编译了
#
#
# sudo apt-get install -y make git
# 安装 android-ndk
# 若在虚拟电脑中编译，请先安装box
# 
# 
# android 使用的 libc 是 bionic， 并非 gnulibc, bionic 中是没有telldir/seekdir两个函数的
# https://github.com/haskell/unix/pull/92/commits/540a317a212ecef8592cc8089ecce1dacea08b2b
# 
# libtalloc使用特殊的非常少见的构建体系，我们在在3种环境中编译过libtalloc，耗时分别如下:
# 1). WSL
#	耗时约50分钟 (将CC换成 arm64-gcc可提速，耗时降为5分钟左右，注意连接工具不要换) (android api level >= 23, 不然会链接到proot时会报错说 undefined symbol: stderr,)
# 2). 虚拟电脑
#	耗时约50分钟 (将CC换成 arm64-gcc可提速，耗时降为5分钟左右，注意连接工具不要换) (android api level >= 23, 不然会链接到proot时会报错说 undefined symbol: stderr)
# 3). x86_64 linux 真机环境()
#	耗时仅约 3 分钟！！
#
# 不懂为什么 ndk-clang 在虚拟环境中(droidvm, wsl)为何会慢这么多。。。
# 
#
# 如何在linux x86_64中编译？
# 1). 把 zzswmgr 整个目录复制到 linux_x86_64 系统中
# 2). 然后运行: 
# cd xxx/zzswmgr
# chmod 755 ./scripts/*.sh
# ./scripts/compile-talloc.sh
#
# 注意：
# 所有路径中都不要含有中文字符和空格
# 设置脚本里面的 NDK_DIR 变量
# 
# gnu 中的 __errno_location 对应于安卓的 __errno
# 安卓中有这样的定义
# #define errno (*__errno())
# 

action=$1
if [ "$action" == "" ]; then action=安装; fi


SWNAME=talloc
SWVERS=2.4.0
DEB_PATH=./downloads/${SWNAME}.tar.gz
DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}
SWMGR_DIR=`pwd`
TMPDIR=${SWMGR_DIR}/tmp
abis="arm64-v8a x86_64"  #arm64-v8a armeabi-v7a x86_64 x86
NDK_DIR=/opt/apps/android-ndk-r25c
NDK_DIR=/media/lenovo/sw/downloads/android-ndk-r23b
NDK_DIR=/mnt/d/downloads/android-ndk-r23b


. ./scripts/common.sh


function sw_download() {

	# ndk installed?
	[ -d $NDK_DIR ]
	exit_if_fail $? "android-ndk 路径错误: ${NDK_DIR}\n(用于安卓的 ${SWNAME} , 必须使用android-ndk编译)"

	swUrl=https://download.samba.org/pub/talloc/talloc-${SWVERS}.tar.gz

	download_file2 "${DEB_PATH}" "${swUrl}"
	exit_if_fail $? "下载失败，网址：${swUrl}"
}

function prepare_vars() {
	CPLARCH=$1
	NDK_BIN=${NDK_DIR}/toolchains/llvm/prebuilt/linux-x86_64/bin
	API_VER=23

	detect_env
	if [ "${ZZ_ENV}" == "DROIDVM" ]; then
		BOX64=`get_box64_fullpath`
		echo "|${BOX64}|"

		sudo apt-get install -y gcc
		exit_if_fail $? "make arm64-gcc 安装失败"

		DIR_TMP_NDK_COMPILER=${TMPDIR}/ndk-compiler-${CPLARCH}-${API_VER}
		rm -rf ${DIR_TMP_NDK_COMPILER}
		mkdir -p ${DIR_TMP_NDK_COMPILER}/
		fn_clang=`readlink ${NDK_BIN}/clang`
		echo -e "#!/bin/bash\nexec ${BOX64} ${NDK_BIN}/${fn_clang}	-target ${CPLARCH}-none-linux-android${API_VER} \$@" > ${DIR_TMP_NDK_COMPILER}/CC
		echo -e "#!/bin/bash\nexec ${BOX64} ${NDK_BIN}/${fn_clang}	-target ${CPLARCH}-none-linux-android${API_VER} \$@" > ${DIR_TMP_NDK_COMPILER}/CXX
		echo -e "#!/bin/bash\nexec ${BOX64} ${NDK_BIN}/llvm-strip													\$@" > ${DIR_TMP_NDK_COMPILER}/STRIP
		echo -e "#!/bin/bash\nexec ${BOX64} ${NDK_BIN}/llvm-ar														\$@" > ${DIR_TMP_NDK_COMPILER}/AR
		echo -e "#!/bin/bash\nexec ${BOX64} ${NDK_BIN}/llvm-as		-target ${CPLARCH}-none-linux-android${API_VER} \$@" > ${DIR_TMP_NDK_COMPILER}/AS
		echo -e "#!/bin/bash\nexec ${BOX64} ${NDK_BIN}/ld			-target ${CPLARCH}-none-linux-android${API_VER} \$@" > ${DIR_TMP_NDK_COMPILER}/LD
		echo -e "#!/bin/bash\nexec ${BOX64} ${NDK_BIN}/llvm-ranlib	-target ${CPLARCH}-none-linux-android${API_VER} \$@" > ${DIR_TMP_NDK_COMPILER}/RANLIB
		echo -e "#!/bin/bash\nexec ${BOX64} ${NDK_BIN}/llvm-objcopy													\$@" > ${DIR_TMP_NDK_COMPILER}/OBJCOPY
		echo -e "#!/bin/bash\nexec ${BOX64} ${NDK_BIN}/llvm-objdump													\$@" > ${DIR_TMP_NDK_COMPILER}/OBJDUMP
		chmod 755 ${DIR_TMP_NDK_COMPILER}/*

		export CC=${DIR_TMP_NDK_COMPILER}/CC
		export CXX=${DIR_TMP_NDK_COMPILER}/CXX
		export STRIP=${DIR_TMP_NDK_COMPILER}/STRIP
		export AR=${DIR_TMP_NDK_COMPILER}/AR
		export AS=${DIR_TMP_NDK_COMPILER}/AS
		export LD=${DIR_TMP_NDK_COMPILER}/LD
		export RANLIB=${DIR_TMP_NDK_COMPILER}/RANLIB
		export OBJCOPY=${DIR_TMP_NDK_COMPILER}/OBJCOPY
		export OBJDUMP=${DIR_TMP_NDK_COMPILER}/OBJDUMP

		if [ "aarch64" == "${CPLARCH}" ] && [ ${API_VER} -ge 23 ]; then
			echo "正在使用arm64-gcc"
			NDK_SYSROOT=${NDK_DIR}/toolchains/llvm/prebuilt/linux-x86_64/sysroot

			tmp_inc_name=${CPLARCH}-linux-android
			if [ "armv7a" == "${CPLARCH}" ]; then
				tmp_inc_name=arm-linux-androideabi
			fi
			
			export CC=gcc
			export AR=ar
			# export CFLAGS=" -nostdinc -nostdlib -fno-builtin -I${NDK_SYSROOT}/usr/include  -I${NDK_SYSROOT}/usr/include/${tmp_inc_name} "
			# echo "CFLAGS: $CFLAGS"

			# export CC=clang -arch ${CPLARCH}           --sysroot=${NDK_SYSROOT} -I${NDK_SYSROOT}/usr/include  -I${NDK_SYSROOT}/usr/include/${tmp_inc_name}
			# export CC=clang -target aarch64-linux-none --sysroot=${NDK_SYSROOT} -I${NDK_SYSROOT}/usr/include  -I${NDK_SYSROOT}/usr/include/${tmp_inc_name}
		fi
	elif [ "${ZZ_ENV}" == "WSL" ]; then
		sudo apt-get install -y gcc-aarch64-linux-gnu
		exit_if_fail $? "make arm64-gcc 安装失败"

		export CC="${NDK_BIN}/${CPLARCH}-linux-android${API_VER}-clang"
		export CXX="${NDK_BIN}/${CPLARCH}-linux-android${API_VER}-clang++"
		export STRIP="${NDK_BIN}/llvm-strip"
		export AR="${NDK_BIN}/llvm-ar"
		export AS="${NDK_BIN}/llvm-as"
		export LD="${NDK_BIN}/ld"
		export RANLIB="${NDK_BIN}/llvm-ranlib"
		export OBJCOPY="${NDK_BIN}/llvm-objcopy"
		export OBJDUMP="${NDK_BIN}/llvm-objdump"

		if [ ${API_VER} -ge 23 ]; then
			if [ "aarch64" == "${CPLARCH}" ]; then
				echo "正在使用arm64-gcc"
				NDK_SYSROOT=${NDK_DIR}/toolchains/llvm/prebuilt/linux-x86_64/sysroot

				tmp_inc_name=${CPLARCH}-linux-android
				if [ "armv7a" == "${CPLARCH}" ]; then
					tmp_inc_name=arm-linux-androideabi
				fi
				
				export CC=aarch64-linux-gnu-gcc
				export AR=aarch64-linux-gnu-ar
				# export CFLAGS=" -nostdinc -nostdlib -fno-builtin" # -I${NDK_SYSROOT}/usr/include  -I${NDK_SYSROOT}/usr/include/${tmp_inc_name} "
				# echo "CFLAGS: $CFLAGS"

				# export CC=clang -arch ${CPLARCH}           --sysroot=${NDK_SYSROOT} -I${NDK_SYSROOT}/usr/include  -I${NDK_SYSROOT}/usr/include/${tmp_inc_name}
				# export CC=clang -target aarch64-linux-none --sysroot=${NDK_SYSROOT} -I${NDK_SYSROOT}/usr/include  -I${NDK_SYSROOT}/usr/include/${tmp_inc_name}
			elif [ "x86_64" == "${CPLARCH}" ]; then
				echo "正在使用x86_64-gcc"
				NDK_SYSROOT=${NDK_DIR}/toolchains/llvm/prebuilt/linux-x86_64/sysroot

				export CC=gcc
				export AR=ar
			fi
		fi
	else
		export CC="${NDK_BIN}/${CPLARCH}-linux-android${API_VER}-clang"
		export CXX="${NDK_BIN}/${CPLARCH}-linux-android${API_VER}-clang++"
		export STRIP="${NDK_BIN}/llvm-strip"
		export AR="${NDK_BIN}/llvm-ar"
		export AS="${NDK_BIN}/llvm-as"
		export LD="${NDK_BIN}/ld"
		export RANLIB="${NDK_BIN}/llvm-ranlib"
		export OBJCOPY="${NDK_BIN}/llvm-objcopy"
		export OBJDUMP="${NDK_BIN}/llvm-objdump"
	fi

	echo $CC
	echo $AR
	# exit 1
}

function generate_answer_file() {
cat <<EOF > ${TMPDIR}/cross-answers.txt
Checking uname sysname type: "Linux"
Checking uname machine type: "dontcare"
Checking uname release type: "dontcare"
Checking uname version type: "dontcare"
Checking simple C program: OK
building library support: OK
Checking for large file support: OK
Checking for -D_FILE_OFFSET_BITS=64: OK
Checking for WORDS_BIGENDIAN: OK
Checking for C99 vsnprintf: OK
Checking for HAVE_SECURE_MKSTEMP: OK
rpath library support: OK
-Wl,--version-script support: FAIL
Checking correct behavior of strtoll: OK
Checking correct behavior of strptime: OK
Checking for HAVE_IFACE_GETIFADDRS: OK
Checking for HAVE_IFACE_IFCONF: OK
Checking for HAVE_IFACE_IFREQ: OK
Checking getconf LFS_CFLAGS: OK
Checking for large file support without additional flags: OK
Checking for working strptime: OK
Checking for HAVE_SHARED_MMAP: OK
Checking for HAVE_MREMAP: OK
Checking for HAVE_INCOHERENT_MMAP: OK
Checking getconf large file support flags work: OK
EOF
}

function sw_compile() {

	sudo apt-get install -y make git
	exit_if_fail $? "make git 安装失败"

	echo "正在解压. . ."
	tar -xzf ${DEB_PATH} --overwrite -C ${TMPDIR}
	exit_if_fail $? "源码解压失败，软件包：${DEB_PATH}"

	if [ "${SWVERS}" == "2.3.3" ]; then
		echo "正在修改源码. . ."
		cp -f ./scripts/res/libtalloc-${SWVERS}_patch_os2_delete.c "${TMPDIR}/talloc-${SWVERS}/lib/replace/tests/os2_delete.c"
		exit_if_fail $? "源码修改失败"
	fi

	export BOX64_NOBANNER=1
	export BOX64_LOG=0
	export BOX64_DYNAREC_LOG=0

	export SRC_DIR="${TMPDIR}/talloc-${SWVERS}"
	export BUILD_DIR="${SRC_DIR}/build"
	export FILE_OFFSET_BITS='OK'
	export PATH="${SWMGR_DIR}/scripts/res/target-mock-bin:$PATH"
	mkdir -p "$BUILD_DIR"
	chmod 755 ${SWMGR_DIR}/scripts/res/target-mock-bin/pkg-config


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

		prepare_vars ${CPLARCH}
		cd "${TMPDIR}/talloc-${SWVERS}"

		generate_answer_file

		echo "正在配置和编译"
		./configure build "--prefix=$INSTALL_DIR" --disable-rpath --disable-python --cross-compile --cross-answers=${TMPDIR}/cross-answers.txt
		exit_if_fail $? "源码配置失败"

		mkdir -p "$INSTALL_DIR/include"
		mkdir -p "$INSTALL_DIR/lib"
		mkdir -p "$INSTALL_DIR/lib/alib"

		echo "正在打包成开发库和动态库"
		cp -f talloc.h               "$INSTALL_DIR/include"
		cp -f bin/default/libtalloc* "$INSTALL_DIR/lib"
		"$AR" rcs                    "$INSTALL_DIR/lib/alib/libtalloc_tmp.a" bin/default/talloc*.o
		"$OBJCOPY" --redefine-sym __errno_location=__errno  "$INSTALL_DIR/lib/alib/libtalloc_tmp.a"  "$INSTALL_DIR/lib/alib/libtalloc.a"
		rm -rf "$INSTALL_DIR/lib/alib/libtalloc_tmp.a"
		exit_if_fail $? "打包失败"

		echo "库已生成，请查看：$INSTALL_DIR"

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
