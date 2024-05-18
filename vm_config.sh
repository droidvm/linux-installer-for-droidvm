######## !/bin/bash

##################################
## https://releases.ubuntu.com/ ##
##################################


# # FOR DEBUG
# echo "CONSOLE_ENV: $CONSOLE_ENV"
# echo "  1app_home: $app_home"

if [ "$CONSOLE_ENV" == "android" ]; then
	source ${app_home}/droidvm_vars.sh
	source ${app_home}/droidvm_vars_setup.sh

    export tools_dir=$app_home/tools
    # export PATH=$PATH:$app_home:$app_home/tools

    export LINUX_FAKE_PROC_DIR=${tools_dir}/fake_proc
    # export LINUX_LOGIN_COMMAND='/bin/bash --login'
    export LINUX_LOGIN_COMMAND='/exbin/tools/vm_init.sh'
    # export LINUX_LOGIN_COMMAND='/exbin/tools/vm.sh'

    export HOST_CPU_ARCH=`get_std_arch`


else
    export app_home=/exbin
    export tools_dir=$app_home/tools
	source ${app_home}/droidvm_vars.sh
	source ${app_home}/droidvm_vars_setup.sh

    export PULSE_SERVER=tcp:127.0.0.1:4713

    # 虚拟系统内的运行时环境变量
    if [ -r /etc/autoruns/vm_runtime_env.sh ]; then
        . /etc/autoruns/vm_runtime_env.sh
    fi

    # # 已在 vm_startx.sh 中的 setup_theme 函数内处理!
    # =================================================
	# GTK_THEME=`cat ${PATH_GTK_THEME_NAME}`
	# if [ "${GTK_THEME}" == "" ]; then
	# 	GTK_THEME="Adwaita"
	# fi
	# export GTK_THEME

    # 虚拟系统内安装的软件的环境变量，比如JAVA_HOME
    if [ -r /etc/autoruns/installed_sw_env.sh ]; then
        . /etc/autoruns/installed_sw_env.sh
    fi

    export ZZEXE_VERBOSE_ON=1
    export DirGuiConf=~/.droidvm
    export DirBakConf=/etc/droidvm/def_xconf
    export PATHUIMODE=${DirGuiConf}/uimode.txt
    export PATH_VMDPI=${DirGuiConf}/vm_dpi.txt
    export PATH_VmColorscheme=${app_home}/app_boot_config/vm_color_scheme.txt
    export PATH_GTK_THEME_NAME=/etc/droidvm/gtktheme.txt


    # # lxterminal patch
    # if [ -d /etc/profile.d ]; then
    #     # ls -al /etc/profile.d
    #     echo "/etc/profile.d 加载中..."
    #     for i in /etc/profile.d/*.sh; do
    #         if [ -r $i ]; then
    #             # echo "/etc/profile.d/$i"
    #             . $i
    #         fi
    #     done
    #     unset i
    # fi

fi

source ${APP_FILENAME_URLDLSERVER}

case "${vmDistribution}" in
    "3")
        export LINUX_DISTRIBUTION=deepin
        export LINUX_ROOTFS_VER=4.0.2
        export LINUXVersionName=pd
        # export FILE_NAME_EX_NDK_TOOLS=ex_ndk_tools-1.26.zip
        ;;
    "2")
        export LINUX_DISTRIBUTION=debian
        export LINUX_ROOTFS_VER=12.04
        export LINUXVersionName=bookworm
        # export FILE_NAME_EX_NDK_TOOLS=ex_ndk_tools-1.26.zip
        ;;
    "1" | *)
        ## 无声音
        # export LINUX_ROOTFS_VER=22.04.3
        # export LINUXVersionName=jammy
        # export FILE_NAME_EX_NDK_TOOLS=ex_ndk_tools-1.08.zip

        # export LINUX_ROOTFS_VER=22.10
        # export LINUXVersionName=kinetic
        # export FILE_NAME_EX_NDK_TOOLS=ex_ndk_tools-1.08.zip

        # export LINUX_ROOTFS_VER=23.04
        # export LINUXVersionName=lunar
        # export FILE_NAME_EX_NDK_TOOLS=ex_ndk_tools-1.08.zip

        export LINUX_DISTRIBUTION=ubuntu
        export LINUX_ROOTFS_VER=23.10
        export LINUXVersionName=mantic
        # export FILE_NAME_EX_NDK_TOOLS=ex_ndk_tools-1.26.zip
        ;;
esac
export FILE_NAME_EX_NDK_TOOLS=ex_ndk_tools-1.31.zip

case "${vmCpuArchId}" in
    "1")
        export CURRENT_VM_ARCH="amd64"
        export CURRENT_OS_NAME="${LINUX_DISTRIBUTION}-${CURRENT_VM_ARCH}"
        ;;
    *)
        export CURRENT_VM_ARCH="arm64"
        export CURRENT_OS_NAME="${LINUX_DISTRIBUTION}-${CURRENT_VM_ARCH}"
        ;;
esac

if [ "$CONSOLE_ENV" == "android" ]; then
	# export LINUX_DIR="${files_dir}/vm/${CURRENT_OS_NAME}"
	if [ -d "${files_dir}/exbin" ]; then
		export LINUX_DIR="../../vm/${CURRENT_OS_NAME}"
	else
		export LINUX_DIR="../vm/${CURRENT_OS_NAME}"
	fi

    # PROOT_VERBOSE 值越大，proot 输出的信息越多
    # export PROOT_VERBOSE=1

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
    export PROOT_USER_BINFMT_DIR=/etc/binfmt.d

    export TMPDIR=$PROOT_TMP_DIR
fi

# # FOR DEBUG
# echo "CONSOLE_ENV: $CONSOLE_ENV"
# echo "   app_home: $app_home"

if [[ $PATH != *$app_home* ]]
then
    export PATH=$PATH:$app_home
fi

if [[ $PATH != *$tools_dir* ]]
then
    export PATH=$PATH:$app_home/tools
fi

function echo2apk() {
        echo $1
        echo $1>$NOTIFY_PIPE
}

export ANDROID_ART_ROOT=/apex/com.android.art
export ANDROID_DATA=/data
export ANDROID_I18N_ROOT=/apex/com.android.i18n
export ANDROID_ROOT=/system
export ANDROID_TZDATA_ROOT=/apex/com.android.tzdata
export X_DAEMON_PIPE=${app_home}/ipc/zzXio
