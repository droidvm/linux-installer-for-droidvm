#!/system/bin/sh
#!busybox sh


# 参考及引用：
# -----------------------------------
# https://gitee.com/sharpeter/proot-ubuntu
# https://blog.csdn.net/qq_39586925/article/details/105653918?spm=1001.2014.3001.5501
#
# https://mirrors.tuna.tsinghua.edu.cn/
# https://mirrors.tuna.tsinghua.edu.cn/archlinuxarm/os/
# wget https://mirrors.tuna.tsinghua.edu.cn/archlinuxarm/os/ArchLinuxARM-aarch64-latest.tar.gz
# http://cdimage.ubuntu.com/ubuntu-core/22/stable/20220525.4/
# https://cdimage.ubuntu.com/ubuntu-base/releases/20.04/release/
# 
# https://mirrors.tuna.tsinghua.edu.cn/lxc-images/images/ubuntu/focal/arm64/default/20220528_07%3A43/	用这个比较妥 100MB 左右
# https://cdimage.ubuntu.com/ubuntu-base/releases/20.04/release/										这个是ubuntu官方的最简系统，不好用
# 
# 





cd ${tools_dir}
# pwd
source ${tools_dir}/vm_config.sh
source ${app_home}/droidvm_vars_setup.sh
HOST_CPU_ARCH=`get_std_arch`

script_pid=$$
pmadd $script_pid setup_linux.sh


echo "此脚本需要在 android console 中运行"
echo ""
echo "setup_linux.sh(pid: $script_pid)"
echo "当前设备的CPU架构: ${HOST_CPU_ARCH}(get in shell script)"
# set
echo '===================================='




function exit_with_msg() {
	echo ""
	echo ""
	echo '===================================='
	echo $2

	echo "安装脚本即将退出, 但会启动telnetd以便您排查"
	echo ""

	echo2apk "正在启动 android telnetd, port: 5555"
	ndkdumpip
	busybox telnetd -p 5555 -l /system/bin/sh &

	exit $1
}

function do_start_vm() {
	# ./startvm.sh 2>&1 >$APP_STDIO_NAME <$APP_STDIO_NAME
	exec ./startvm.sh 2>&1
}

function setup_complete() {
	#################################################################################

	chmod 777 startvm.sh  #2>/dev/null
	chmod 777 run_once.sh #2>/dev/null

	pmdel $script_pid
	echo2apk '正在通过 proot 加载 linux 环境'
	do_start_vm
}




# 用busybox增加指令, 后面的脚本依赖这些指令 =============================
# clear
cp -f ../busybox ./
chmod 755 busybox
if [ ! -x wget ]; then
	echo 'android shell中可用的指令太少，正在使用busybox添加扩展指令'
	echo '正在添加 tar  指令(安卓自带的tar被裁剪过，功能不完整)'
	echo '正在添加 wget 指令(其实busybox中的wget在处理ssl的时候也有问题)'
	echo ''
	echo ''

	#busybox ash
	# cp ../busybox ./

	# case "${HOST_CPU_ARCH}" in
	# 	"arm64")
	# 		echo "正在复制 arm64 busybox"
	# 		cp -f busybox-v1_34_1/arm64/busybox	./
	# 		;;
	# 	"amd64")
	# 		echo "正在复制 amd64 busybox"
	# 		cp -f busybox-v1_34_1/x86_64/busybox	./
	# 		;;
	# 	*)
	# 		exit_with_msg 5 "运行失败, 不支持的CPU架构: ${HOST_CPU_ARCH}"
	# 		;;
	# esac

	ln -f -s busybox tar
	ln -f -s busybox wget
	ln -f -s busybox tcpsvd
	ln -f -s busybox mkfifo
	ln -f -s busybox head
	ln -f -s busybox awk
	ln -f -s busybox id
	ln -f -s busybox paste
	ln -f -s busybox tr
	ln -f -s busybox gzip
	ln -f -s busybox gunzip
	ln -f -s busybox unzip
	ln -f -s busybox xz
	ln -f -s busybox ip

	#curl from termux
	# mkdir exe_curl
	# tar -zxf misc/curl.tar.gz -C exe_curl
	# chmod 777 exe_curl/*
	# ln -s exe_curl/curl curl

	# ls -al>tmp.txt
	# cat tmp.txt
	# pwd
	# echo $PATH

fi

## hardcode
# echo "#droidconsole" > ${NOTIFY_PIPE}
# rm -rf ./ndkpulseaudio

if [ ! -d ./ndkpulseaudio ]; then
	URL_EX_NDK_TOOLS=${APP_URL_DLSERVER}/${FILE_NAME_EX_NDK_TOOLS}
	echo2apk "正在下载 EX_NDK_TOOLS"
	echo "正在下载 ${URL_EX_NDK_TOOLS}"
	echo "app_temp: ${app_temp}"
	ndkhttpsget $URL_EX_NDK_TOOLS ${FILE_NAME_EX_NDK_TOOLS}  2>&1
	httpget_rlt=$?
	if [ $httpget_rlt -ne 0 ]; then
		rm -rf ${app_temp}/$FILE_NAME_EX_NDK_TOOLS
	else
		mv -f ${app_temp}/$FILE_NAME_EX_NDK_TOOLS ./
		busybox unzip -q -o ${FILE_NAME_EX_NDK_TOOLS} -d ./
		# tar -xzf ./${FILE_NAME_EX_NDK_TOOLS} --overwrite -C ./
		# tar_rlt=$?
		# echo "tar_rlt: ${tar_rlt}"
		# if [ $tar_rlt -ne 0 ]; then
		# 	exit_with_msg 5 "解压失败: ./${FILE_NAME_EX_NDK_TOOLS}"
		# fi
	fi

	if [ ! -d ./ndkpulseaudio ]; then
		exit_with_msg 5 "EX_NDK_TOOLS 下载解压失败"
	fi
fi

# xlorie
rm -rf ${tools_dir}/libXlorie.so
ln -sf ./xlorie/${HOST_CPU_ARCH}/libXlorie.so ${tools_dir}/libXlorie.so
# cp -f ./xlorie/${HOST_CPU_ARCH}/libXlorie.so ${tools_dir}/libXlorie.so
pwd
ls -al ${tools_dir}/libXlorie.so




#################################################################################
if [ -x backupvm.sh ]; then
	echo2apk "正在备份系统，备份完成会自动重启，请稍候"

	pmdel $script_pid
	# ./backupvm.sh 2>&1 >$APP_STDIO_NAME <$APP_STDIO_NAME
	./backupvm.sh 2>&1
	rm -rf ./backupvm.sh
fi

#################################################################################
if [ -x restorevm.sh ]; then
	echo2apk "正在还原系统，还原完成会自动重启，请稍候"

	pmdel $script_pid
	# ./restorevm.sh 2>&1 >$APP_STDIO_NAME <$APP_STDIO_NAME
	./restorevm.sh 2>&1

	LINUX_TXT="您之前备份的系统镜像文件"
	LINUX_ZIP=imgbak/bak_${CURRENT_OS_NAME}.tar.gz
	UNZIP_ARG=-xzf

	echo "img: |$LINUX_ZIP|"

	rm -rf ./startvm.sh
	rm -rf ./restorevm.sh

	OSRESTORING=1
else
	OSRESTORING=0
fi

#################################################################################
if [ -x startvm.sh ]; then
	echo2apk "正在启动"

	if [ -f ${APP_FILENAME_URLTOOLS} ]; then
		mkdir -p $LINUX_DIR/etc/droidvm/bootup_scripts/tools/ 2>/dev/null
		cp -f def_startvm.sh	startvm.sh
		chmod 755 startvm.sh  2>/dev/null
		cp -f startvm.sh $LINUX_DIR/etc/droidvm/bootup_scripts/tools/
	fi

	pmdel $script_pid

	do_start_vm
	exit 0
fi


#################################################################################
if [ "$OSRESTORING" != "1" ]; then
	echo2apk "正在全新安装 虚拟系统(删除ipc目录可手动安装)"
fi

rm -rf $LINUX_DIR
mkdir $PROOT_TMP_DIR
chmod 777 $PROOT_TMP_DIR

echo "LINUX_DIR => $LINUX_DIR"

# 镜像选择
#################################################################################

function prompt_download_msg() {
	donwload_promted=0
	if [ "$donwload_promted" != "0" ]; then
		return
	fi
	donwload_promted=1

	echo "   虚拟机信息: "
	echo "=========================================="
	echo "HOST_CPU_ARCH: ${HOST_CPU_ARCH}"
	echo "  VM_CPU_ARCH: ${VM_CPU_ARCH}"
	echo "   CROSS_ARCH: ${CROSS_ARCH}"
	echo "  vmGraphicsx: ${vmGraphicsx}"
	echo ""

	echo -e "耗时 约${TIME_COST}分钟(下载+安装)。\n安装完成会自动进入桌面环境.\n\n请保持前台运行，等待安装完成\n请保持前台运行，等待安装完成\n请保持前台运行，等待安装完成\n\n安装过程中建议您不要操作手机\n如有电话或好友消息，请浮窗回复\n\n安装程序开启的进程数量较多，后台运行时容易被【省电机制】终止运行，安装失败会导致启动黑屏" > "../tmp/promptmsg.txt"
	echo2apk "#initprompt"
}

function user_select_url() {
	# DEF_IMG_arm64=0
	# DEF_IMG_amd64=1

	# case "${vmCpuArchId}" in
	# 	"1")
	# 		DEF_IMG_SEL=$DEF_IMG_amd64
	# 		;;
	# 	"0")
	# 		DEF_IMG_SEL=$DEF_IMG_arm64
	# 		;;
	# 	*)
	# 		DEF_IMG_SEL=$DEF_IMG_arm64
	# 		;;
	# esac

	# echo "虚拟电脑将rootfs分为以下两类:"
	# echo " 1). 常规系的rootfs https://cdimage.ubuntu.com/ubuntu-base/releases/22.10/release/"
	# echo " 2). lxc 系的rootfs https://mirrors.tuna.tsinghua.edu.cn/lxc-images/images/ubuntu/kinetic/"
	# echo "     "
	# echo "第一种体积小运行速度稍快, 但dbus容易出现莫名其妙的问题, dpkg/apt 安装软件的时候也容易出错"
	# echo "请尽量选择lxc-rootfs镜像"
	# echo ""
	# echo ""
	# # echo "请选择rootfs"
	# # echo "输入其它值将取消安装 请选择 [1/2/3]"
	# # read -t 180 readrlt
	# readrlt=${DEF_IMG_SEL}
	# echo "自动化安装不会显示可用的 rootfs 列表."
	# echo "已选择的rootfs_id: |$readrlt|"

	# LINUX_TXT=$(eval echo \$IMAGE_TXT_${readrlt})
	# LINUX_ZIP=$(eval echo \$IMAGE_ZIP_${readrlt})
	# LINUX_URL=$(eval echo \$IMAGE_URL_${readrlt})"/$LINUX_ZIP"
	# UNZIP_ARG=$(eval echo \$UNZIP_OPT_${readrlt})

	# UNZIP_ARG="$UNZIP_ARG"
	# UNZIP_ARG="$UNZIP_ARG -v"



	# # ubuntu 官网镜像，更新频繁，难以汉化
	# LINUX_TXT="ubuntu官网"
	# LINUX_ZIP=ubuntu-base-${LINUX_ROOTFS_VER}-base-${CURRENT_VM_ARCH}.tar.gz
	# LINUX_URL=https://cdimage.ubuntu.com/ubuntu-base/releases/${LINUX_ROOTFS_VER}/release/$LINUX_ZIP
	# UNZIP_ARG=-xzf

	# ## 固定的镜像，用得时间最久
	# LINUX_TXT="虚拟电脑官网"
	# LINUX_ZIP=lxc_ubuntu-base-${LINUX_ROOTFS_VER}-base-${CURRENT_VM_ARCH}.tar.xz
	# LINUX_URL=${APP_URL_DLSERVER}/$LINUX_ZIP
	# UNZIP_ARG=-xJf
}

function get_debug_image_url() {

	# LINUX_URL=
	# echo "已停用 debug image"
	# return

	LINUX_TXT="本地调试服务器"

	case "${vmDistribution}" in
		"3")
			LINUX_ZIP=deepin-aarch64-pd-v4.0.2.tar.xz
			LINUX_URL=${APP_URL_DLSERVER}/$LINUX_ZIP
			UNZIP_ARG=-xJf

			LINUX_ZIP=deepin-rootfs-arm64.tar.gz
			LINUX_URL=https://mirror.ghproxy.com/https://github.com/deepin-community/deepin-rootfs/releases/download/v1.2.0/$LINUX_ZIP
			UNZIP_ARG=-xf
			
			;;
		"2")
			LINUX_ZIP=lxc_debian-12.04-arm64.tar.gz
			LINUX_URL=${APP_URL_DLSERVER}/$LINUX_ZIP
			UNZIP_ARG=-xzf
			;;
		"1" | *)

			LINUX_URL=
			echo "已停用 debug image"
			return

			if [ 1 -eq 0 ]; then
				LINUX_ZIP=ubuntu-base-${LINUX_ROOTFS_VER}-base-${CURRENT_VM_ARCH}.tar.gz
				LINUX_URL=${APP_URL_DLSERVER}/$LINUX_ZIP
				UNZIP_ARG=-xzf

				# LINUX_ZIP=lxc_ubuntu-base-${LINUX_ROOTFS_VER}-base-${CURRENT_VM_ARCH}.tar.xz
				# LINUX_URL=${APP_URL_DLSERVER}/$LINUX_ZIP
				# UNZIP_ARG=-xJf
			else
				# https://cdimage.ubuntu.com/ubuntu-base/releases/23.10/release/ubuntu-base-23.10-base-arm64.tar.gz
				LINUX_TXT="ubuntu官网"
				LINUX_ZIP=ubuntu-base-${LINUX_ROOTFS_VER}-base-${CURRENT_VM_ARCH}.tar.gz
				LINUX_URL=https://cdimage.ubuntu.com/ubuntu-base/releases/${LINUX_ROOTFS_VER}/release/$LINUX_ZIP
				UNZIP_ARG=-xzf
			fi
			;;
	esac
}

function get_url_from_tsinghua() {
	LINUX_TXT="清华大学lxc-image仓库"
	LINUX_ZIP=rootfs.tar.xz
	echo "LINUX_TXT: $LINUX_TXT"
	tmp_base_url=https://mirrors.tuna.tsinghua.edu.cn/lxc-images/images/${LINUX_DISTRIBUTION}/${LINUXVersionName}/${CURRENT_VM_ARCH}/default/
	ndkhttpsget ${tmp_base_url} index.html  2>&1
	httpget_rlt=$?
	if [ $httpget_rlt -ne 0 ]; then
		rm -rf ${app_temp}/index.html
	fi
	cp -f ${app_temp}/index.html ./ 2>/dev/null
	DATETIME_FIELD=
	if [ -f index.html ]; then
		DATETIME_FIELD=$(busybox cat index.html |grep 'title="20'|grep 'href="20'|${tools_dir}/awk -v FS="\"" '{print $4}'|${tools_dir}/head -c 16) 2>&1
	fi
	LINUX_URL=${tmp_base_url}$DATETIME_FIELD/$LINUX_ZIP
	UNZIP_ARG=-xJf
}

function get_url_from_bfsu() {
	LINUX_TXT="北京外国语大学lxc-image仓库"
	LINUX_ZIP=rootfs.tar.xz
	echo "LINUX_TXT: $LINUX_TXT"
	tmp_base_url=https://mirrors.bfsu.edu.cn/lxc-images/images/${LINUX_DISTRIBUTION}/${LINUXVersionName}/${CURRENT_VM_ARCH}/default/
	ndkhttpsget ${tmp_base_url} index.html  2>&1
	httpget_rlt=$?
	if [ $httpget_rlt -ne 0 ]; then
		rm -rf ${app_temp}/index.html
	fi
	cp -f ${app_temp}/index.html ./ 2>/dev/null
	DATETIME_FIELD=
	if [ -f index.html ]; then
		DATETIME_FIELD=$(busybox cat index.html |grep 'title="20'|grep 'href="20'|${tools_dir}/awk -v FS="\"" '{print $4}'|${tools_dir}/head -c 16) 2>&1
	fi
	LINUX_URL=${tmp_base_url}$DATETIME_FIELD/$LINUX_ZIP
	UNZIP_ARG=-xJf
}

function get_url_from_nyist() {
	LINUX_TXT="南阳理工学院lxc-image仓库"
	LINUX_ZIP=rootfs.tar.xz
	echo "LINUX_TXT: $LINUX_TXT"
	tmp_base_url=https://mirror.nyist.edu.cn/lxc-images/images/${LINUX_DISTRIBUTION}/${LINUXVersionName}/${CURRENT_VM_ARCH}/default/
	ndkhttpsget ${tmp_base_url} index.html  2>&1
	httpget_rlt=$?
	if [ $httpget_rlt -ne 0 ]; then
		rm -rf ${app_temp}/index.html
	fi
	cp -f ${app_temp}/index.html ./ 2>/dev/null
	DATETIME_FIELD=
	if [ -f index.html ]; then
		DATETIME_FIELD=$(busybox cat index.html |grep 'title="20'|grep 'href="20'|${tools_dir}/awk -v FS="\"" '{print $4}'|${tools_dir}/head -c 16) 2>&1
	fi
	LINUX_URL=${tmp_base_url}$DATETIME_FIELD/$LINUX_ZIP
	UNZIP_ARG=-xJf
}

function get_url_from_iscas() {
	LINUX_TXT="中国科学院软件研究所lxc-image仓库"
	LINUX_ZIP=rootfs.tar.xz
	echo "LINUX_TXT: $LINUX_TXT"
	tmp_base_url=https://mirror.iscas.ac.cn/lxc-images/images/${LINUX_DISTRIBUTION}/${LINUXVersionName}/${CURRENT_VM_ARCH}/default/
	ndkhttpsget ${tmp_base_url} index.html  2>&1
	httpget_rlt=$?
	if [ $httpget_rlt -ne 0 ]; then
		rm -rf ${app_temp}/index.html
	fi
	cp -f ${app_temp}/index.html ./ 2>/dev/null
	DATETIME_FIELD=
	if [ -f index.html ]; then
		DATETIME_FIELD=$(busybox cat index.html |grep 'title="20'|grep 'href="20'|${tools_dir}/awk -v FS="\"" '{print $6}'|${tools_dir}/head -c 16) 2>&1
	fi
	LINUX_URL=${tmp_base_url}$DATETIME_FIELD/$LINUX_ZIP
	UNZIP_ARG=-xJf
}

function get_url_from_nju() {
	LINUX_TXT="南京大学lxc-image仓库"
	LINUX_ZIP=rootfs.tar.xz
	echo "LINUX_TXT: $LINUX_TXT"
	tmp_base_url=https://mirror.nju.edu.cn/lxc-images/images/${LINUX_DISTRIBUTION}/${LINUXVersionName}/${CURRENT_VM_ARCH}/default/
	ndkhttpsget ${tmp_base_url} index.html  2>&1
	httpget_rlt=$?
	if [ $httpget_rlt -ne 0 ]; then
		rm -rf ${app_temp}/index.html
	fi
	cp -f ${app_temp}/index.html ./ 2>/dev/null
	DATETIME_FIELD=
	if [ -f index.html ]; then
		DATETIME_FIELD=$(busybox cat index.html |grep 'title="20'|grep 'href="20'|${tools_dir}/awk -v FS="\"" '{print $6}'|${tools_dir}/head -c 16) 2>&1
	fi
	LINUX_URL=${tmp_base_url}$DATETIME_FIELD/$LINUX_ZIP
	UNZIP_ARG=-xJf
}


function do_donwload_rootfs() {
	if [ "$LINUX_URL" == "" ]; then
		return
	fi

	echo2apk "正在下载 linux 镜像包"
	echo "下载站点：$LINUX_TXT"
	echo "下载链接：$LINUX_URL"
	echo "下载文件：$LINUX_ZIP"
	echo ""

	# UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.54 Safari/537.36"

	ndkhttpsget $LINUX_URL $LINUX_ZIP  2>&1
	httpget_rlt=$?
	if [ $httpget_rlt -ne 0 ]; then
		rm -rf ${app_temp}/$LINUX_ZIP
	else
		mv -f ${app_temp}/$LINUX_ZIP ./
	fi
}

function donwload_rootfs() {
	if [ "$OSRESTORING" == "1" ]; then
		return
	fi

	mkdir -p ../tmp
	TIME_COST=" 3"
	VM_CPU_ARCH=${CURRENT_VM_ARCH}
	CROSS_ARCH=0
	if [ "${HOST_CPU_ARCH}" != "${VM_CPU_ARCH}" ]; then
		CROSS_ARCH=1
	fi

	if [ "${vmGraphicsx}" == "1" ]; then
		# 安装图形界面
		if [ "${CROSS_ARCH}" == "1" ]; then
			TIME_COST="15"
		else
			TIME_COST="10"
		fi
	else
		# 不装图形界面
		if [ "${CROSS_ARCH}" == "1" ]; then
			TIME_COST=" 5"
		else
			TIME_COST=" 3"
		fi
	fi

	prompt_download_msg

	LINUX_ZIP=不存在的文件名.gz

	if [ $APP_RELEASE_INTERNAL -ne 0 ]; then
		if [ ! -f $LINUX_ZIP ]; then
			get_debug_image_url
			do_donwload_rootfs
		fi
	fi


	# 清华大学 lxc-image 镜像站点
	if [ ! -f $LINUX_ZIP ]; then
		get_url_from_tsinghua
		do_donwload_rootfs
	fi

	# 北京外国语大学 lxc-image 镜像站点
	if [ ! -f $LINUX_ZIP ]; then
		get_url_from_bfsu
		do_donwload_rootfs
	fi

	# 中国科学院软件研究所lxc-image仓库
	if [ ! -f $LINUX_ZIP ]; then
		get_url_from_iscas
		do_donwload_rootfs
	fi

	# 南京大学lxc-image仓库
	if [ ! -f $LINUX_ZIP ]; then
		get_url_from_nju
		do_donwload_rootfs
	fi

	# 南阳理工学院lxc-image仓库
	if [ ! -f $LINUX_ZIP ]; then
		get_url_from_nyist
		do_donwload_rootfs
	fi


	rootfs_not_exist=0

	if [ "$LINUX_URL" == "" ]; then
		rootfs_not_exist=1
	fi
	if [ "$LINUX_ZIP" == "" ]; then
		rootfs_not_exist=1
	fi
	if [ ! -f $LINUX_ZIP ]; then
		rootfs_not_exist=1
	fi

	if [ "$rootfs_not_exist" == "1" ]; then
		echo2apk "linux 镜像包下载失败"
		exit_with_msg 4 "linux 镜像包下载失败"
		# exit 4
	fi

	chmod 666 $LINUX_ZIP
	echo "LINUX_ZIP => $LINUX_ZIP"
	ls -al $LINUX_ZIP

}

# 镜像下载，注意 busybox 内带的wget不支持https
#################################################################################
donwload_rootfs


# 解压镜像
#################################################################################
echo "LINUX_TXT: |"$LINUX_TXT"|"
echo "LINUX_ZIP: |"$LINUX_ZIP"|"
echo "LINUX_URL: |"$LINUX_URL"|"
echo "UNZIP_ARG: |"$UNZIP_ARG"|"

echo ""
echo ""
echo2apk "正在解压系统文件"
echo "解压过程中请保持前台运行，不要关闭软件"
echo "解压过程中请保持前台运行，不要关闭软件"
echo "解压过程中请保持前台运行，不要关闭软件"
echo "解压过程中请保持前台运行，不要关闭软件"
echo "解压过程中请保持前台运行，不要关闭软件"
mkdir -p $LINUX_DIR

tar_rlt=2
chmod 755 ${PROOT_BINARY_DIR}/*
chmod 755 ${PROOT_BINARY_DIR}/loader/*

if [ 1 -eq 0 ]; then
	# 这种解包方式无法处理 hardlink，而且解压后，各目录的权限不对。。。
	# LINUX_ZIP_FULLPATH=`pwd`/$LINUX_ZIP
	rm -rf $LINUX_DIR/*
	busybox tar  --overwrite --no-same-permissions -h $UNZIP_ARG $LINUX_ZIP -C  $LINUX_DIR 2>./tar.stderr

	tar_rlt=1
	# 有除此之外的其它错误信息吗？若没有，则当成解压成功!!!!
	grep -v "can't create hardlink" ./tar.stderr
	if [ $? -ne 0 ]; then
		tar_rlt=0
	fi
else
	# 创建一个临时的 vm 来解压 rootfs
	${PROOT_BINARY_DIR}/proot --link2symlink --kill-on-exit -0 -r $LINUX_DIR -w / -b ${tools_dir}:/exbin \
	"/exbin/tar" $UNZIP_ARG /exbin/$LINUX_ZIP -C / --exclude='dev' 2>&1
	tar_rlt=$?
fi

echo "解压返回值: |$tar_rlt|"

if [ "$OSRESTORING" == "1" ]; then
	mkdir -p  $LINUX_DIR/tmp
	chmod 777 $LINUX_DIR/tmp

	echo "系统还原已完成."
    echo "系统还原已完成." > $LINUX_DIR/tmp/osrestoremsg.txt

	cp -f def_startvm.sh	startvm.sh
	setup_complete
	exit 0
fi

if [ $tar_rlt -ne 0 ]; then
	echo2apk "解压失败"
	cat unzipmsg.txt 2>/dev/null
	rm -rf $LINUX_DIR

	# 把无法解压的rootfs也删掉!
	if [ "$OSRESTORING" != "1" ]; then
		rm -rf $LINUX_ZIP
	fi

	exit_with_msg 5 "解压失败"
	# exit 5
else
	rm -rf $LINUX_ZIP
	echo2apk "解压完成"
fi


#################################################################################
if [ 1 -eq 0 ]; then
echo2apk "正在解压deb包"
wget http://192.168.1.5:90/debs.tar.gz
mkdir -p $LINUX_DIR/var/cache/apt/archives/
tar -xzvf debs.tar.gz -C $LINUX_DIR/var/cache/apt/archives/
ls -al $LINUX_DIR/var/cache/apt/archives/
# exit
fi


# echo '===================================='
# echo2apk '相当重要的动作'
# echo '===================================='
# chmod 755 $LINUX_DIR/var/lib/dpkg

# 相当重要的动作
#################################################################################
if [ 1 -eq 1 ]; then
	# groups: cannot find name for group ID **** 问题
	# https://blog.csdn.net/babytiger/article/details/112121506
	# https://cloud.tencent.com/developer/article/1742731
	# 在Android中，每一个用户组都有一个唯一的ID号，定义在文件：
	# system\core\include\private\android_filesystem_config.h
	echo '===================================='
	echo2apk '正在添加与安卓宿主系统相应的用户组'
	echo '===================================='
	# addgroup --system --gid 3003  inet
	# addgroup --system --gid 9997  sdcard_rw
	# addgroup --system --gid $((20000+$APP_ANDROID_UID)) cache
	# addgroup --system --gid $((50000+$APP_ANDROID_UID)) all_a$APP_ANDROID_UID
	chmod u+rw \
		"$LINUX_DIR/etc/passwd" \
		"$LINUX_DIR/etc/shadow" \
		"$LINUX_DIR/etc/group" \
		"$LINUX_DIR/etc/gshadow" >/dev/null 2>&1 || true
	echo "aid_$(id -un):x:$(id -u):$(id -g):Android user:/:/sbin/nologin" >> \
		"$LINUX_DIR/etc/passwd"
	echo "aid_$(id -un):*:18446:0:99999:7:::" >> \
		"$LINUX_DIR/etc/shadow"

	id -G  | tr ' ' '\n'>groupids.txt
	id -Gn | tr ' ' '\n'>groupnames.txt
	group_name=
	group_id=
	while read -u3 group_id && read -u4 group_name; do
		echo "正在创建用户组: aid_${group_name}:${group_id}"
		echo "aid_${group_name}:x:${group_id}:root,aid_$(id -un)"	>> "$LINUX_DIR/etc/group"
		if [ -f "$LINUX_DIR/etc/gshadow" ]; then
			echo "aid_${group_name}:*::root,aid_$(id -un)"			>> "$LINUX_DIR/etc/gshadow"
		fi
	done 3<groupids.txt 4<groupnames.txt
	rm -rf groupids.txt
	rm -rf groupnames.txt


	# while read -r group_name group_id; do
	# 	echo "aid_${group_name}:x:${group_id}:root,aid_$(id -un)"	>> "$LINUX_DIR/etc/group"
	# 	if [ -f "$LINUX_DIR/etc/gshadow" ]; then
	# 		echo "aid_${group_name}:*::root,aid_$(id -un)"			>> "$LINUX_DIR/etc/gshadow"
	# 	fi
	# done < <(paste <(id -Gn | tr ' ' '\n') <(id -G | tr ' ' '\n'))
fi



echo2apk "正在添加 $LINUX_DIR 中的自启动脚本"
if [ 1 -eq 1 ]; then
	echo "source /exbin/tools/vm_config.sh"								>>$LINUX_DIR/etc/profile
	echo "alias unlink=rm"												>>$LINUX_DIR/etc/profile
	echo "alias ls='ls --color=auto'"									>>$LINUX_DIR/etc/profile
	echo "export PS1='"'\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '"'" >>$LINUX_DIR/etc/profile

	# echo "source /etc/profile"											>>$LINUX_DIR/root/.bashrc
	# echo "if [ -x \${tools_dir}/run_once.sh ]; then"					>>$LINUX_DIR/root/.bashrc
	# echo "	. \${tools_dir}/run_once.sh"								>>$LINUX_DIR/root/.bashrc
	# echo "fi"															>>$LINUX_DIR/root/.bashrc
	# # echo "echo2apk 'Linux started'"									>>$LINUX_DIR/root/.bashrc
	# echo "if [ -x \${tools_dir}/vm_onstarted.sh ]; then"				>>$LINUX_DIR/root/.bashrc
	# echo "	. \${tools_dir}/vm_onstarted.sh"							>>$LINUX_DIR/root/.bashrc
	# echo "fi"															>>$LINUX_DIR/root/.bashrc

	chmod 750 $LINUX_DIR/etc/profile
	chmod 750 $LINUX_DIR/root/.bashrc
	chmod 750 $LINUX_DIR/root/.profile
fi


# 设置虚拟系统的HOSTNAME，启动时能会通过 -k 参数传给proot
# #################################################################################
echo "DroidVM" >     $LINUX_DIR/etc/hostname

# 更换国内软件仓库，可以加快下载速度，感谢国内各镜像站点...
# #################################################################################
USE_CN_SoftwareRepository=1
if [ $USE_CN_SoftwareRepository -eq 1 ]; then
	echo2apk "正在更换 $LINUX_DIR 中的软件仓库，将使用国内的软件仓库..."

	################################
	# 加新时，注意要添加硬域名解析
	# 相关文件: /etc/hosts
	################################

	source vm_config.sh
	echo "TMPDIR:"$TMPDIR

	# 备份旧的
	cp -f $LINUX_DIR/etc/apt/sources.list				$LINUX_DIR/etc/apt/sources.list.bak.ubuntu

	# amd64
	if [ "${vmCpuArchId}" == "1" ]; then
		if [ "${LINUX_DISTRIBUTION}" == "ubuntu" ]; then
			# 北京外国语大学的软件仓库
			cat <<- EOF > $LINUX_DIR/etc/apt/sources.list
			deb https://mirrors.bfsu.edu.cn/ubuntu/ ${LINUXVersionName} main restricted universe multiverse
			deb https://mirrors.bfsu.edu.cn/ubuntu/ ${LINUXVersionName}-updates main restricted universe multiverse
			deb https://mirrors.bfsu.edu.cn/ubuntu/ ${LINUXVersionName}-backports main restricted universe multiverse
			deb http://security.ubuntu.com/ubuntu/ ${LINUXVersionName}-security main restricted universe multiverse
			EOF
			cp -f $LINUX_DIR/etc/apt/sources.list				$LINUX_DIR/etc/apt/sources.list.bak.bfsu


			# 中科大
			cat <<- EOF > $LINUX_DIR/etc/apt/sources.list
			deb https://mirrors.ustc.edu.cn/ubuntu/ ${LINUXVersionName} main restricted universe multiverse
			deb https://mirrors.ustc.edu.cn/ubuntu/ ${LINUXVersionName}-security main restricted universe multiverse
			deb https://mirrors.ustc.edu.cn/ubuntu/ ${LINUXVersionName}-updates main restricted universe multiverse
			deb https://mirrors.ustc.edu.cn/ubuntu/ ${LINUXVersionName}-backports main restricted universe multiverse
			EOF
			cp -f $LINUX_DIR/etc/apt/sources.list				$LINUX_DIR/etc/apt/sources.list.bak.ustc


			# 清华源 - https://mirrors.tuna.tsinghua.edu.cn/help/ubuntu/
			echo "" > $LINUX_DIR/etc/apt/sources.list
			echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${LINUXVersionName} main restricted universe multiverse"					>> $LINUX_DIR/etc/apt/sources.list
			echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${LINUXVersionName}-updates main restricted universe multiverse"			>> $LINUX_DIR/etc/apt/sources.list
			echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${LINUXVersionName}-backports main restricted universe multiverse"		>> $LINUX_DIR/etc/apt/sources.list
			echo "deb http://security.ubuntu.com/ubuntu/ ${LINUXVersionName}-security main restricted universe multiverse"					>> $LINUX_DIR/etc/apt/sources.list
			cp -f $LINUX_DIR/etc/apt/sources.list				$LINUX_DIR/etc/apt/sources.list.bak.tsinghua
		elif [ "${LINUX_DISTRIBUTION}" == "debian" ]; then
			# 清华源 https://mirrors.tuna.tsinghua.edu.cn/help/debian/
			cat <<- EOF > $LINUX_DIR/etc/apt/sources.list
				# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
				deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free non-free-firmware
				# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free non-free-firmware

				deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware
				# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware

				deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-backports main contrib non-free non-free-firmware
				# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-backports main contrib non-free non-free-firmware

				deb https://mirrors.tuna.tsinghua.edu.cn/debian-security bookworm-security main contrib non-free non-free-firmware
				# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian-security bookworm-security main contrib non-free non-free-firmware
			EOF
			cp -f $LINUX_DIR/etc/apt/sources.list				$LINUX_DIR/etc/apt/sources.list.bak_tsinghua
		fi

	else

		if [ "${LINUX_DISTRIBUTION}" == "ubuntu" ]; then
			# 北京外国语大学的软件仓库
			cat <<- EOF > $LINUX_DIR/etc/apt/sources.list
			# Generated by distrobuilder
			##deb https://ports.ubuntu.com/ubuntu-ports ${LINUXVersionName} main restricted universe multiverse
			##deb https://ports.ubuntu.com/ubuntu-ports ${LINUXVersionName}-updates main restricted universe multiverse
			##deb https://ports.ubuntu.com/ubuntu-ports ${LINUXVersionName}-security main restricted universe multiverse
			# deb https://mirrors.huaweicloud.com/ubuntu-ports/ ${LINUXVersionName}-proposed main restricted universe multiverse
			deb https://mirrors.bfsu.edu.cn/ubuntu-ports/ ${LINUXVersionName} main restricted universe multiverse
			deb https://mirrors.bfsu.edu.cn/ubuntu-ports/ ${LINUXVersionName}-updates main restricted universe multiverse
			deb https://mirrors.bfsu.edu.cn/ubuntu-ports/ ${LINUXVersionName}-backports main restricted universe multiverse
			deb https://mirrors.bfsu.edu.cn/ubuntu-ports/ ${LINUXVersionName}-security main restricted universe multiverse
			EOF
			cp -f $LINUX_DIR/etc/apt/sources.list				$LINUX_DIR/etc/apt/sources.list.bak.bfsu

			# 中科大
			cp -f $LINUX_DIR/etc/apt/sources.list.bak.ubuntu	$LINUX_DIR/etc/apt/sources.list
			sed -i 's/ports.ubuntu.com/mirrors.ustc.edu.cn/g'	$LINUX_DIR/etc/apt/sources.list
			cp -f $LINUX_DIR/etc/apt/sources.list				$LINUX_DIR/etc/apt/sources.list.bak.ustc


			# 清华源 - [non x86/x64, without https] from => https://mirrors.tuna.tsinghua.edu.cn/help/ubuntu-ports/
			echo "" > $LINUX_DIR/etc/apt/sources.list
			echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ ${LINUXVersionName} main restricted universe multiverse"			>> $LINUX_DIR/etc/apt/sources.list
			echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ ${LINUXVersionName}-updates main restricted universe multiverse"	>> $LINUX_DIR/etc/apt/sources.list
			echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ ${LINUXVersionName}-backports main restricted universe multiverse"	>> $LINUX_DIR/etc/apt/sources.list
			echo "deb http://ports.ubuntu.com/ubuntu-ports/ ${LINUXVersionName}-security main restricted universe multiverse"				>> $LINUX_DIR/etc/apt/sources.list
			cp -f $LINUX_DIR/etc/apt/sources.list				$LINUX_DIR/etc/apt/sources.list.bak.tsinghua
		elif [ "${LINUX_DISTRIBUTION}" == "debian" ]; then
			# 清华源 https://mirrors.tuna.tsinghua.edu.cn/help/debian/
			cat <<- EOF > $LINUX_DIR/etc/apt/sources.list
				# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
				deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free non-free-firmware
				# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free non-free-firmware

				deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware
				# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware

				deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-backports main contrib non-free non-free-firmware
				# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-backports main contrib non-free non-free-firmware

				deb https://mirrors.tuna.tsinghua.edu.cn/debian-security bookworm-security main contrib non-free non-free-firmware
				# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian-security bookworm-security main contrib non-free non-free-firmware
			EOF
			cp -f $LINUX_DIR/etc/apt/sources.list				$LINUX_DIR/etc/apt/sources.list.bak_tsinghua
		fi
	fi

fi



cp -f def_startvm.sh	startvm.sh
cp -f def_run_once.sh	run_once.sh
setup_complete

