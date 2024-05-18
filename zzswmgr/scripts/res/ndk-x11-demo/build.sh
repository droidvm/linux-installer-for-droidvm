#!/bin/bash

# export BOX64_NOBANNER=1
# export BOX64_LOG=0
# export BOX64_DYNAREC_LOG=0
# make

shellargs=$@

# echo "arm64-v8a x86_64 x86">abis.txt
# abis=`cat abis.txt`
abis=arm64-v8a

export ndk_exlibs_hostpath=${APP_INTERNAL_DIR}/vm/android_console/ndk_exlibs
export ndk_exlibs_virtpath=/exbin/vm/android_console/ndk_exlibs

command -v patchelf >/dev/null 2>&1 || sudo apt install -y patchelf

sofiles=`ls -al ${ndk_exlibs_virtpath}/usr/lib/*.so`
if [ "${sofiles}" == "" ]; then

	if [ -f "${APP_FILENAME_URLDLSERVER}" ]; then
	. ${APP_FILENAME_URLDLSERVER}
	fi

	wget ${APP_URL_DLSERVER}/ndk_exlibs.zip -O ndk_exlibs.zip
	mkdir -p ${ndk_exlibs_virtpath} 2>/dev/null
	unzip -oq ./ndk_exlibs.zip -d ${ndk_exlibs_virtpath}
	patchelf --set-rpath "${ndk_exlibs_hostpath}/usr/lib:/system/lib64"             ${ndk_exlibs_virtpath}/usr/lib/*.so
fi


for abi in ${abis} #arm64-v8a armeabi-v7a x86_64 x86
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

	# BOX64_LOG=0 BOX64_DYNAREC_LOG=0 BOX64_NOBANNER=1 make TEMPABI=${abi} CPLARCH=${CPLARCH} ${shellargs} EXE=1
	make TEMPABI=${abi} CPLARCH=${CPLARCH} ${shellargs} EXE=1
	mkrlt=$?
	if [ $mkrlt -ne 0 ]; then
		exit $mkrlt
	fi

	patchelf --set-rpath "${ndk_exlibs_hostpath}/usr/lib:/system/lib64"             ./build/abi_arm64-v8a/main

	# 运行
	droidexec ./build/abi_arm64-v8a/main

done

