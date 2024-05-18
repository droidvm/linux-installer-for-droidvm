#!/bin/bash

SWNAME=box
DEB_PATH=./downloads/${SWNAME}.deb
DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}
SWMGR_DIR=`pwd`
TMPDIR=${SWMGR_DIR}/tmp

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh

function makedeb() {
      # 参考：https://blog.csdn.net/badbayyj/article/details/129353140

      DEB_DIR=${TMPDIR}/deb_build
      rm -rf   ${DEB_DIR}
      mkdir -p ${DEB_DIR}
      mkdir -p ${DEB_DIR}/DEBIAN

      echo "Package: box"                       > ${DEB_DIR}/DEBIAN/control
      echo "Version: 1.0.0"                     >>${DEB_DIR}/DEBIAN/control
      echo "Architecture: arm64"                >>${DEB_DIR}/DEBIAN/control
      echo "Maintainer: 韦华锋"                 >>${DEB_DIR}/DEBIAN/control
      echo "Description: box86,box64"           >>${DEB_DIR}/DEBIAN/control
      # echo "Depends: libc6:armhf"             >>${DEB_DIR}/DEBIAN/control

      echo '#!/bin/sh'                                      > ${DEB_DIR}/DEBIAN/postinst
      echo 'echo ""'                                        >>${DEB_DIR}/DEBIAN/postinst
      echo 'echo "请注意："'                                >>${DEB_DIR}/DEBIAN/postinst
      echo 'echo "你需要自己运行以下指令, box86才能运行："' >>${DEB_DIR}/DEBIAN/postinst
      echo 'echo "================================"'        >>${DEB_DIR}/DEBIAN/postinst
      echo 'echo "sudo dpkg --add-architecture armhf"'      >>${DEB_DIR}/DEBIAN/postinst
      echo 'echo "sudo apt-get update"'                     >>${DEB_DIR}/DEBIAN/postinst
      echo 'echo "sudo apt install libc6:armhf -y"'         >>${DEB_DIR}/DEBIAN/postinst
      echo 'echo "================================"'        >>${DEB_DIR}/DEBIAN/postinst

      chmod 755 ${DEB_DIR}/DEBIAN/control
      chmod 755 ${DEB_DIR}/DEBIAN/postinst

      mkdir -p ${DEB_DIR}/usr/local/bin
      mkdir -p ${DEB_DIR}/etc/binfmt.d
      mkdir -p ${DEB_DIR}/usr/lib/i386-linux-gnu
      mkdir -p ${DEB_DIR}/usr/lib/x86_64-linux-gnu
      mkdir -p ${DEB_DIR}/etc

      cp -f /usr/local/bin/box64                      ${DEB_DIR}/usr/local/bin/box64
      cp -f /etc/binfmt.d/box64.conf                  ${DEB_DIR}/etc/binfmt.d/box64.conf
      cp -f /usr/lib/x86_64-linux-gnu/libstdc++.so.5  ${DEB_DIR}/usr/lib/x86_64-linux-gnu/libstdc++.so.5
      cp -f /usr/lib/x86_64-linux-gnu/libstdc++.so.6  ${DEB_DIR}/usr/lib/x86_64-linux-gnu/libstdc++.so.6
      cp -f /usr/lib/x86_64-linux-gnu/libgcc_s.so.1   ${DEB_DIR}/usr/lib/x86_64-linux-gnu/libgcc_s.so.1
      cp -f /usr/lib/x86_64-linux-gnu/libpng12.so.0   ${DEB_DIR}/usr/lib/x86_64-linux-gnu/libpng12.so.0
      cp -f /etc/box64.box64rc                        ${DEB_DIR}/etc/box64.box64rc

      cp -f /usr/local/bin/box86                      ${DEB_DIR}/usr/local/bin/box86
      cp -f /etc/binfmt.d/box86.conf                  ${DEB_DIR}/etc/binfmt.d/box86.conf
      cp -f /usr/lib/i386-linux-gnu/libstdc++.so.6    ${DEB_DIR}/usr/lib/i386-linux-gnu/libstdc++.so.6
      cp -f /usr/lib/i386-linux-gnu/libstdc++.so.5    ${DEB_DIR}/usr/lib/i386-linux-gnu/libstdc++.so.5
      cp -f /usr/lib/i386-linux-gnu/libgcc_s.so.1     ${DEB_DIR}/usr/lib/i386-linux-gnu/libgcc_s.so.1
      cp -f /usr/lib/i386-linux-gnu/libpng12.so.0     ${DEB_DIR}/usr/lib/i386-linux-gnu/libpng12.so.0
      cp -f /etc/box86.box86rc                        ${DEB_DIR}/etc/box86.box86rc

      dpkg -b ${DEB_DIR}

      if [ -f deb_build.deb ]; then
            # 解包
            # dpkg-deb -x deb_build.deb undeb
            echo "DEB包生成成功 => ${TMPDIR}/box.deb"
			gxmessage -title "编译成功" "DEB包生成成功 => ${TMPDIR}/box.deb"  -center
            cp -f deb_build.deb box.deb
            mv -f deb_build.deb /sdcard/box.deb
            return 0
      fi

      return 1
}

function sw_download() {
	apt-get -y install git
	exit_if_fail $? "git安装失败"

	case "${CURRENT_VM_ARCH}" in
		"arm64")
			cd ${TMPDIR}

			echo "正在下载box86源码"
			# git clone https://gitee.com/smlawb/box86.git
			[ -d ./box86 ] || git clone https://gitee.com/mirrors_ptitSeb/box86.git
			exit_if_fail $? "box86 源码下载失败"

			echo "正在下载box64源码"
			[ -d ./box64 ] || git clone https://gitee.com/hedan666/box64.git
			exit_if_fail $? "box64 源码下载失败"

			;;
		*) exit_unsupport ;;
	esac
}

function sw_compile() {
	apt-get -y install git gcc cmake make python3
	exit_if_fail $? "arm64系列的编译工具安装失败"
	
	apt-get -y install git gcc-arm-linux-gnueabihf #g++-arm-linux-gnueabihf
	exit_if_fail $? "arm32系列的编译工具安装失败"


	echo "正在编译box86"
	cd ${TMPDIR}/box86
	mkdir build; cd build; 
	cmake ../ \
		-DBAD_SIGNAL=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo -DARM64=1 \
		-DCMAKE_C_COMPILER=/usr/bin/arm-linux-gnueabihf-gcc
		# -DCMAKE_CXX_COMPILER=/usr/bin/arm-linux-gnueabihf-g++
		exit_if_fail $? "box86 cmake编译失败"
	make -j$(nproc) install
		exit_if_fail $? "box86 make编译失败"

	echo "正在编译box64"
	cd ${TMPDIR}/box64
	mkdir build; cd build; 
	cmake ../ \
		-DBAD_SIGNAL=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo -DARM_DYNAREC=ON \
		-DCMAKE_C_COMPILER=gcc
		# -DCMAKE_CXX_COMPILER=g++ 
		exit_if_fail $? "box64 cmake编译失败"
	make -j$(nproc) install
		exit_if_fail $? "box64 make编译失败"
	
	# box86 -v
	# box64 -v

	dpkg --add-architecture armhf
	exit_if_fail $? "依赖包安装失败"

	apt-get update
	exit_if_fail $? "依赖包安装失败"

	apt-get install -y libc6:armhf
	exit_if_fail $? "依赖包安装失败"


	# install_deb ${DEB_PATH}
	# exit_if_fail $? "安装失败，软件包：${DEB_PATH}"

	echo "正在生成为deb包"
	cd ${TMPDIR}
	makedeb
	exit_if_fail $? "deb包生成失败"

	# gxmessage -title "提示" "安装已完成，但需要重启一次才能运行"  -center
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
