#!/bin/bash

: '
                
    ==============================================================================
    《半小时，无痛体验一次自己编译并运行linux-6.6主线内核 ---- x86_64 架构 qemu-virt机型》
    ==============================================================================


    建议的两种编译环境：
    ==============================================================================
    1).安装了ubuntu系统的x86架构电脑
    2).或者安卓手机上的虚拟电脑app(里面的linux是ubuntu环境)


    主线内核源码：
    ==============================================================================
    1). linux内核源码一般分为 主线源码 和 各种分支源码
    2). 主线源码，由创始人开发、合并、维护
    3). 分支源码，是各厂家根据自己需要修改的
        修改了的部分，可以向主线源码管理方申请并入修改的部分，但不一定能通过。
        申请方式不确定是用mail还是走github还是其它方式，没试过

    发行版linux操作系统
    ==============================================================================
    1). 大多使用主线内核源码，且通常以iso镜像文件的形式发布
    2). 大多有自己的软件仓库，但收录的驱动、软件、library不同，软件管理工具也不同(apt, yum, dnf)
    3). 桌面环境默认使用的软件不同(kde, gnome, xfce4, 其它...)



参考1：《linux主线内核源码官方下载地址》
========================================================================================================
https://mirrors.edge.kernel.org/pub/linux/kernel/
https://mirror.tuna.tsinghua.edu.cn/kernel/

参考2：《ubuntu-base, ubuntu发行版最小的rootfs下载, 不到30MB》 # 但是集成了apt指令，方便安装ubuntu软件仓库中的软件
========================================================================================================
https://mirrors.aliyun.com/ubuntu-cdimage/ubuntu-base/releases/22.04/release/


参考3：《qemu 各CPU架构对应的 virt 机型的官方说明文档》
========================================================================================================
https://github.com/qemu/qemu/blob/master/docs/system/riscv/virt.rst
https://github.com/qemu/qemu/blob/master/docs/system/arm/virt.rst
https://www.qemu.org/docs/master/system/riscv/virt.html             这份比较详细，有 “Running Linux kernel”小节
https://www.qemu.org/docs/master/system/arm/virt.html

'

BUILD_KERNEL=1
BUILD_ROOTFS=1
SRC_CFG_FROM="-c1"

# echo "CPU架构仅支持 [riscv64|arm64|amd64]"
# echo "VHD格式仅支持 [raw|qcow2]"
export ARCH_COMP=amd64
export VER_KERNEL=linux-6.2
export VER_KERNEL=linux-6.6
export DIR_BUILD=$HOME/build_mylinux
export DIR_DOWNLD=${DIR_BUILD}/download
export DIR_OUTPUT=${DIR_BUILD}/output-${ARCH_COMP}
export DIR_ROOTFS=${DIR_OUTPUT}/rootfs-ubuntu
export IMG_ROOTFS=${DIR_OUTPUT}/virhd-${ARCH_COMP}.img
export IMG_KERNEL=${DIR_OUTPUT}/linux-${ARCH_COMP}
export TXT_README=${DIR_OUTPUT}/说明.txt
export VHDIMGSIZE=999M
export VHD_FORMAT=qcow2
# export DIR_SCRIPT=`dirname $0` # 这个不准确
export DIR_SCRIPT=$(dirname $(realpath $0))
export ARCH_HOST_=`uname -m`

# 用于存放 make modules 时生成的 "内核密相关模块"，在制作核心文件组(rootfs)时需要包入
export DIR_KNLMOD=${DIR_OUTPUT}/kernel-related/kernel_modules

# 用于存放 "内核密相关软件"，在制作核心文件组(rootfs)时需要包入
export DIR_KNLAPP=${DIR_OUTPUT}/kernel-related/kernel_userapp


function usage() {
    echo ""
    echo "《半小时，无痛体验一次自己编译并运行${VER_KERNEL}主线内核 ---- ${ARCH_COMP} 架构 qemu-virt机型》"
    echo "《半小时，无痛体验一次自己编译并运行${VER_KERNEL}主线内核 ---- ${ARCH_COMP} 架构 qemu-virt机型》">${TXT_README}
    echo ""
    echo "建议的两种编译环境："
    echo "========================================================================"
    echo "1).安装了ubuntu系统的x86架构电脑"
    echo "2).或者安卓手机上的虚拟电脑app(里面的linux是ubuntu环境)"
    echo ""

    echo "参数说明："
    echo "-k 不编译内核"
    echo "-r 不创建核心文件组(rootfs)"
    echo "-cm 手动配置内核源码"
    echo "-c0 使用 make defconfig 配置内核源码"
    echo "-c1 使用推荐的内核源码配置文件"
    echo "-c2 使用上次编译时使用的配置文件"
    exit -1
}

if [ $# -le 0 ]; then
    usage
fi

for arg in  $*
do
    if [ "$arg" == "-h" ]; then
        usage
    elif [ "$arg" == "-k" ]; then
        BUILD_KERNEL=0
    elif [ "$arg" == "-r" ]; then
        BUILD_ROOTFS=0
    elif [ "$arg" == "-cm" ]; then
        SRC_CFG_FROM="-cm"
    elif [ "$arg" == "-c0" ]; then
        SRC_CFG_FROM="-c0"
    elif [ "$arg" == "-c1" ]; then
        SRC_CFG_FROM="-c1"
    elif [ "$arg" == "-c2" ]; then
        SRC_CFG_FROM="-c2"
    else
        echo "程序无法识别此参数：$arg"
        echo ""
        usage
    fi
done
export SRC_CFG_FROM


echo "工作目录：${DIR_BUILD}"
echo ""

if [ "${ARCH_COMP}" == "riscv64" ]; then
    export LINUX_ARCH=riscv
    export GCC_PKG=gcc-riscv64-linux-gnu
    export CROSS_COMPILE=riscv64-linux-gnu-
    export QEMU_PKG=qemu-system-misc
    export QEMU_APP=qemu-system-riscv64
    export QEMU_EXE=qemu-riscv64-static
elif [ "${ARCH_COMP}" == "arm64" ]; then
    export LINUX_ARCH=arm64
    export GCC_PKG=gcc-aarch64-linux-gnu
    export CROSS_COMPILE=aarch64-linux-gnu-
    export QEMU_PKG=qemu-system-arm
    export QEMU_APP=qemu-system-aarch64
    export QEMU_EXE=qemu-aarch64-static
elif [ "${ARCH_COMP}" == "amd64" ]; then
    export LINUX_ARCH=x86_64
    export GCC_PKG=gcc-x86-64-linux-gnu
    export CROSS_COMPILE=x86_64-linux-gnu-
    export QEMU_PKG=qemu-system-x86
    export QEMU_APP=qemu-system-x86_64
    export QEMU_EXE=qemu-x86_64-static

    if [ "${ARCH_HOST_}" == "x86_64" ]; then
        export GCC_PKG=gcc
        export CROSS_COMPILE=
    fi
else
    echo "仅支持 [riscv64|arm64|amd64] 三种CPU架构"
    read -s -n1 -p "按任意键退出"
    exit -1
fi

if [ $BUILD_KERNEL -ne 0 ]; then
    SUCC_MSG_KERNEL="内核编译完成"
    echo "1/3，正在调用编译内核的脚本代码"
    ${DIR_SCRIPT}/mkkernel.sh
    if [ $? -ne 0 ]; then
        echo "linux 内核编译失败！"
        read -s -n1 -p "按任意键退出"
        exit -1
    fi
fi

if [ $BUILD_ROOTFS -ne 0 ]; then
    SUCC_MSG_ROOTFS="rootfs(核心文件组)制作完成"
    echo "2/3，正在调用制作rootfs(核心文件组)的脚本代码"
    ${DIR_SCRIPT}/mkrootfs.sh
    if [ $? -ne 0 ]; then
        echo "linux 核心文件组制作失败！(rootfs)"
        read -s -n1 -p "按任意键退出"
        exit -1
    fi
fi

# 显示编译结果，即生成的说明.txt
if [ 1 -eq 1 ]; then
    LINUX_NOTEPAD=
    which notepad >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        LINUX_NOTEPAD=notepad
    fi
    which gedit >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        LINUX_NOTEPAD=gedit
    fi
    if [ "${LINUX_NOTEPAD}" != "" ]; then 
        ${LINUX_NOTEPAD} ${TXT_README} 2>&1 > /dev/null &
    fi
fi



function startQemu_riscv64() {
    # riscv64 的efi:
    # =============================================================================
    # sudo apt install u-boot-qemu opensbi

    # 装好后相关文件的路径：
    #     -bios   /usr/lib/riscv64-linux-gnu/opensbi/generic/fw_jump.elf \
    #     -kernel /usr/lib/u-boot/qemu-riscv64_smode/uboot.elf \

    ${QEMU_APP} \
        -nographic -machine virt \
        -smp 4 \
        -m 1G \
        -kernel ${IMG_KERNEL} \
        -drive file=${IMG_ROOTFS},if=none,format=${VHD_FORMAT},id=hd0 \
        -object rng-random,filename=/dev/urandom,id=rng0 \
        -device virtio-vga \
        -device virtio-rng-device,rng=rng0 \
        -device virtio-blk-device,drive=hd0 \
        -device virtio-net-device,netdev=usernet \
        -netdev user,id=usernet \
        -append "ip=dhcp root=/dev/vda rw loglevel=8 init=/zzinit" \
        -virtfs local,path=/mnt/shared,mount_tag=hostdir,security_model=mapped,fmode='0777',dmode='0777',id=hostdir
}

function startQemu_arm64() {
    # aarch64 的efi: 
    # =============================================================================
    # sudo apt-get install qemu-system-arm qemu-efi
    # -pflash /usr/share/AAVMF/AAVMF_CODE.fd
    ${QEMU_APP} \
        -nographic -machine virt \
        -cpu cortex-a53 \
        -smp 4 \
        -m 1G \
        -kernel ${IMG_KERNEL} \
        -drive file=${IMG_ROOTFS},if=none,format=${VHD_FORMAT},id=hd0 \
        -object rng-random,filename=/dev/urandom,id=rng0 \
        -device virtio-vga \
        -device virtio-rng-device,rng=rng0 \
        -device virtio-blk-device,drive=hd0 \
        -device virtio-net-device,netdev=usernet \
        -netdev user,id=usernet \
        -append "ip=dhcp root=/dev/vda rw loglevel=8 init=/zzinit" \
        -virtfs local,path=/mnt/shared,mount_tag=hostdir,security_model=mapped,fmode='0777',dmode='0777',id=hostdir
}

function startQemu_amd64() {
    # x86_64的efi: 
    # =============================================================================
    # sudo apt -y install ovmf
    # https://techoverflow.net/2019/05/05/how-to-use-qemu-with-uefi-on-ubuntu/

    # # 注意不要加  -display none  或者 -nographic !!!!!!!!!， 和 -serial stdio 不能一起用？
    # ${QEMU_APP} \
    #     -serial stdio \
    #     -smp 1 \
    #     -m 1G \
    #     -kernel ${IMG_KERNEL} \
    #     -hda ${IMG_ROOTFS} \
    #     -netdev user,id=usernet,hostfwd=tcp::8080-:80 \
    #     -device e1000,netdev=usernet \
    #     -append "ip=dhcp root=/dev/sda rw loglevel=8 init=/zzinit  console=ttyS0" \
    #     -virtfs local,path=/mnt/shared,mount_tag=hostdir,security_model=mapped,fmode='0777',dmode='0777',id=hostdir

    # # 注意不要加  -display none  或者 -nographic !!!!!!!!!， 和 -serial stdio， console=ttyS0 不能一起用？
    # ${QEMU_APP} \
    #     -serial stdio \
    #     -smp 1 \
    #     -m 1G \
    #     -kernel ${IMG_KERNEL} \
    #     -drive if=virtio,file=${IMG_ROOTFS},format=${VHD_FORMAT},cache=none \
    #     -netdev user,id=mynet0,net=192.168.76.0/24,dhcpstart=192.168.76.9 -device rtl8139,netdev=mynet0 \
    #     -netdev user,id=usernet,hostfwd=tcp::8080-:80 \
    #     -device e1000,netdev=usernet \
    #     -append "ip=dhcp root=/dev/vda rw loglevel=8 init=/zzinit console=ttyS0" \
    #     -virtfs local,path=/mnt/shared,mount_tag=hostdir,security_model=mapped,fmode='0777',dmode='0777',id=hostdir \
    #     -device qemu-xhci -usb -device usb-kbd -device usb-tablet

    # CTRL+A, + X 结束运行
    # 注意不要加  -display none  或者 -nographic !!!!!!!!!， 和 -serial stdio， console=ttyS0 不能一起用？
    ${QEMU_APP} \
        -nographic \
        -smp 1 \
        -m 1G \
        -kernel ${IMG_KERNEL} \
        -drive if=virtio,file=${IMG_ROOTFS},format=${VHD_FORMAT},cache=none \
        -netdev user,id=mynet0,net=192.168.76.0/24,dhcpstart=192.168.76.9 -device rtl8139,netdev=mynet0 \
        -netdev user,id=usernet,hostfwd=tcp::8080-:80 \
        -device e1000,netdev=usernet \
        -append "ip=dhcp root=/dev/vda rw loglevel=8 init=/zzinit console=ttyS0" \
        -virtfs local,path=/mnt/shared,mount_tag=hostdir,security_model=mapped,fmode='0777',dmode='0777',id=hostdir \
        -device qemu-xhci -usb -device usb-kbd -device usb-tablet
}

function startQemu() {
    # read -t 180     -p "是否启动 qemu? 请选择 [Y/n]"   readrlt
    # read -t 180 -n1 -p "是否启动 qemu? 请选择 [Y/n]"   readrlt
    read -t 180     -p "是否启动 qemu? 请选择 [Y/n]"   readrlt
    echo ""
    if [ "${readrlt}" != "" ] && [  "${readrlt}" != "Y" ] && [  "${readrlt}" != "y" ]; then
        return
    fi

    if [ ! -f ${IMG_KERNEL} ]; then
        echo "无法启动qemu, 文件不存在：${IMG_KERNEL}"
        return
    fi

    if [ ! -f ${IMG_ROOTFS} ]; then
        echo "无法启动qemu, 文件不存在：${IMG_ROOTFS}"
        return
    fi

    echo "3/3，正在启动qemu虚拟机，将加载前两步生成的文件"

    sudo mkdir -p   /mnt/shared
    sudo chmod 777  /mnt/shared

    startQemu_${ARCH_COMP}

    # 共享目录
    # 在主机上启动qemu时加参数
    # sudo mkdir -p   /mnt/shared
    # sudo chmod 777  /mnt/shared
    #   -virtfs local,path=/mnt/shared,mount_tag=hostdir,security_model=mapped,fmode='0777',dmode='0777',id=hostdir "

    # 在虚拟系统中挂载共享目录
    # sudo mkdir -p /mnt/shared
    # sudo mount -t 9p -o trans=virtio,version=9p2000.L hostdir /mnt/shared
    # mkdir -p /mnt/shared
    # mount -t 9p -o trans=virtio,version=9p2000.L hostdir /mnt/shared
}



if [ "${SUCC_MSG_KERNEL}" != "" ]; then echo "==> ${SUCC_MSG_KERNEL}"; fi
if [ "${SUCC_MSG_ROOTFS}" != "" ]; then echo "==> ${SUCC_MSG_ROOTFS}"; fi
echo "编译结束，请查看此目录："
echo "${DIR_OUTPUT}"
echo ""

startQemu
