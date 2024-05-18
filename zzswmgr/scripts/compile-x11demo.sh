#!/bin/bash

# wget http://192.168.1.5:90/compile-x11demo.sh -O ./scripts/compile-x11demo.sh



action=$1
if [ "$action" == "" ]; then action=安装; fi


SWNAME=x11demo
SWMGR_DIR=`pwd`
TMPDIR=${SWMGR_DIR}/tmp

abis="arm64-v8a"  #arm64-v8a armeabi-v7a x86_64 x86
NDK_DIR=/media/lenovo/sw/downloads/android-ndk-r23b
NDK_DIR=/mnt/d/downloads/android-ndk-r23b
NDK_DIR=/opt/apps/android-ndk-r25c


. ./scripts/common.sh

function sw_download() {

	# ndk installed?
	[ -d $NDK_DIR ]
	exit_if_fail $? "android-ndk 路径错误: ${NDK_DIR}\n(用于安卓的 ${SWNAME} , 必须使用android-ndk编译)"

	export SRC_DIR="${TMPDIR}/${SWNAME}"
	mkdir -p ${SRC_DIR} 2>/dev/null
	mkdir -p ${SRC_DIR}/linuxlib 2>/dev/null

	swUrl=https://github.com/hexops/x11-headers.git
	download_file3 "${SRC_DIR}/x11header" "${swUrl}"
	exit_if_fail $? "下载失败，网址：${swUrl}"

	cat <<- EOF > ${SRC_DIR}/main.c
	#include <stdio.h>
	#include </usr/include/X11/X.h>
	#include </usr/include/X11/Xlib.h>

	int main(void)
	{
		Display *dsp = XOpenDisplay(NULL);

		if(!dsp) {
			printf("连接失败\n");
			return 1;
		}else{
			printf("连接成功\n");
			return 0;
		}
	}
	EOF

	echo -e "all:" > ${SRC_DIR}/makefile
	echo -e "\t\$(CC) main.c \$(LDFLAGS)  -I${SRC_DIR}/x11header -lX11 -lxcb -o ${SWNAME}" >>${SRC_DIR}/makefile

	# find /usr -name *.a
	cp -f /usr/lib/aarch64-linux-gnu/libX11.a ${SRC_DIR}/linuxlib/
	cp -f /usr/lib/aarch64-linux-gnu/libxcb.a ${SRC_DIR}/linuxlib/
}

function prepare_vars() {
	CPLARCH=$1
	NDK_BIN=${NDK_DIR}/toolchains/llvm/prebuilt/linux-x86_64/bin
	API_VER=26

	detect_env
	if [ "${ZZ_ENV}" == "DROIDVM" ]; then
		BOX64=`get_box64_fullpath`
		echo "|${BOX64}|"

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

		NDK_SYSROOT=${NDK_DIR}/toolchains/llvm/prebuilt/linux-x86_64/sysroot
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

		NDK_SYSROOT=${NDK_DIR}/toolchains/llvm/prebuilt/linux-x86_64/sysroot
	fi

	echo $CC
	echo $AR
	# exit 1
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

		prepare_vars ${CPLARCH}

		export  CFLAGS=" -D__ANDROID__ "
		export LDFLAGS=" -L${SRC_DIR}/linuxlib -Wl,-rpath='\$\$ORIGIN/linuxlib' -latomic -llog -landroid -lc -lm " # -Wl,-Bstatic -ltalloc

		cd "${SRC_DIR}"
		make V=1
		exit_if_fail $? "编译失败"

		echo "正在打包"
		cp  -f ${SRC_DIR}/${SWNAME}								${INSTALL_DIR}/
		# cp -rf ${SRC_DIR}/linuxlib							${INSTALL_DIR}/
		# mv  -f $INSTALL_DIR/linuxlib/libwayland-client.so	${INSTALL_DIR}/linuxlib/libwayland-client.so.0
		# cp -f /usr/lib/aarch64-linux-gnu/libffi.so.8		${INSTALL_DIR}/linuxlib/
		# cp -f /usr/lib/aarch64-linux-gnu/libc.so.6			${INSTALL_DIR}/linuxlib/
		# cp -f /usr/lib/aarch64-linux-gnu/ld-linux-aarch64.so.1	${INSTALL_DIR}/linuxlib/
		# patchelf --set-rpath "\$ORIGIN" ${INSTALL_DIR}/linuxlib/*
		# chmod 755 ${INSTALL_DIR}/linuxlib/*
		# ls -al ${INSTALL_DIR}/linuxlib/
		
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
