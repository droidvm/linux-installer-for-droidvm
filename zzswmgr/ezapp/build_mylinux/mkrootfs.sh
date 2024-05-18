#!/bin/bash

function exit_if_fail() {
    rlt_code=$1
    fail_msg=$2
    if [ $rlt_code -ne 0 ]; then
      echo -e "错误码: ${rlt_code}\n${fail_msg}"
      # read -s -n1 -p "按任意键退出"
      exit $rlt_code
    fi
}

SW_SOURCE_X86="
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse

deb http://security.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse
# deb-src http://security.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse

# 预发布软件源，不建议启用
# deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-proposed main restricted universe multiverse
# # deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-proposed main restricted universe multiverse
"
SW_SOURCE_PORTS="
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ jammy main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ jammy main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ jammy-updates main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ jammy-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ jammy-backports main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ jammy-backports main restricted universe multiverse

deb http://ports.ubuntu.com/ubuntu-ports/ jammy-security main restricted universe multiverse
# deb-src http://ports.ubuntu.com/ubuntu-ports/ jammy-security main restricted universe multiverse

# 预发布软件源，不建议启用
# deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ jammy-proposed main restricted universe multiverse
# # deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ jammy-proposed main restricted universe multiverse
"

VM_STATIC_DNS="
# IPv4. add by droidvm

127.0.0.1       zzvm

180.76.198.77	gitee.com
180.76.198.77	foruda.gitee.com
39.155.141.16	mirrors.bfsu.edu.cn
218.104.71.170	mirrors.ustc.edu.cn
101.6.15.130	mirrors.tuna.tsinghua.edu.cn
185.125.190.36	ports.ubuntu.com
185.125.190.39	ports.ubuntu.com
91.189.91.82	security.ubuntu.com
91.189.91.81	security.ubuntu.com
185.125.190.36	security.ubuntu.com
185.125.190.39	security.ubuntu.com
91.189.91.83	security.ubuntu.com

# IPv6. add by droidvm
2402:f000:1:400::2				pypi.tuna.tsinghua.edu.cn
2620:2d:4000:1::16              archive.ubuntu.com
# 2409:8700:2482:710::fe55:2840 mirrors.bfsu.edu.cn
# 2001:da8:d800:95::110         mirrors.ustc.edu.cn
# 2402:f000:1:400::2            mirrors.tuna.tsinghua.edu.cn
# 2620:2d:4000:1::16            ports.ubuntu.com
# 2620:2d:4000:1::19            security.ubuntu.com
"

VM_NAMESERVER="
nameserver 8.8.8.8
nameserver 223.5.5.5
nameserver 223.6.6.6
nameserver 2400:3200::1
nameserver 2400:3200:baba::1
nameserver 114.114.114.114
nameserver 114.114.115.115
nameserver 240c::6666
nameserver 240c::6644

options single-request-reopen
options timeout:2
options attempts:3
options rotate
options use-vc      # 走TCP
"


mkdir -p ${DIR_DOWNLD} 2>/dev/null
mkdir -p ${DIR_OUTPUT} 2>/dev/null
cd ${DIR_BUILD}



sudo apt install -y ${QEMU_PKG} qemu-user-static binfmt-support

function create_vm_script() {
    TMP_LOCAL_FILE_CODE=$1
    TMP_LOCAL_FILE_NAME=$2
    sudo echo "${TMP_LOCAL_FILE_CODE}" > $TMP_LOCAL_FILE_NAME
    sudo chmod 755                       $TMP_LOCAL_FILE_NAME
}

function compile_genimage() {
    echo "正在编译 genimage"
    sudo apt install gcc autoconf automake libtool libconfuse-dev genext2fs
    git clone https://gitee.com/yelam2022/genimage
    cd genimage
    ./autogen.sh
    ./configure
    sudo make -j4 install
    genimage -h
}

function mount_to_chroot() {
    echo ""
    echo "正在尝试在编译机端挂载临时核心文件组"
    # sudo mount ${IMG_ROOTFS} ${DIR_ROOTFS}
    sudo mount -t proc /proc ${DIR_ROOTFS}/proc
    sudo mount -t sysfs /sys ${DIR_ROOTFS}/sys
    sudo mount -o bind /dev ${DIR_ROOTFS}/dev
    sudo mount -o bind /dev/pts ${DIR_ROOTFS}/dev/pts
}

function unmount() {
    echo "正在脱离"
    sudo umount ${DIR_ROOTFS}/proc
    sudo umount ${DIR_ROOTFS}/sys
    sudo umount ${DIR_ROOTFS}/dev/pts
    sudo umount ${DIR_ROOTFS}/dev
    # sudo umount ${DIR_ROOTFS}
}

function do_chroot() {

    echo "准备chroot进入临时根目录，当出现shell提示符时，你可以给正在创建的rootfs安装软件, exit 退出"

    if [ "${ARCH_COMP}" == "arm64" ]; then
        sudo update-binfmts --display qemu-aarch64
        sudo update-binfmts --enable  qemu-aarch64
        sudo update-binfmts --display qemu-aarch64
    fi

    if [ "${ARCH_COMP}" == "riscv64" ]; then
        sudo update-binfmts --display qemu-riscv64
        sudo update-binfmts --enable  qemu-riscv64
        sudo update-binfmts --display qemu-riscv64
    fi

    echo ""
    echo "  是否需要现在就往核心文件组(rootfs)中安装软件？"
    echo "========================================================================"
    echo "  如需安装，请执行 /mycode，即在编译机端生成的自动化脚本"
    echo "  如不安装，或者安装已经完成，请执行 exit 继续打包核心文件组(rootfs)"
    echo "========================================================================"
    echo ""
    sudo chroot ${DIR_ROOTFS}
}


function edit_temp_rootfs() {
    sudo cp -f /usr/bin/${QEMU_EXE} ${DIR_ROOTFS}/usr/bin/

    if [ -d ${DIR_KNLMOD} ]; then
        echo ""                                       >>${TXT_README}
        echo "正在复制 内核密相关模块(在编译内核模块时生成)" >>${TXT_README}
        echo "正在复制 内核密相关模块(在编译内核模块时生成)"
        sudo cp -R ${DIR_KNLMOD}/* ${DIR_ROOTFS}/usr/
        exit_if_fail $? "内核密相关模块 复制失败"
    fi

    if [ -d ${DIR_KNLAPP} ]; then
        echo ""                                       >>${TXT_README}
        echo "正在复制 内核密相关软件(在编译内核软件时生成)" >>${TXT_README}
        echo "正在复制 内核密相关软件(在编译内核软件时生成)"
        sudo cp -R ${DIR_KNLAPP}/* ${DIR_ROOTFS}/usr/
        exit_if_fail $? "内核密相关软件 复制失败"
    fi

    # sudo mkdir -p                    ${DIR_ROOTFS}/etc/apt/sources.list.d
    # sudo chmod 777                   ${DIR_ROOTFS}/etc/apt/sources.list.d
    # sudo touch                       ${DIR_ROOTFS}/etc/apt/sources.list.d/cnrepo.list
    # sudo chmod 777                   ${DIR_ROOTFS}/etc/apt/sources.list.d/cnrepo.list
    # sudo ls -al                      ${DIR_ROOTFS}/etc/apt/
    # sudo ls -al                      ${DIR_ROOTFS}/etc/apt/sources.list.d/cnrepo.list
    sudo chmod 777                   ${DIR_ROOTFS}/etc/apt
    sudo echo "${SW_SOURCE_X86}"   > ${DIR_ROOTFS}/etc/apt/sources.list.cn.amd64
    sudo echo "${SW_SOURCE_PORTS}" > ${DIR_ROOTFS}/etc/apt/sources.list.cn.arm64
    sudo echo "${SW_SOURCE_PORTS}" > ${DIR_ROOTFS}/etc/apt/sources.list.cn.riscv64
    exit_if_fail $? "软件下载仓库地址 修改失败"
    sudo chmod 755                   ${DIR_ROOTFS}/etc/apt

    sudo chmod 666 ${DIR_ROOTFS}/etc/hostname
    echo "zzvm" >  ${DIR_ROOTFS}/etc/hostname
    exit_if_fail $? "hostname 修改失败"

    sudo chmod 666            ${DIR_ROOTFS}/etc/hosts
    echo "${VM_STATIC_DNS}" > ${DIR_ROOTFS}/etc/hosts
    exit_if_fail $? "静态域名解析文件 修改失败"

    # sudo cp -f /etc/resolv.conf ${DIR_ROOTFS}/etc/
    # exit_if_fail $? "DNS服务器 修改失败"
    # sudo chmod 666                      ${DIR_ROOTFS}/etc/resolv.conf
    # sudo echo "nameserver 192.168.1.1" >${DIR_ROOTFS}/etc/resolv.conf
    
    sudo chmod 666                      ${DIR_ROOTFS}/etc/resolv.conf
    sudo echo "${VM_NAMESERVER}"       >${DIR_ROOTFS}/etc/resolv.conf
    exit_if_fail $? "DNS服务器 修改失败"

    tmpdata="#!/bin/bash

    function exit_if_fail() {
        rlt_code=\$1
        fail_msg=\$2
        if [ \$rlt_code -ne 0 ]; then
        echo -e \"错误码: \${rlt_code}\\n\${fail_msg}\"
        # read -s -n1 -p "按任意键退出"
        exit \$rlt_code
        fi
    }

    echo \"正在将常见根证书添加到系统可信证书列表\"
    apt update
    apt install -y ca-certificates
    exit_if_fail \$? \"常用ca根证书安装失败\"

    cp -f /etc/apt/sources.list    /etc/apt/sources.list.ubuntu
    exit_if_fail \$? \"软件仓库切换失败\"
    cp -f /etc/apt/sources.list.cn.${ARCH_COMP} /etc/apt/sources.list
    exit_if_fail \$? \"软件仓库切换失败\"
    echo \"apt软件仓库已切换为国内仓库\"

    apt update
    exit_if_fail \$? \"仓库切换后，获取软件列表失败\"

    # apt install -y udev usbutils usb.ids android-tools-adb net-tools pciutils wget x11-apps
    apt install -y udev usbutils wget
    exit_if_fail \$? \"软件安装失败\"


    mkdir -p /usr/share/hwdata 2>/dev/null
    ln -sf /var/lib/usbutils/usb.ids /usr/share/hwdata/usb.ids

    # udevadm monitor --env


    # apt install -y kmod wget net-tools inetutils-ping usbutils linux-tools-common linux-tools-6.2.0-37-generic linux-cloud-tools-6.2.0-37-generic

    # udev                  #udevadm
    # kmod                  #内核模块操作指令，如 insmod, lsmod, modprobe
    # command-not-found     #输入未安装的指令时，会提示指令所在的软件包名
    # usbutils usb.ids      #lsusb
    # pciutils              #lspci
    # kmod                  #modprobe
    # linux-tools-common linux-tools-6.2.0-37-generic linux-cloud-tools-6.2.0-37-generic    #usbip
    # x11-apps              #一些x11程序示例，比如 xclock
    # usb.ids               #/var/lib/usbutils/usb.ids
    # android-tools-adb     #adb

    # apt 安装的同时显示下载链接
    # apt-get install --print-uris -y ca-certificates


    # # 复制编译内核时生成的 "内核密相关模块"
    # cp -f  /lib/modules/6.2.0/kernel/drivers/usb/usbip/*.ko  /lib/modules/
    # cp -f  /lib/modules/6.2.0/kernel/drivers/usb/serial/*.ko /lib/modules/

    # # usbip内核模块
    # modprobe usbip-core
    # modprobe vhci-hcd
    # modprobe usbip_host

    # # usb转串口的驱动(内核模块的)
    # modprobe ch341



    apt-get clean
    "
    sudo echo "${tmpdata}" > ${DIR_ROOTFS}/zz_setupsw
    sudo chmod 755           ${DIR_ROOTFS}/zz_setupsw

    vmlinux_init="#!/bin/bash
    echo \"当前脚本: \$0\"
    ls -al \$0
    echo \"\"
    echo \"欢迎使用小型qemu-linux\"
    echo \"结合虚拟电脑app，您可以在qemu中通过usbip指令访问安卓端usb设备\"
    echo \"\"
    echo \"  内核版本：主线linux-6.6，用build_mylinux脚本编译\"
    echo \"核心文件组：基于ubuntu-base-rootfs创建，可以使用apt指令安装软件\"
    echo \"如需将apt软件仓库换成国内的，请运行: /zz_setupsw\"
    echo \"\"

    function exit_if_fail() {
        rlt_code=\$1
        fail_msg=\$2
        if [ \$rlt_code -ne 0 ]; then
        echo -e \"错误码: \${rlt_code}\\n\${fail_msg}\"
        # read -s -n1 -p "按任意键退出"
        exit \$rlt_code
        fi
    }


    export HOME=/root
    export TERM=xterm-color
    export HOSTNAME=\`cat /etc/hostname\`
    hostname \$HOSTNAME
    # export PS1='"'\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '"'

    mount -t proc proc /proc
    exit_if_fail \$? \"/proc 目录挂载失败\"

    mount -t sysfs none /sys
    exit_if_fail \$? \"/sys 目录挂载失败\"

    # 挂载qemu共享目录
    mkdir -p /mnt/shared
    mount -t 9p -o trans=virtio,version=9p2000.L hostdir /mnt/shared
    if [ \$? -eq 0 ]; then
        echo \"共享目录 /mnt/shared 已挂载\"

        if [ -x /mnt/shared/autorun.sh ]; then
            echo \"正在调用 /mnt/shared/autorun.sh\"
            /mnt/shared/autorun.sh

            if [ -f /mnt/shared/autorun.rlt ]; then
                . /mnt/shared/autorun.rlt
            fi

            if [ \"\$AUTO_POWEROFF\" != \"\" ]; then
                exit
            fi
        else
            echo \"无法调用 /mnt/shared/autorun.sh => 启动 /bin/bash\"
        fi
    fi

    echo \"\"
    exec /bin/bash

    "
    create_vm_script "${vmlinux_init}" ${DIR_ROOTFS}/zzinit
    exit_if_fail $? "init 脚本创建失败"

    tmpdata="
export PS1='"'\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '"'
    "
    create_vm_script "${tmpdata}" ${DIR_ROOTFS}/zz_setupPS1
    exit_if_fail $? "tmp_ps1 脚本创建失败"





    mount_to_chroot
    if [ $? -eq 0 ]; then
        sudo cp -f /usr/bin/${QEMU_EXE} ${DIR_ROOTFS}/usr/bin/
        do_chroot
        unmount
    else
        echo "当前系统下您没有权限执行挂载的操作"
    fi

    # usbip client app
    if [ -f ${DIR_BUILD}/${VER_KERNEL}/tools/usb/usbip/libsrc/.libs/libusbip.so ]; then
        sudo cp -f ${DIR_BUILD}/${VER_KERNEL}/tools/usb/usbip/libsrc/.libs/libusbip.so ${DIR_ROOTFS}/usr/local/lib/
    fi
    if [ -f ${DIR_BUILD}/${VER_KERNEL}/tools/usb/usbip/src/usbip ]; then
        sudo cp -f ${DIR_BUILD}/${VER_KERNEL}/tools/usb/usbip/src/usbip                ${DIR_ROOTFS}/usr/bin/
        sudo chmod 777 ${DIR_ROOTFS}/usr/bin/usbip
    fi

    echo "rootfs修改完成"
    # echo "如需深度修改rootfs，请在真正有root权限的系统上使用 chroot/fakechroot 和 qemu-user-static"
}


FIL_UBUNTU_BASE_ROOTFS=ubuntu-base-22.04.3-base-${ARCH_COMP}.tar.gz
ZIP_UBUNTU_BASE_ROOTFS=${DIR_DOWNLD}/${FIL_UBUNTU_BASE_ROOTFS}
URL_UBUNTU_BASE_ROOTFS=https://mirrors.aliyun.com/ubuntu-cdimage/ubuntu-base/releases/22.04/release/${FIL_UBUNTU_BASE_ROOTFS}
URL_UBUNTU_BASE_ROOTFS=https://mirror.tuna.tsinghua.edu.cn/ubuntu-cdimage/ubuntu-base/releases/jammy/release/${FIL_UBUNTU_BASE_ROOTFS}


if [ ! -f ${ZIP_UBUNTU_BASE_ROOTFS} ]; then
    echo "正在下载 ubuntu-base-rootfs"
    wget ${URL_UBUNTU_BASE_ROOTFS} -O ${ZIP_UBUNTU_BASE_ROOTFS}
    exit_if_fail $? "ubuntu-base-rootfs 下载失败"

    filesize=`ls -l ${ZIP_UBUNTU_BASE_ROOTFS} | awk '{print $5}'`
    if [ ${filesize} -lt 1024 ]; then
        echo "ubuntu-base-rootfs 下载失败"
        rm -rf ${ZIP_UBUNTU_BASE_ROOTFS}
        exit -1;
    fi
fi


echo ""                                                     >>${TXT_README}
echo "正在制作与内核配套的核心文件组(rootfs)，目录：${DIR_ROOTFS}">>${TXT_README}
echo "正在解压 ubuntu-base-rootfs"                           >>${TXT_README}
echo "正在解压 ubuntu-base-rootfs"
unmount
sudo rm -rf    ${DIR_ROOTFS}
exit_if_fail $? "无法删除旧目录: ${DIR_ROOTFS}"
echo "mkdir -p ${DIR_ROOTFS}"
mkdir -p       ${DIR_ROOTFS} 2>/dev/null
exit_if_fail $? "无法创建临时目录: ${DIR_ROOTFS}"
sudo tar -xzf ${ZIP_UBUNTU_BASE_ROOTFS} -C ${DIR_ROOTFS}
exit_if_fail $? "ubuntu-base-rootfs 解压失败"


echo "正在修改rootfs"
edit_temp_rootfs

echo ""
echo "正在将rootfs打包成虚拟硬盘镜像(默认大小：${VHDIMGSIZE}) ${IMG_ROOTFS}"
echo "如需在没有真正root权限的环境下创建包含多个分区的虚拟硬盘镜像，可以使用 genimage 这个工具"
qemu-img create  -f raw  ${IMG_ROOTFS} ${VHDIMGSIZE}
sudo mkfs.ext4   -d ${DIR_ROOTFS}  -L rootfs ${IMG_ROOTFS}

if [ "${VHD_FORMAT}" == "qcow2" ]; then
    echo ""
    echo "正在将 raw 格式的镜像转换成 qcow2 格式"
    qemu-img convert -f raw ${IMG_ROOTFS} -O qcow2 ${IMG_ROOTFS}.qcow2
    exit_if_fail $? "虚拟硬盘镜像格式转换失败"

    rm -rf ${IMG_ROOTFS}
    mv -f ${IMG_ROOTFS}.qcow2 ${IMG_ROOTFS}
    exit_if_fail $? "虚拟硬盘镜像格式转换失败"
fi

echo ""                                     >>${TXT_README}
echo "核心文件组制作完成： ${DIR_ROOTFS}"   >>${TXT_README}
echo "已经打包成硬盘镜像： ${IMG_ROOTFS}"   >>${TXT_README}
echo ""                                     >>${TXT_README}

echo ""
echo "创建的虚拟硬盘镜像的信息如下："
qemu-img info ${IMG_ROOTFS}

echo ""
echo "如需对虚拟硬盘进行扩容，请执行："
echo "qemu-img resize ${IMG_ROOTFS}  +1G"
echo ""
