#!/system/bin/sh

export tools_dir=${app_home}/tools

. ${tools_dir}/vm_config.sh

if [ -f ${app_home}/app_boot_config/cfg_proot_name.txt ]; then
    prootdirname=`cat ${app_home}/app_boot_config/cfg_proot_name.txt`
    export PROOT_BINARY_DIR=${tools_dir}/ndkproot/${prootdirname}/${HOST_CPU_ARCH}
else
    export PROOT_BINARY_DIR=${tools_dir}/ndkproot/proot-userbinfmt/${HOST_CPU_ARCH}
    # export PROOT_BINARY_DIR=${tools_dir}/ndkproot/proot-userland-box86/${HOST_CPU_ARCH}
    # export PROOT_BINARY_DIR=${tools_dir}/ndkproot/proot-termux-box86/${HOST_CPU_ARCH}
fi

export PROOT_LOADER=${PROOT_BINARY_DIR}/loader/loader
export PROOT_LOADER_32=${PROOT_BINARY_DIR}/loader/loader32
export PROOT_TMP_DIR=${tools_dir}/tmp
export PROOT_HOST_ABIS=`/system/bin/getprop ro.product.cpu.abilist`
# export PROOT_USER_BINFMT_DIR=/etc/binfmt.d


export PATH=$PATH:$PROOT_BINARY_DIR
