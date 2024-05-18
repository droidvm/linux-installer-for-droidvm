#!/bin/bash

SWNAME=android-ndk
DEB_PATH=./downloads/${SWNAME}.zip
DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}
SWVER=r26b

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh

function sw_download() {
	tmpdns=`cd /exbin && droidexec ./vm_getHostByName.sh mirrors.cloud.tencent.com`
	exit_if_fail $? "DNS解析失败"
	echo "$tmpdns" >> /etc/hosts
	# echo "211.97.84.91   mirrors.cloud.tencent.com"           >> /etc/hosts

	case "${CURRENT_VM_ARCH}" in
		"arm64")
				# swUrl=https://mirrors.cloud.tencent.com/AndroidSDK/android-ndk-${SWVER}-linux.zip
				# swUrl=https://dl.google.com/android/repository/android-ndk-r26b-linux.zip

				swUrl=https://mirror.ghproxy.com/https://github.com/lzhiyong/termux-ndk/releases/download/android-ndk/android-ndk-${SWVER}-aarch64.zip
				;;
		"amd64")
				swUrl=https://mirrors.cloud.tencent.com/AndroidSDK/android-ndk-${SWVER}-linux.zip
				;;
		*) exit_unsupport ;;
	esac

	download_file2 "${DEB_PATH}" "${swUrl}"
	exit_if_fail $? "下载失败，网址：${swUrl}"
}

function sw_install() {
	apt-get install -y make
	exit_if_fail $? "依赖包安装失败"

	apt-get install -y unzip
	exit_if_fail $? "解压工具unzip安装失败"

	echo "正在解压. . ."
	unzip -oq ${DEB_PATH} -d /opt/apps/
	exit_if_fail $? "安装失败，软件包：${DEB_PATH}"

	for dirname in ndk-demo1 ndk-opengles-demo1 ndk-vulkan-demo1
	do
		chmod a+x ./scripts/res/$dirname/build.sh
		ls -al    ./scripts/res/$dirname/build.sh
	done
}

function sw_create_desktop_file() {
	case "${CURRENT_VM_ARCH}" in
		"arm64")
			# echo "运行ndk中的gcc："
			# echo "NDK_DIR=/opt/apps/android-ndk-${SWVER}"
			# echo "NDK_BIN=\${NDK_DIR}/toolchains/llvm/prebuilt/linux-aarch64/bin"
			# echo "export NDKCC=\${NDK_BIN}/clang"
			# echo "/opt/apps/android-ndk-${SWVER}/toolchains/llvm/prebuilt/linux-aarch64/bin/clang"
			# echo ""
			echo "更多信息请参考： ./scripts/res/droidcc-demo.sh"

			cat <<- EOF > /usr/bin/ndkenv
				#!/bin/bash

				NDK_DIR=/opt/apps/android-ndk-${SWVER}
				NDK_BIN=\${NDK_DIR}/toolchains/llvm/prebuilt/linux-aarch64/bin
				NDK_SYSROOT=\${NDK_DIR}/toolchains/llvm/prebuilt/linux-aarch64/sysroot

				if [ "\${abi}" == "" ]; then
					echo "请：export abi=arm64-v8a"
					echo "ndk-${SWVER} 目前只支持4种abi: arm64-v8a, armeabi-v7a, x86_64, x86"
					exit 1
				fi

				if [ "\${API_VER}" == "" ]; then
					echo "请：export API_VER=21"
					echo "ndk-${SWVER} 目前只支持以下 API_VER: "
					ls -a \${NDK_BIN}/aarch64-linux-android*|grep clang$|cut -c 24-25
					exit 1
				fi

				case "\${abi}" in
					"arm64-v8a")
						export CPLARCH=aarch64
						export OS_ARCH=arm64
						;;
					"armeabi-v7a")
						export CPLARCH=armv7a
						export OS_ARCH=arm32
						;;
					"x86_64")
						export CPLARCH=x86_64
						export OS_ARCH=amd64
						;;
					"x86")
						export CPLARCH=i686
						export OS_ARCH=amd32
						;;
					*)
						echo "不支持的abi: |\${abi}|"
						exit 2
						;;
				esac

				tmp_inc_name=\${CPLARCH}-linux-android
				if [ "armv7a" == "\${CPLARCH}" ]; then
					tmp_inc_name=arm-linux-androideabi
				fi

				NDK_EX_ARGS+=" -target \${CPLARCH}-none-linux-android\${API_VER}"
				NDK_EX_ARGS+=" --sysroot=\${NDK_SYSROOT}"
				NDK_EX_ARGS+=" -I\${NDK_SYSROOT}/usr/include"
				NDK_EX_ARGS+="  -I\${NDK_SYSROOT}/usr/include/\${tmp_inc_name}"
			EOF

			NDK_DIR=/opt/apps/android-ndk-${SWVER}
			NDK_BIN=${NDK_DIR}/toolchains/llvm/prebuilt/linux-aarch64/bin
			fn_clang=`readlink ${NDK_BIN}/clang`
			# echo -e "#!/bin/bash\nset -x\n. /usr/bin/ndkenv\nexec ${NDK_BIN}/${fn_clang}	\$NDK_EX_ARGS \$@" > /usr/bin/ndkcc_dbg
			echo -e "#!/bin/bash\n. /usr/bin/ndkenv\nexec ${NDK_BIN}/${fn_clang}	\$NDK_EX_ARGS \$@" > /usr/bin/ndkcc
			echo -e "#!/bin/bash\n. /usr/bin/ndkenv\nexec ${NDK_BIN}/${fn_clang}	\$NDK_EX_ARGS \$@" > /usr/bin/ndkpp
			echo -e "#!/bin/bash\n. /usr/bin/ndkenv\nexec ${NDK_BIN}/llvm-strip					  \$@" > /usr/bin/ndkstrip
			echo -e "#!/bin/bash\n. /usr/bin/ndkenv\nexec ${NDK_BIN}/llvm-ar					  \$@" > /usr/bin/ndkar
			echo -e "#!/bin/bash\n. /usr/bin/ndkenv\nexec ${NDK_BIN}/llvm-as		\$NDK_EX_ARGS \$@" > /usr/bin/ndkas
			echo -e "#!/bin/bash\n. /usr/bin/ndkenv\nexec ${NDK_BIN}/ld				\$NDK_EX_ARGS \$@" > /usr/bin/ndkld
			echo -e "#!/bin/bash\n. /usr/bin/ndkenv\nexec ${NDK_BIN}/llvm-ranlib	\$NDK_EX_ARGS \$@" > /usr/bin/ndkranlib
			echo -e "#!/bin/bash\n. /usr/bin/ndkenv\nexec ${NDK_BIN}/llvm-objcopy				  \$@" > /usr/bin/ndkobjcopy
			echo -e "#!/bin/bash\n. /usr/bin/ndkenv\nexec ${NDK_BIN}/llvm-objdump				  \$@" > /usr/bin/ndkobjdump

			chmod a+x /usr/bin/ndk*

			;;
		"amd64")
			echo ""
			;;
		*) exit_unsupport ;;
	esac
}

if [ "${action}" == "卸载" ]; then
	echo "暂不支持卸载"
	exit 1
else

	sw_download
	sw_install
	sw_create_desktop_file
fi
