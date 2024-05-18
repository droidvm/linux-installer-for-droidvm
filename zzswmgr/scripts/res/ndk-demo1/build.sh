#!/bin/bash

# export BOX64_NOBANNER=1
# export BOX64_LOG=0
# export BOX64_DYNAREC_LOG=0
# make

shellargs=$@

echo "arm64-v8a x86_64 x86">abis.txt
abis=`cat abis.txt`

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

done

