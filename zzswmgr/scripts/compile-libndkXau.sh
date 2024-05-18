#!/bin/bash

#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#

action=$1
if [ "$action" == "" ]; then action=安装; fi


. ./scripts/common.sh

SWNAME=libndkXau
SWMDIR=${ZZSWMGR_MAIN_DIR}
TMPDIR=${ZZSWMGR_TEMP_DIR}
abis="arm64-v8a x86_64"  #arm64-v8a armeabi-v7a x86_64 x86
NDK_DIR=/opt/apps/android-ndk-r25c
NDK_DIR=/media/lenovo/sw/downloads/android-ndk-r23b
NDK_DIR=/mnt/d/downloads/android-ndk-r23b

function sw_download() {
	echo "已弃用"
	exit 1

	# ndk installed?
	[ -d $NDK_DIR ]
	exit_if_fail $? "android-ndk 路径错误: ${NDK_DIR}\n(用于安卓的 ${SWNAME} , 必须使用android-ndk编译)"

	export SRC_DIR="${TMPDIR}/libXau-1.0.9"
	export SRCPATH="${TMPDIR}/libndkXau.tar.gz"
	# [ -d ${SRC_DIR} ] || mkdir -p ${SRC_DIR}

	swUrl=https://www.x.org/releases/individual/lib/libXau-1.0.9.tar.gz
	download_file2 "${SRCPATH}" "${swUrl}"
	exit_if_fail $? "下载失败，网址：${swUrl}"

	if [ ! -d ${SRC_DIR} ]; then
	echo "正在解压. . ."
	# [ -d ${SRC_DIR} ] || mkdir -p ${SRC_DIR}
	tar -xzf ${SRCPATH} --overwrite -C ${TMPDIR}
	exit_if_fail $? "源码解压失败，软件包：${SRCPATH}"
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
	sudo apt-get install -y make git gawk
	exit_if_fail $? "make git gawk 安装失败"

	which gawk >/dev/null 2>&1
	exit_if_fail $? "请先运行 sudo apt-get install -y gawk"

	if [ "$PROOT_BRANCH" == "termux" ]; then
		echo "无需解压"
	else
		echo "无需解压"
		# echo "正在解压. . ."
		# echo ${TMPDIR}
		# tar -xzf ${DEB_PATH} --overwrite -C ${TMPDIR}
		# exit_if_fail $? "源码解压失败，软件包：${DEB_PATH}"
	fi

	# echo "正在修改源码. . ."
	# cp -f ./scripts/res/libtalloc_patch_os2_delete.c "${TMPDIR}/talloc-${TALLOC_VER}/lib/replace/tests/os2_delete.c"

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

		# export libtalloc_dir=${TALLOC_SRCDIR}/release/${OS_ARCH}

		# # tmp_inc_name=${CPLARCH}-linux-android
		# # if [ "armv7a" == "${CPLARCH}" ]; then
		# # 	tmp_inc_name=arm-linux-androideabi
		# # fi

		# # export  CFLAGS=" --sysroot ${NDK_SYSROOT} -I$libtalloc_dir/include -I${NDK_SYSROOT}/usr/include  -I${NDK_SYSROOT}/usr/include/${tmp_inc_name} -Werror=implicit-function-declaration "
		# export  CFLAGS=" -I$libtalloc_dir/include -D__ANDROID__ "
		# export LDFLAGS=" -L$libtalloc_dir/lib/alib -Wl,-rpath='\$\$ORIGIN' -ltalloc -latomic -llog -landroid -lc -lm " # -Wl,-Bstatic -ltalloc

		cd "${SRC_DIR}"

		# if [ "$PROOT_BRANCH" == "termux" ]; then
		# 	echo "正在修改makefile"

		# 	# mk_insert_mk

		# 	NEW_MK_FILE=makefile
		# 	head -n  7  GNUmakefile       							> ${NEW_MK_FILE}
		# 	cat ${SWMGR_DIR}/scripts/res/insert-${TALLOC_VER}.mk	>>${NEW_MK_FILE}
		# 	tail -n +7 GNUmakefile        							>>${NEW_MK_FILE}
		# 	head -n  50 ${NEW_MK_FILE}

		# 	echo "正在编译"
		# 	make -f ${NEW_MK_FILE} CPLARCH=${CPLARCH} distclean
		# 	make -f ${NEW_MK_FILE} CPLARCH=${CPLARCH} proot -j$(nproc)
		# 	exit_if_fail $? "编译失败"
		# else
			echo "正在configure"
			./configure --host=arm64-linux
			exit_if_fail $? "configure失败"

			echo "正在编译"
			make V=1 -f GNUmakefile distclean
			make V=1 -f GNUmakefile -j$(nproc) proot # CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}"
			exit_if_fail $? "编译失败"
		# fi

		ls -al ${SRC_DIR}/src/proot
		echo "正在strip"
		$STRIP --strip-unneeded --remove-section=.symtab ${SRC_DIR}/src/proot
		ls -al ${SRC_DIR}/src/proot


		echo "正在打包"
		mkdir -p $INSTALL_DIR/loader
		# cp -f ${libtalloc_dir}/lib/libtalloc.so		$INSTALL_DIR/libtalloc.so.2
		cp -f ${SRC_DIR}/src/proot               	$INSTALL_DIR/
		cp -f ${SRC_DIR}/src/loader/loader       	$INSTALL_DIR/loader/
		cp -f ${SRC_DIR}/src/loader/loader-m32   	$INSTALL_DIR/loader/loader32
		
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
