#!/bin/bash

: '

cp -rf /mnt/e/Dev/EE/Rockchip/freemain/src/gui/os/android/droidvm/linux-installer-for-droidvm/zzswmgr ~/dev/

备份修改的源文件：
cp -rf /home/lenovo/dev/zzswmgr/tmp/tigervnc-1.12.0+dfsg/unix/xserver/hw/vnc/xvnc.c /mnt/e/Dev/EE/Rockchip/freemain/src/gui/os/android/droidvm/linux-installer-for-droidvm/zzswmgr/scripts/res/tigervnc_patch_xvnc.c

cd /exbin/tools/zzswmgr
wget http://192.168.1.5:90/compile-tigervnc.sh -O ./scripts/compile-tigervnc.sh


里面的路径多了 xserver/, 如果不改这个文件，也可以在编译过程中等出现要patch哪个文件时，输入文件名：configure.ac
/exbin/tools/zzswmgr/tmp/tigervnc-1.12.0+dfsg/debian/xserver121.patch


tigervnc-common_1.12.0+dfsg-5_arm64.deb
tigervnc-standalone-server_1.12.0+dfsg-5_arm64.deb


cd /home/lenovo/dev/zzswmgr/tmp/tigervnc-1.12.0+dfsg/obj-x86_64-linux-gnu
make


启动指令：
vncserver :6 -localhost no -geometry 1280x800 -depth 32  -xstartup jwm
:6 即代表xserver的display_id, 也代表vnc server的端口号为 5906, 如果是:1那对应的端口号就是5901, :2=>5902
https://blog.csdn.net/u012625323/article/details/122419954
vncserver -kill :6

修改vnc访问密码：
vncpasswd


下面这两个方式中会启动xserver，不启动vnc server， vnc客户端连不上的
Xtigervnc :1
Xtigervnc :6
Xtigervnc :6 -Log *:stderr:100

如何动态调整分辨率 => 只能选择它内置的分辨率，不能随意设置~~~：
https://blog.csdn.net/dream_allday/article/details/77896194
xrandr                  显示可用分辨率列表
xrandr -s 1600x1200     动态调整分辨率，调整后vnc会断开，但是xserver不会断
xrandr -s 1600x1208     报错：Size 1600x1208 not found in available modes



cd ~/dev/zzswmgr/tmp/tigervnc-1.12.0+dfsg
		# -nc, --no-pre-clean
		# -us, --unsigned-source
		# -uc, --unsigned-changes
		# --no-sign               do not sign any file.
		dpkg-buildpackage -us -uc -j12
		dpkg-buildpackage -nc -us -uc -j12| tee ./mk.log
		Reversed (or previously applied) patch detected! Assume -R? [n] 是否想还原为打补丁之前的文件？好像又不对，给它输入 y 回车
		实际我是-nc参数交替着加或不加

export WST_SCREEN_SAVETO=/exbin/ipc/weston_screen
./debian/tmp/usr/bin/Xtigervnc :5 -geometry 1080x600 -depth 24
./obj-x86_64-linux-gnu/unix/vncserver :6 -localhost no -geometry 1280x800 -depth 32  -xstartup jwm
xwud -in /exbin/ipc/weston_screen


最快速的编译单个c文件
cd ~/dev/zzswmgr/tmp/tigervnc-1.12.0+dfsg
cd ~/dev/zzswmgr/tmp/tigervnc-1.12.0+dfsg/obj-x86_64-linux-gnu/unix/xserver/hw/vnc
rm -rf ./Xvnc
rm -rf ./Xvnc-xvnc.o
gcc -DHAVE_CONFIG_H -I. -I../../../../../unix/xserver/hw/vnc -I../../include  -DHAVE_DIX_CONFIG_H -Wall -Wpointer-arith -Wmissing-declarations -Wformat=2 -Wstrict-prototypes -Wmissing-prototypes -Wnested-externs -Wbad-function-cast -Wold-style-definition -Wdeclaration-after-statement -Wunused -Wuninitialized -Wshadow -Wmissing-noreturn -Wmissing-format-attribute -Wredundant-decls -Wlogical-op -Wimplicit -Wnonnull -Winit-self -Wmain -Wmissing-braces -Wsequence-point -Wreturn-type -Wtrigraphs -Warray-bounds -Wwrite-strings -Waddress -Wint-to-pointer-cast -Wpointer-to-int-cast -fno-strict-aliasing -fno-strict-aliasing -D_DEFAULT_SOURCE -D_BSD_SOURCE -DHAS_FCHOWN -DHAS_STICKY_DIR_BIT -I/usr/local/include -I/usr/include/pixman-1 -I/usr/include/freetype2 -I/usr/include/libpng16 -I../../../../../unix/xserver/include -I../../include -I../../../../../unix/xserver/Xext -I../../../../../unix/xserver/composite -I../../../../../unix/xserver/damageext -I../../../../../unix/xserver/xfixes -I../../../../../unix/xserver/Xi -I../../../../../unix/xserver/mi -I../../../../../unix/xserver/miext/sync -I../../../../../unix/xserver/miext/shadow  -I../../../../../unix/xserver/miext/damage -I../../../../../unix/xserver/render -I../../../../../unix/xserver/randr -I../../../../../unix/xserver/fb -I../../../../../unix/xserver/dbe -I../../../../../unix/xserver/present -DTIGERVNC -DNO_MODULE_EXTS -UHAVE_CONFIG_H -DXFree86Server -DVENDOR_RELEASE="\"21.1.4\"" -DVENDOR_STRING="\"X.Org\"" -I../../../../../unix/xserver/../../common -I../../../../../unix/xserver/../../unix/common -I../../../../../unix/xserver/include -I/usr/local/include -I/usr/include/pixman-1 -I/usr/include/freetype2 -I/usr/include/libpng16 -Wdate-time -D_FORTIFY_SOURCE=2 -DBUILD_TIMESTAMP="\"2022-03-25 17:06\""  -g -O2 -ffile-prefix-map=/home/lenovo/dev/zzswmgr/tmp/tigervnc-1.12.0+dfsg=. -flto=auto -ffat-lto-objects -flto=auto -ffat-lto-objects -fstack-protector-strong -Wformat -Werror=format-security  -c -o Xvnc-xvnc.o `test -f 'xvnc.c' || echo '../../../../../unix/xserver/hw/vnc/'`xvnc.c
/bin/bash ../../libtool  --tag=CXX   --mode=link g++  -g -O2 -ffile-prefix-map=/home/lenovo/dev/zzswmgr/tmp/tigervnc-1.12.0+dfsg=. -flto=auto -ffat-lto-objects -flto=auto -ffat-lto-objects -fstack-protector-strong -Wformat -Werror=format-security -export-dynamic -Wl,-Bsymbolic-functions -flto=auto -ffat-lto-objects -flto=auto -Wl,-z,relro -Wl,-z,now -Wl,--as-needed -o Xvnc Xvnc-xvnc.o Xvnc-stubs.o Xvnc-miinitext.o Xvnc-fbcmap_mi.o Xvnc-buildtime.o ../../fb/libfb.la ../../xfixes/libxfixes.la ../../Xext/libXext.la  ../../dbe/libdbe.la ../../record/librecord.la ../../glx/libglx.la ../../glx/libglxvnd.la ../../randr/librandr.la ../../render/librender.la ../../damageext/libdamageext.la  ../../present/libpresent.la ../../miext/sync/libsync.la ../../miext/damage/libdamage.la ../../miext/shadow/libshadow.la ../../Xi/libXi.la ../../xkb/libxkb.la ../../xkb/libxkbstubs.la ../../composite/libcomposite.la ../../dix/libmain.la libvnccommon.la ../../../../common/network/libnetwork.la ../../../../common/rfb/librfb.la ../../../../common/rdr/librdr.la ../../../../common/os/libos.la ../../../../unix/common/libunixcommon.la ../../dix/libdix.la ../../mi/libmi.la ../../os/libos.la -L/usr/local/lib -lpixman-1 -lXfont2 -lXau -lsystemd -lxshmfence -lXdmcp   -laudit -lm -lbsd   -lGL -lX11 -laudit -lm -lbsd
./Xvnc :5 -geometry 1080x600 -depth 24 &

备份修改的源文件：
cp -rf /home/lenovo/dev/zzswmgr/tmp/tigervnc-1.12.0+dfsg/unix/xserver/hw/vnc/xvnc.c /mnt/e/Dev/EE/Rockchip/freemain/src/gui/os/android/droidvm/linux-installer-for-droidvm/zzswmgr/scripts/res/tigervnc_patch_xvnc.c

droidvm端
cd /exbin/tools/zzswmgr/tmp/tigervnc-1.12.0+dfsg/unix/xserver/hw/vnc
wget http://192.168.1.5:90/tigervnc_patch_xvnc.c -O xvnc.c
cd /exbin/tools/zzswmgr/tmp/tigervnc-1.12.0+dfsg/obj-aarch64-linux-gnu/unix/xserver/hw/vnc
rm -rf ./Xvnc
rm -rf ./Xvnc-xvnc.o
gcc -DHAVE_CONFIG_H -I. -I../../../../../unix/xserver/hw/vnc -I../../include  -DHAVE_DIX_CONFIG_H -Wall -Wpointer-arith -Wmissing-declarations -Wformat=2 -Wstrict-prototypes -Wmissing-prototypes -Wnested-externs -Wbad-function-cast -Wold-style-definition -Wdeclaration-after-statement -Wunused -Wuninitialized -Wshadow -Wmissing-noreturn -Wmissing-format-attribute -Wredundant-decls -Wlogical-op -Wimplicit -Wnonnull -Winit-self -Wmain -Wmissing-braces -Wsequence-point -Wreturn-type -Wtrigraphs -Warray-bounds -Wwrite-strings -Waddress -Wint-to-pointer-cast -Wpointer-to-int-cast -fno-strict-aliasing -fno-strict-aliasing -D_DEFAULT_SOURCE -D_BSD_SOURCE -DHAS_FCHOWN -DHAS_STICKY_DIR_BIT -I/usr/local/include -I/usr/include/pixman-1 -I/usr/include/freetype2 -I/usr/include/libpng16 -I../../../../../unix/xserver/include -I../../include -I../../../../../unix/xserver/Xext -I../../../../../unix/xserver/composite -I../../../../../unix/xserver/damageext -I../../../../../unix/xserver/xfixes -I../../../../../unix/xserver/Xi -I../../../../../unix/xserver/mi -I../../../../../unix/xserver/miext/sync -I../../../../../unix/xserver/miext/shadow  -I../../../../../unix/xserver/miext/damage -I../../../../../unix/xserver/render -I../../../../../unix/xserver/randr -I../../../../../unix/xserver/fb -I../../../../../unix/xserver/dbe -I../../../../../unix/xserver/present -DTIGERVNC -DNO_MODULE_EXTS -UHAVE_CONFIG_H -DXFree86Server -DVENDOR_RELEASE="\"21.1.4\"" -DVENDOR_STRING="\"X.Org\"" -I../../../../../unix/xserver/../../common -I../../../../../unix/xserver/../../unix/common -I../../../../../unix/xserver/include -I/usr/local/include -I/usr/include/pixman-1 -I/usr/include/freetype2 -I/usr/include/libpng16 -Wdate-time -D_FORTIFY_SOURCE=2 -DBUILD_TIMESTAMP="\"2022-03-25 17:06\""  -g -O2 -ffile-prefix-map=/home/lenovo/dev/zzswmgr/tmp/tigervnc-1.12.0+dfsg=. -flto=auto -ffat-lto-objects -flto=auto -ffat-lto-objects -fstack-protector-strong -Wformat -Werror=format-security  -c -o Xvnc-xvnc.o `test -f 'xvnc.c' || echo '../../../../../unix/xserver/hw/vnc/'`xvnc.c
/bin/bash ../../libtool  --tag=CXX   --mode=link g++  -g -O2 -ffile-prefix-map=/exbin/tools/zzswmgr/tmp/tigervnc-1.12.0+dfsg=. -flto=auto -ffat-lto-objects -flto=auto -ffat-lto-objects -fstack-protector-strong -Wformat -Werror=format-security -export-dynamic -Wl,-Bsymbolic-functions -flto=auto -ffat-lto-objects -flto=auto -Wl,-z,relro -Wl,-z,now -Wl,--as-needed -o Xvnc Xvnc-xvnc.o Xvnc-stubs.o Xvnc-miinitext.o Xvnc-fbcmap_mi.o Xvnc-buildtime.o ../../fb/libfb.la ../../xfixes/libxfixes.la ../../Xext/libXext.la  ../../dbe/libdbe.la ../../record/librecord.la ../../glx/libglx.la ../../glx/libglxvnd.la ../../randr/librandr.la ../../render/librender.la ../../damageext/libdamageext.la  ../../present/libpresent.la ../../miext/sync/libsync.la ../../miext/damage/libdamage.la ../../miext/shadow/libshadow.la ../../Xi/libXi.la ../../xkb/libxkb.la ../../xkb/libxkbstubs.la ../../composite/libcomposite.la ../../dix/libmain.la libvnccommon.la ../../../../common/network/libnetwork.la ../../../../common/rfb/librfb.la ../../../../common/rdr/librdr.la ../../../../common/os/libos.la ../../../../unix/common/libunixcommon.la ../../dix/libdix.la ../../mi/libmi.la ../../os/libos.la -L/usr/local/lib -lpixman-1 -lXfont2 -lXau -lsystemd -lxshmfence -lXdmcp   -laudit -lm -lbsd   -lGL -lX11 -laudit -lm -lbsd
sudo cp -f ./Xvnc /usr/bin/Xtigervnc

./Xvnc --help
./Xvnc :5 -geometry 1080x600 -depth 24 &


给进程发送 SIGUSR1 信号
kill -s SIGUSR1 7383

实测下面这两行指令没有用:
xrandr --newmode "777X88_60.00"
xrandr --addmode VNC-0 777x88_60.00

注意编译过程中的这一行：
dpkg-source: info: local changes detected, the modified files are:



修改文件后的快速编译
cd ~/dev/zzswmgr/tmp/tigervnc-1.12.0+dfsg/obj-x86_64-linux-gnu/unix/xserver
make -j12

其它：
	./configure --prefix=/usr \
		--disable-silent-rules \
		--disable-static \
		--without-dtrace \
		--disable-strict-compilation \
		--disable-debug \
		--disable-unit-tests \
		--with-int10=x86emu \
		--with-extra-module-dir="/usr/lib/${DEB_HOST_MULTIARCH}/xorg/extra-modules,/usr/lib/xorg/extra-modules" \
		--with-os-vendor="$(VENDOR)" \
		--with-builderstring="$(SOURCE_NAME) $(SOURCE_VERSION) ($(BUILDER))" \
		--with-xkb-path=/usr/share/X11/xkb \
		--with-xkb-output=/var/lib/xkb \
		--with-default-xkb-rules=evdev \
		--disable-devel-docs \
		--enable-mitshm \
		--enable-xres \
		--disable-xcsecurity \
		--disable-tslib \
		--enable-dbe \
		--disable-xf86bigfont \
		--disable-dpms \
		--disable-config-hal \
		--disable-config-udev \
		--disable-xorg \
		--disable-xquartz \
		--disable-xwin \
		--disable-xfake \
		--disable-install-setuid \
		--with-default-font-path="/usr/share/fonts/X11/misc,/usr/share/fonts/X11/cyrillic,/usr/share/fonts/X11/100dpi/:unscaled,/usr/share/fonts/X11/75dpi/:unscaled,/usr/share/fonts/X11/Type1,/usr/share/fonts/X11/100dpi,/usr/share/fonts/X11/75dpi,/var/lib/defoma/x-ttcidfont-conf.d/dirs/TrueType,built-ins" \
		--enable-aiglx \
		--enable-composite \
		--enable-record \
		--enable-xv \
		--enable-xvmc \
		--enable-dga \
		--enable-screensaver \
		--enable-xdmcp \
		--enable-xdm-auth-1 \
		--enable-glx \
		--disable-dri --enable-dri2 --enable-dri3 \
		--enable-xinerama \
		--enable-xf86vidmode \
		--enable-xace \
		--enable-xfree86-utils \
		--disable-dmx \
		--disable-xvfb \
		--disable-xnest \
		--disable-kdrive \
		--disable-xephyr \
		--enable-xfbdev \
		--with-sha1=libgcrypt \
		--enable-xcsecurity \
		--disable-docs \
		--disable-selective-werror)
	touch config-stamp



'

action=$1
if [ "$action" == "" ]; then action=安装; fi

SWNAME=tigervnc
swVer=1.12.0+dfsg

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
		cp -f ${SWMGR_DIR}/scripts/res/tigervnc_patch_xvnc.c ${SRC_DIR}/unix/xserver/hw/vnc/xvnc.c

		# # 有些项目的源码，修改后需要 commit 才能编译, 比如 libfm, 实测 weston 不需要，反而还省点事了
		# # dpkg-source --commit
	else
		echo "正在修改源码"
		cp -f ${SWMGR_DIR}/scripts/res/tigervnc_patch_xvnc.c ${SRC_DIR}/unix/xserver/hw/vnc/xvnc.c
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
		# make -f debian/rules build
		# -nc, --no-pre-clean
		# -us, --unsigned-source
		# -uc, --unsigned-changes
		# --no-sign               do not sign any file.
		# dpkg-buildpackage -nc -us -uc -j12 -aarmhf # 可以指定架构
		dpkg-buildpackage -nc -us -uc -j12
		exit_if_fail $? "编译失败"

		# # export  CFLAGS=" -D__ANDROID__ "
		# # export LDFLAGS=" -L${SRC_DIR}/linuxlib -Wl,-rpath='\$\$ORIGIN/linuxlib' -latomic -llog -landroid -lc -lm " # -Wl,-Bstatic -ltalloc

		# export  CFLAGS=" -I${TMPDIR}/libffi/release/${OS_ARCH}/include -I${TMPDIR}/libwaylandclient/release/${OS_ARCH}/include -D__DEBUG__ -DANDROID_BUILD -DANDROID"
		# export LDFLAGS=" -L${TMPDIR}/libffi/release/${OS_ARCH}/lib -L${TMPDIR}/libwaylandclient/release/${OS_ARCH}/lib/alib -latomic -stdlib=libstdc++" # -Wl,-Bstatic -ltalloc

		# cd "${SRC_DIR}"
		# make V=1
		# exit_if_fail $? "编译失败"

		# echo "正在安装"
		# sudo dpkg -i ${SWMGR_DIR}/tmp/libweston-10-0_10.0.1-1_arm64.deb

		# echo "正在打包"
		# cp  -f ${SRC_DIR}/wldemo1							${INSTALL_DIR}/
		# cp  -f ${SRC_DIR}/wldemo2							${INSTALL_DIR}/
		# # cp -rf ${SRC_DIR}/linuxlib							${INSTALL_DIR}/
		# # mv  -f $INSTALL_DIR/linuxlib/libwayland-client.so	${INSTALL_DIR}/linuxlib/libwayland-client.so.0
		# # cp -f /usr/lib/aarch64-linux-gnu/libffi.so.8		${INSTALL_DIR}/linuxlib/
		# # cp -f /usr/lib/aarch64-linux-gnu/libc.so.6			${INSTALL_DIR}/linuxlib/
		# # cp -f /usr/lib/aarch64-linux-gnu/ld-linux-aarch64.so.1	${INSTALL_DIR}/linuxlib/
		

		# # patchelf --set-rpath "\$ORIGIN" ${INSTALL_DIR}/linuxlib/*
		
		# # chmod 755 ${INSTALL_DIR}/linuxlib/*
		# # ls -al ${INSTALL_DIR}/linuxlib/
		
		echo "编译完成，请查看：./tmp 目录" # "$INSTALL_DIR"

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
