#!/bin/bash

ZIP_KERNEL_SRC=${DIR_DOWNLD}/${VER_KERNEL}.tar.xz

function exit_if_fail() {
    rlt_code=$1
    fail_msg=$2
    if [ $rlt_code -ne 0 ]; then
      echo -e "错误码: ${rlt_code}\n${fail_msg}"
      # read -s -n1 -p "按任意键退出"
      exit $rlt_code
    fi
}


echo "正在安装编译器和内核源码依赖的库"
sudo apt install -y ${GCC_PKG} flex bison openssl libssl-dev libncurses5-dev build-essential bc xz-utils libelf-dev
exit_if_fail $? "编译器和依赖库失败"
# ls -al /usr/bin/|grep gcc|grep riscv

mkdir -p ${DIR_DOWNLD} 2>/dev/null
mkdir -p ${DIR_OUTPUT} 2>/dev/null
cd ${DIR_BUILD}

if [ ! -f ${ZIP_KERNEL_SRC} ]; then
    echo "正在下载linux主线内核源码，下载地址为清华大学的开放仓库"
    # sudo echo "2402:f000:1:400::2  mirror.tuna.tsinghua.edu.cn" >> /etc/hosts
    wget https://mirror.tuna.tsinghua.edu.cn/kernel/v6.x/${VER_KERNEL}.tar.xz -O ${ZIP_KERNEL_SRC}
    exit_if_fail $? "linux内核源码下载失败"
fi

if [ ! -d ${VER_KERNEL} ]; then
    echo "正在解压内核源码"
    tar -xJf ${ZIP_KERNEL_SRC}
    exit_if_fail $? "linux内核源码解压失败"
fi

export ARCH=${LINUX_ARCH}
echo ""
echo "相关架构和使用的编译器："
echo "========================================================================"
echo "当前主机的cpu架构: ${ARCH_HOST_}"
echo "目标主机的cpu架构: ${ARCH_COMP}"
echo "当前选用的gcc工具: ${CROSS_COMPILE}gcc"
echo ""

cd ${DIR_BUILD}/${VER_KERNEL}/

PRE_BUILD_ARCH=`cat ${DIR_OUTPUT}/arch.txt 2>/dev/null`
if [ "${PRE_BUILD_ARCH}" != "" ]; then
    if [ "${ARCH_COMP}" != "${PRE_BUILD_ARCH}" ]; then
        echo ""
        echo "上次编译的目标架构：|${PRE_BUILD_ARCH}|，和本次编译目标架构不同，正在清理"
        echo "正在清理上次编译时产生的中间文件，包括.o和源码配置文件"
        make distclean
        if [ $? -ne 0 ]; then
            echo "错误，无法正常清理上次编译时产生的中间文件，且上次编译的CPU架构和本次不同"
            echo "这会导致本次编译失败以及影响编译结果！"
        fi
    fi
fi
echo "${ARCH_COMP}">"${DIR_OUTPUT}/arch.txt"

function USER_CONFIG_FOR_riscv64() {
    make defconfig
    if [ "$1" == "cm" ]; then
        make menuconfig
    fi
    exit_if_fail $? "linux内核源码配置失败"
}

function USER_CONFIG_FOR_arm64() {
    make defconfig
    if [ "$1" == "cm" ]; then
        make menuconfig
    fi
    exit_if_fail $? "linux内核源码配置失败"
}

function USER_CONFIG_FOR_amd64() {
    make ARCH=x86_64 x86_64_defconfig
    # make ARCH=x86_64 allnoconfig
    if [ "$1" == "cm" ]; then
        make ARCH=x86_64 menuconfig
    fi
    exit_if_fail $? "linux内核源码配置失败"
}

# make defconfig
# make allnoconfig
# make menuconfig
# make ARCH=x86_64 x86_64_defconfig
# make ARCH=x86_64 menuconfig
# make ARCH=x86_64 allnoconfig

PRE_BUILD_CONFIG_FILE=${DIR_OUTPUT}/kernel-${ARCH_COMP}.config
RECOMMEND_CONFIG_FILE=${DIR_SCRIPT}/myconfig/kernel-${ARCH_COMP}.config
case "${SRC_CFG_FROM}" in
	"-c0")
        echo "正在将源码配置为 ${ARCH_COMP} 架构，qemu-virt 机型的默认配置(make defconfig)" >>${TXT_README}
        echo "正在将源码配置为 ${ARCH_COMP} 架构，qemu-virt 机型的默认配置(make defconfig)"
		USER_CONFIG_FOR_${ARCH_COMP}  c0
        if [ $? -ne 0 ]; then
            echo "仅支持 [riscv64|arm64|amd64] 三种CPU架构"
            exit -1
        fi
		;;
	"-c1")
        echo ""                                     >>${TXT_README}
        echo "正在将源码配置为当前架构推荐的配置"   >>${TXT_README}

        if [ -f ${RECOMMEND_CONFIG_FILE} ]; then
            cp -f ${RECOMMEND_CONFIG_FILE}  .config
        else
            echo "此架构没有推荐的配置文件: ${RECOMMEND_CONFIG_FILE}"
            exit -1
        fi
		;;
	"-c2")
        echo ""                                 >>${TXT_README}
        echo "正在将源码配置为上次编译时的配置" >>${TXT_README}

        if [ -f ${PRE_BUILD_CONFIG_FILE} ]; then
            cp -f ${PRE_BUILD_CONFIG_FILE}  .config
        else
            echo "您没有编译过此架构，无法找到上次编译时使用的配置文件: ${PRE_BUILD_CONFIG_FILE}"
            exit -1
        fi
		;;
	"-cm" | * )
        echo "正在启动源码配置程序，目标CPU架构：${ARCH_COMP}"
		USER_CONFIG_FOR_${ARCH_COMP}  cm
        if [ $? -ne 0 ]; then
            echo "仅支持 [riscv64|arm64|amd64] 三种CPU架构"
            exit -1
        fi
        cp -f .config  ${PRE_BUILD_CONFIG_FILE}
		;;
esac



startTime=`date +%Y%m%d-%H:%M:%S`
startTime_s=`date +%s`

echo ""
echo "正在编译内核源码, 开始计时: ${startTime}"
nproc=`cat /proc/cpuinfo | grep processor | wc -l`
if [ "${nproc}" == "" ]; then nproc=4; fi
make -j${nproc}
exit_if_fail $? "linux内核源码编译失败"

endTime=`date +%Y%m%d-%H:%M:%S`
endTime_s=`date +%s`
sumTime=$[ $endTime_s - $startTime_s ]
echo "$startTime --> $endTime" "编译耗时:$sumTime seconds"

echo ""
echo "内核编译完成，生成的linux内核如下(是个文件)："
if [ "${ARCH_COMP}" == "riscv64" ]; then
    COMPILED_LINUX_KERNEL_PATH=${DIR_BUILD}/${VER_KERNEL}/arch/${LINUX_ARCH}/boot/Image
elif [ "${ARCH_COMP}" == "arm64" ]; then
    COMPILED_LINUX_KERNEL_PATH=${DIR_BUILD}/${VER_KERNEL}/arch/${LINUX_ARCH}/boot/Image.gz
elif [ "${ARCH_COMP}" == "amd64" ]; then
    COMPILED_LINUX_KERNEL_PATH=${DIR_BUILD}/${VER_KERNEL}/arch/${LINUX_ARCH}/boot/bzImage
fi
ls ${COMPILED_LINUX_KERNEL_PATH}
cp -f ${COMPILED_LINUX_KERNEL_PATH} ${IMG_KERNEL}
exit_if_fail $? "编译已完成，但复制到工作目录时出错!"
echo "已将其复制为：${IMG_KERNEL}"
echo ""

echo ""                                           >>${TXT_README}
echo "内核已编译完成，生成一个文件，具体如下："          >>${TXT_README}
echo "可启动的内核：${COMPILED_LINUX_KERNEL_PATH}"  >>${TXT_README}
echo "已将其复制为：${IMG_KERNEL}"                  >>${TXT_README}


# 编译内核模块请参考：https://wenku.csdn.net/answer/fffe048b5a1f4cf2b353331ce9f891aa
echo ""
echo "正在编译 \"内核密相关模块\""
make modules -j${nproc} # 把配置值选成M的代码编译生成模块文件。（.ko)  放在对应的源码目录下。
exit_if_fail $? "linux内核模块编译失败"

echo ""
echo "正在把编译生成的内核模块，复制到临时目录"
sudo rm -rf    ${DIR_KNLMOD}
echo "mkdir -p ${DIR_KNLMOD}"
mkdir -p       ${DIR_KNLMOD} 2>/dev/null
exit_if_fail $? "无法创建目录(用于存放与内核极度相关的模块和软件, 比如*.ko、usbip、usbipd): ${DIR_KNLMOD}"
make ARCH=arm64 modules_install INSTALL_MOD_PATH="${DIR_KNLMOD}"
exit_if_fail $? "linux内核模块复制失败"

echo ""                                               >>${TXT_README}
echo "内核各个独立模块已编译完成，已复制到：${DIR_KNLMOD}"  >>${TXT_README}





echo ""
echo "试半天发现usbip居然不支持交叉编译！！！"
if [ "$ARCH_COMP" == "amd64" -a "$ARCH_HOST_" == "x86_64" ]; then
    echo ""
    echo ""
    echo ""
    echo "正在编译 \"内核密相关软件\""
    echo "export ARCH=${LINUX_ARCH}"
    echo "export CROSS_COMPILE=${CROSS_COMPILE}"
    echo ""

    sudo apt install -y autoconf libtool libconfuse-dev libudev-dev gcc make file
    exit_if_fail $? "在编译 内核密相关软件  时，依赖库安装失败"

    echo ""
    echo "正在配置usbip/usbipd" # 参考：https://wiki.beyondlogic.org/index.php/Cross_Compiling_USBIP_for_ARM
    cd ${DIR_BUILD}/${VER_KERNEL}/tools/usb/usbip

    ARCH=${LINUX_ARCH} CROSS_COMPILE=${CROSS_COMPILE} ./autogen.sh
    exit_if_fail $? "usbip编译失败 fail to autogen"

    echo ""
    echo "正在配置usbip/usbipd"
    # riscv64-linux-gnu
    ./configure --prefix=${DIR_KNLAPP} --target=${LINUX_ARCH}-linux-gnu
    exit_if_fail $? "usbip编译失败 fail to configure"

    
    echo ""
    echo "正在编译usbip/usbipd"
    sudo make clean
    make -j4
    exit_if_fail $? "usbip编译失败 fail to make"

    echo ""
    echo "正在安装usbip/usbipd"
    echo "export ARCH=${LINUX_ARCH}"
    echo "export CROSS_COMPILE=${CROSS_COMPILE}"
    ARCH=${LINUX_ARCH} CROSS_COMPILE=${CROSS_COMPILE}  sudo make install
    exit_if_fail $? "usbip编译失败 fail to make install"


    echo ""                                             >>${TXT_README}
    echo "内核密相关的软件已编译完成，已复制到：${DIR_KNLAPP}" >>${TXT_README}


    # 2024.05.13 增加
    KERNEL_BASENAME=`basename ${IMG_KERNEL}`
    (cd ${DIR_OUTPUT} && tar -czf ${KERNEL_BASENAME}.tar.gz  ${KERNEL_BASENAME} kernel-related/ )

fi
