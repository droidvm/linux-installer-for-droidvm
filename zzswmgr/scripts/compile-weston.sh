#!/bin/bash

: '

测试结果：实测单独使用wayland感觉速度不错，但套接一个xserver(启动xwayland)，就出奇的慢

SWMGR_DIR=/exbin/tools/zzswmgr
SRC_DIR=/exbin/tools/zzswmgr/tmp/weston-10.0.1

cd /exbin/tools/zzswmgr/tmp/weston-10.0.1/obj-aarch64-linux-gnu
gcc -Ilibweston/backend-headless/headless-backend.so.p -Ilibweston/backend-headless -I../libweston/backend-headless -I. -I.. -Iinclude -I../include -Ilibweston -I../libweston -Iprotocol -I/usr/include/pixman-1 -I/usr/include/libdrm -fdiagnostics-color=always -D_FILE_OFFSET_BITS=64 -Wall -Winvalid-pch -Wextra -Wpedantic -std=gnu99 -O0 -Wmissing-prototypes -Wno-unused-parameter -Wno-shift-negative-value -Wno-missing-field-initializers -Wno-pedantic -Wundef -fvisibility=hidden -g -O2 -ffile-prefix-map=/exbin/tools/zzswmgr/tmp/weston-10.0.1=. -fstack-protector-strong -Wformat -Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2 -fPIC -MD -MQ libweston/backend-headless/headless-backend.so.p/headless.c.o -MF libweston/backend-headless/headless-backend.so.p/headless.c.o.d -o libweston/backend-headless/headless-backend.so.p/headless.c.o -c ../libweston/backend-headless/headless.c

sudo dpkg -i tmp/libweston-10-0_10.0.1-1_arm64.deb

wget http://192.168.1.5:90/compile-weston.sh -O ./scripts/compile-weston.sh

SWMGR_DIR=/exbin/tools/zzswmgr
SRC_DIR=/exbin/tools/zzswmgr/tmp/weston-10.0.1
wget http://192.168.1.5:90/weston-10.0.1_headless.c -O ./scripts/res/weston-10.0.1_headless.c
cp -f ${SWMGR_DIR}/scripts/res/weston-10.0.1_headless.c ${SRC_DIR}/libweston/backend-headless/headless.c


busybox wget http://192.168.1.5:90/wldemo2 -O wldemo2
busybox wget http://192.168.1.5:90/wldemo1 -O wldemo1

# 可以使用 xwud -in /exbin/ipc/weston_screen 来查看xwd图片
export XDG_RUNTIME_DIR=${HOME}
export WST_SCREEN_SAVETO=/exbin/ipc/weston_screen
unset WAYLAND_DISPLAY
weston -B headless-backend.so --xwayland --use-gl &
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


SWNAME=weston
swVer=10.0.1
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

		sudo apt build-dep -y ${SWNAME}
		exit_if_fail $? "源码项目编译过程的依赖库/依赖程序安装失败"

		echo "正在修改源码"
		cp -f ${SRC_DIR}/libweston/backend-headless/headless.c  ${SRC_DIR}/libweston/backend-headless/headless.c.bak
		cp -f ${SWMGR_DIR}/scripts/res/weston-10.0.1_headless.c ${SRC_DIR}/libweston/backend-headless/headless.c

		# 有些项目的源码，修改后需要 commit 才能编译, 比如 libfm, 实测 weston 不需要，反而还省点事了
		# dpkg-source --commit
	else
		echo "正在修改源码"
		cp -f ${SWMGR_DIR}/scripts/res/weston-10.0.1_headless.c ${SRC_DIR}/libweston/backend-headless/headless.c
	fi
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

		# prepare_vars ${CPLARCH}

		cd ${SRC_DIR}
		pwd

		echo "正在编译"
		# dpkg-buildpackage -nc -us -uc -j12 -aarmhf # 可以指定架构
		dpkg-buildpackage -us -uc -j12

		# # export  CFLAGS=" -D__ANDROID__ "
		# # export LDFLAGS=" -L${SRC_DIR}/linuxlib -Wl,-rpath='\$\$ORIGIN/linuxlib' -latomic -llog -landroid -lc -lm " # -Wl,-Bstatic -ltalloc

		# export  CFLAGS=" -I${TMPDIR}/libffi/release/${OS_ARCH}/include -I${TMPDIR}/libwaylandclient/release/${OS_ARCH}/include -D__DEBUG__ -DANDROID_BUILD -DANDROID"
		# export LDFLAGS=" -L${TMPDIR}/libffi/release/${OS_ARCH}/lib -L${TMPDIR}/libwaylandclient/release/${OS_ARCH}/lib/alib -latomic -stdlib=libstdc++" # -Wl,-Bstatic -ltalloc

		# cd "${SRC_DIR}"
		# make V=1
		# exit_if_fail $? "编译失败"

		echo "正在安装"
		sudo dpkg -i ${SWMGR_DIR}/tmp/libweston-10-0_10.0.1-1_arm64.deb

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
