#!/bin/bash

: '
wget http://192.168.1.5:90/compile-wldemo.sh -O ./scripts/compile-wldemo.sh
busybox wget http://192.168.1.5:90/wldemo2 -O wldemo2
busybox wget http://192.168.1.5:90/wldemo1 -O wldemo1

export XDG_RUNTIME_DIR=${HOME}
weston --xwayland &
export WAYLAND_DISPLAY=wayland-1

在安卓端：
cd /data/user/0/com.zzvm/files/vm/linux-arm64/home/droidvm
export XDG_RUNTIME_DIR=/data/user/0/com.zzvm/files/vm/linux-arm64/home/droidvm
export WAYLAND_DISPLAY=wayland-1
export WAYLAND_DISPLAY=wayland-0

这样运行
WAYLAND_DEBUG=1 ./wldemo2

'

# 
# 
# 
# busybox wget http://192.168.1.5:90/wldemo2 -O wldemo2




action=$1
if [ "$action" == "" ]; then action=安装; fi


SWNAME=wldemo
SWMGR_DIR=`pwd`
TMPDIR=${SWMGR_DIR}/tmp

abis="arm64-v8a"  #arm64-v8a armeabi-v7a x86_64 x86
NDK_DIR=/media/lenovo/sw/downloads/android-ndk-r23b
NDK_DIR=/opt/apps/android-ndk-r25c
NDK_DIR=/mnt/d/downloads/android-ndk-r23b


. ./scripts/common.sh

function sw_download() {

	# ndk installed?
	[ -d $NDK_DIR ]
	exit_if_fail $? "android-ndk 路径错误: ${NDK_DIR}\n(用于安卓的 ${SWNAME} , 必须使用android-ndk编译)"

	export SRC_DIR="${TMPDIR}/wldemo"
	mkdir -p ${SRC_DIR} 2>/dev/null
	rm -rf ${SRC_DIR}/*.c

	cp -f ${SWMGR_DIR}/scripts/res/wldemo_main1.c ${SRC_DIR}/main1.c
	cp -f ${SWMGR_DIR}/scripts/res/wldemo_main2.c ${SRC_DIR}/main2.c
	cp -f ${SWMGR_DIR}/scripts/res/wldemo_main2.bak.c ${SRC_DIR}/main2.bak.c

	echo -e "all:"																			> ${SRC_DIR}/makefile
	# echo -e "\t\$(CC) main1.c -g3 \$(CFLAGS) \$(LDFLAGS) -lffi -lwaylandclient -o wldemo1"	>>${SRC_DIR}/makefile
	echo -e "\t\$(CC) main2.c -g3 \$(CFLAGS) \$(LDFLAGS) -lffi -lwaylandclient -o wldemo2"	>>${SRC_DIR}/makefile

	# exit 1
	# cp -f /usr/lib/aarch64-linux-gnu/libwayland-client.so ${SRC_DIR}/linuxlib/
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

		# export  CFLAGS=" -D__ANDROID__ "
		# export LDFLAGS=" -L${SRC_DIR}/linuxlib -Wl,-rpath='\$\$ORIGIN/linuxlib' -latomic -llog -landroid -lc -lm " # -Wl,-Bstatic -ltalloc

		export  CFLAGS=" -I${TMPDIR}/libffi/release/${OS_ARCH}/include -I${TMPDIR}/libwaylandclient/release/${OS_ARCH}/include -D__DEBUG__ -DANDROID_BUILD -DANDROID"
		export LDFLAGS=" -L${TMPDIR}/libffi/release/${OS_ARCH}/lib -L${TMPDIR}/libwaylandclient/release/${OS_ARCH}/lib/alib -latomic -stdlib=libstdc++" # -Wl,-Bstatic -ltalloc

		cd "${SRC_DIR}"
		make V=1
		exit_if_fail $? "编译失败"

		echo "正在打包"
		cp  -f ${SRC_DIR}/wldemo1							${INSTALL_DIR}/
		cp  -f ${SRC_DIR}/wldemo2							${INSTALL_DIR}/
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
