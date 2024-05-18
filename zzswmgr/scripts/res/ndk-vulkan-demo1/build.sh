#!/bin/bash

shellargs=$@

# echo "正在处理子模块"

# abis=`cat abis.txt`
abis=arm64-v8a

for abi in ${abis} #arm64-v8a armeabi-v7a x86_64 x86
do
	# echo "正在处理${abi}平台的子模块"
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


done
