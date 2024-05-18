#!/system/bin/sh


source vm_config.sh
source ${app_home}/droidvm_vars_setup.sh
HOST_CPU_ARCH=`get_std_arch`


#################################################################################
# if [ $SCRIPT_DEBUG -eq 1 ]; then
# 	echo2apk "正在启动 android telnetd, port: 5555"
# 	# echo "IP:"
# 	# busybox ifconfig|grep 'inet '
# 	ndkdumpip
# 	busybox telnetd -p 5555 -l /system/bin/sh &
# 	# exit 0
# fi



#################################################################################
echo2apk "正在生成 fake_proc"
. ./setup_fake_proc.sh
# mkdir -p  "${LINUX_FAKE_PROC_DIR}"
# chmod 700 "${LINUX_FAKE_PROC_DIR}"
# busybox unzip -o ${app_home}/vm-fake-proc.zip -d ${LINUX_FAKE_PROC_DIR}




# ==============================================
# virgl_srv打包(cd到/exbin/virglrenderer-android/)：
# tar -czvf ../virglrenderer-android.tar.gz  .
# ==============================================

function start_virgl_srv() {
    # echo onetime>>v.txt
    # mkdir ./virglrenderer-android/
    # tar -xzvf misc/virglrenderer-android.tar.gz -C ./virglrenderer-android/
    # chmod a+x ./virglrenderer-android/bin/*
    chmod a+x ${tools_dir}/virglrenderer-android/bin/*
    
    # # ./virglrenderer-android/bin/virgl_srv --use-egl-surfaceless --use-gles 2>&1 &
    # # ${tools_dir}/virglrenderer-android/bin/virgl_test_server.cp_from_termux --socket-path="${LINUX_DIR}/tmp/.virgl_test" --use-egl-surfaceless --use-gles 2>&1 &
    # virglrenderer-android/bin/virgl_test_server.cp_from_termux --socket-path="${LINUX_DIR}/tmp/.virgl_test" --use-egl-surfaceless --use-gles 2>&1 &

    tmpfile=./svc_virgl
	cat <<- EOF > ${tmpfile}
		#!/system/bin/sh
		exec -a svc_virgl ${tools_dir}/virglrenderer-android/bin/virgl_test_server.cp_from_termux --socket-path="${LINUX_DIR}/tmp/.virgl_test" --use-egl-surfaceless --use-gles 2>&1
	EOF
    chmod a+x ${tmpfile}
    ${tmpfile} &

    # # 自己编译的，运行失败
    # # vtest_srv --socket-path="./linux/tmp/.virgl_test" --use-egl-surfaceless --use-gles 2>&1 &
}

function start_pulseaudio_srv() {
    chmod a+x ${tools_dir}/ndkpulseaudio/bin/*

    # # -v
    # ${tools_dir}/ndkpulseaudio/bin/pulseaudio -n --disable-shm --load="module-sles-sink" --load="module-native-protocol-tcp auth-anonymous=1" --exit-idle-time=7200 --dl-search-path=${tools_dir}/ndkpulseaudio/libs 2>&1 &

    tmpfile=./svc_audio
	cat <<- EOF > ${tmpfile}
		#!/system/bin/sh
        exec -a svc_audio ${tools_dir}/ndkpulseaudio/bin/pulseaudio -n --disable-shm --load="module-sles-sink" --load="module-native-protocol-tcp auth-anonymous=1" --exit-idle-time=7200 --dl-search-path=${tools_dir}/ndkpulseaudio/libs 2>&1
	EOF
    chmod a+x ${tmpfile}
    ${tmpfile} &

}

function start_getifaddrs_srv() {
    if [ ! -d ${tools_dir}/getifaddrs ]; then
        return
    fi

    chmod a+x ${tools_dir}/getifaddrs/*

    # ${tools_dir}/getifaddrs/getifaddrs_bridge_server "${LINUX_DIR}/tmp/.getifaddrs-bridge" 2>&1 &

    tmpfile=./svc_netif
	cat <<- EOF > ${tmpfile}
		#!/system/bin/sh
        exec -a svc_netif ${tools_dir}/getifaddrs/getifaddrs_bridge_server "${LINUX_DIR}/tmp/.getifaddrs-bridge" 2>&1
	EOF
    chmod a+x ${tmpfile}
    ${tmpfile} &

}



function generate_jwm_menu_oslist() {
    echo '<JWM>'                                                                                                    > ${app_home}/jwm_menu_oslist
    echo '<!-- Automatically generated and updated. Do not touch -->'                                               >>${app_home}/jwm_menu_oslist
  # echo '<Program label="重启以安装其它系统"             >/exbin/tools/vm_OSRebootto.sh setup</Program>'           >>${app_home}/jwm_menu_oslist

    curr_osname=`basename $LINUX_DIR`
    echo ""
    echo "  \$LINUX_DIR: $LINUX_DIR"
    echo "\$curr_osname: $curr_osname"
    echo "正在查找已安装的虚拟系统"

	dir_VMs=${app_home}/vm
    for osname in ${dir_VMs}/*-*; do
        echo "$osname"

        if [ ! -r $osname ]; then
            continue
        fi

        osname=`basename $osname`
        if [ "$curr_osname" == "$osname" ]; then
            continue
        fi

        echo "<Program label=\"重启到 $osname\" >/exbin/tools/vm_OSRebootto.sh $osname</Program>"               >>${app_home}/jwm_menu_oslist
    done
    unset osname
    echo ""

    # if [ -d ${app_home}/vm/linux-amd64 ] && [ "${vmCpuArchId}" != "1" ]; then
    # echo '<Program label="重启到 linux-amd64" >/exbin/tools/vm_OSRebootto.sh linux-amd64</Program>'                 >>${app_home}/jwm_menu_oslist
    # fi
    # if [ -d ${app_home}/vm/linux-arm64 ] && [ "${vmCpuArchId}" != "0" ]; then
    # echo '<Program label="重启到 linux-arm64" >/exbin/tools/vm_OSRebootto.sh linux-arm64</Program>'                 >>${app_home}/jwm_menu_oslist
    # fi

    echo '</JWM>'                                                                                                   >>${app_home}/jwm_menu_oslist
}

function generate_jwm_menu_debug_xserverOrder() {
    chmod a+x ${tools_dir}/misc/dyn_menu/*
}


function create_dir_filerecv() {

    rm -rf ${files_dir}/filerecv
    ln -s ./vm/${CURRENT_OS_NAME}/home/droidvm/Desktop ${files_dir}/filerecv

}

function remove_flag_files() {
    if [ ! -d $LINUX_DIR/tmp ]; then
        mkdir -p $LINUX_DIR/tmp 2>/dev/null
    fi
    chmod 777 $LINUX_DIR/tmp

    rm -rf $LINUX_DIR/tmp/req_reboot
    rm -rf $LINUX_DIR/tmp/LinuxStarted
    rm -rf $LINUX_DIR/tmp/xstarted
    rm -rf $LINUX_DIR/tmp/enable_webctrl
    rm -rf $LINUX_DIR/tmp/zzswmgr.running
}


#################################################################################
chmod a+x ${tools_dir}/cputrans/*
chmod a+x ${tools_dir}/misc/dyn_menu/*


#################################################################################
generate_jwm_menu_oslist

#################################################################################
if [ "$VM_BOOTTYPE" == "cold" ]; then

    if [ "${HOST_CPU_ARCH}" == "arm64" ]; then
        BOOL_START_VIRGL_SERVER=`cat ${app_home}/app_boot_config/cfg_autostart_virgl_service.txt 2>/dev/null`
        BOOL_START_AUDIO_SERVER=`cat ${app_home}/app_boot_config/cfg_autostart_audio_service.txt 2>/dev/null`
        BOOL_START_IFBRG_SERVER=`cat ${app_home}/app_boot_config/cfg_autostart_ifbrg_service.txt 2>/dev/null`

        if [ "$BOOL_START_VIRGL_SERVER" == "" ] || [ $BOOL_START_VIRGL_SERVER -ne 0 ]; then
            echo2apk 'starting virgl server...'
            start_virgl_srv
        fi

        if [ "$BOOL_START_AUDIO_SERVER" == "" ] || [ $BOOL_START_AUDIO_SERVER -ne 0 ]; then
            echo2apk '正在启动音频播放服务...'
            start_pulseaudio_srv
        fi

        if [ "$BOOL_START_IFBRG_SERVER" == "" ] || [ $BOOL_START_IFBRG_SERVER -ne 0 ]; then
            echo2apk '正在启动 getifaddrs 服务...'
            start_getifaddrs_srv
        fi
    fi

    echo2apk 'chmod helper scripts...'
    chmod 755 ${tools_dir}/misc/helper/*.sh
fi

function startvm_using_chroot() {

    echo "chroot 方案未支持"
    exit 0

    su -c mount --bind /proc $LINUX_DIR/proc
    su -c mount --bind $LINUX_DIR/../.. $LINUX_DIR/exbin

    chmod 755 $LINUX_DIR/usr/bin/*
    chmod 755 $LINUX_DIR/bin/*
    chmod 755 $LINUX_DIR/sbin/*
    chmod 755 $LINUX_DIR/usr/local/bin/*
    chmod 755 $LINUX_DIR/usr/local/sbin/*

    cp -f ${app_home}/busybox $LINUX_DIR/
    chmod 777 $LINUX_DIR/busybox

    mkdir -p  $LINUX_DIR/tmp
    chmod 777 $LINUX_DIR/tmp

    unset LD_PRELOAD
    command="su -c chroot"
    command+=" ${app_home}/vm/${CURRENT_OS_NAME}/"
    command+=" /usr/bin/env -i"
    command+=" HOME=/root"
    command+=" TMPDIR=/tmp"
    command+=" PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games:/exbin"
    command+=" TERM=vt100"	#不同的终端类型支持不同的功能，比如：终端文字着色，光标随意定位。。。，不设置的话不能在终端中运行 reset 指令
    command+=" LANG=C.UTF-8"
    # command+=" export LD_LIBRARY_PATH=${app_home}/vm/linux-arm64-2/usr/lib/aarch64-linux-gnu/"
    # command+=" /busybox sh"
    # command+=" $LINUX_LOGIN_COMMAND"
    command+=" /bin/bash"

    # echo $command
    # su -c "$command" 2>&1 >$APP_STDIO_NAME <$APP_STDIO_NAME &


    # ls -al /data/user/0/com.zzvm/files/vm/linux-arm64-2/
    # su -c "chroot /data/user/0/com.zzvm/files/vm/linux-arm64-2/  /busybox echo 'test'"

    remove_flag_files

    echo2apk 'starting linux bash...'
    # $command 2>&1
    # $command 2>&1 >$APP_STDIO_NAME <$APP_STDIO_NAME &
    $command 2>&1
}

function startvm_using_proot() {

    chmod 755 ${PROOT_BINARY_DIR}/*
    chmod 755 ${PROOT_BINARY_DIR}/loader/*

    sysvipc_function_test=`${PROOT_BINARY_DIR}/proot --help|grep sysvipc`

    VM_HOSTNAME=`cat ${LINUX_DIR}/etc/hostname 2>/dev/null`
    if [ "$VM_HOSTNAME" == "" ]; then
        VM_HOSTNAME=DroidVM
    fi

    case "${vmCpuArchId}" in
        "1")
            export TMP_ARCH=x86_64
            ;;
        *)
            export TMP_ARCH=aarch64
            ;;
    esac

    ANDROID_KERNEL_RELEASE=`uname -r`
    ANDROID_KERNEL_VERSION=`uname -v`
    ANDROID_KERNEL_VERSION="#1"
    # echo "ANDROID_KERNEL_VERSION: ${ANDROID_KERNEL_VERSION}"

    # '\sysname\nodename\release\version\machine\domainname\hwcap\'

    # KERNEL_STRING_WITHIN_HOSTNAME='\Linux\'"${VM_HOSTNAME}"'\'"${ANDROID_KERNEL_RELEASE}"'\'"${ANDROID_KERNEL_VERSION}"'\'"${TMP_ARCH}"'\domainname\-1\'    # 参考：https://github.com/termux/proot/issues/80 以及 proot 源码中的 src\extension\kompat\kompat.c
    KERNEL_STRING_WITHIN_HOSTNAME="\\Linux\\${VM_HOSTNAME}\\${ANDROID_KERNEL_RELEASE}\\${ANDROID_KERNEL_VERSION}\\${TMP_ARCH}\\domainname\\-1\\"    # 参考：https://github.com/termux/proot/issues/80 以及 proot 源码中的 src\extension\kompat\kompat.c
    # KERNEL_STRING_WITHIN_HOSTNAME='Linux DroidVM 4.14.186+ #1 SMP PREEMPT Thu Oct 19 10:39:41 CST 2023 aarch64'
    # Linux localhost 4.14.186+ #1 SMP PREEMPT Thu Oct 19 10:39:41 CST 2023 aarch64 aarch64 aarch64 GNU/Linux

    unset LD_PRELOAD
    command="${PROOT_BINARY_DIR}/proot"
    command+=" -H"
    command+=" --kernel-release=${KERNEL_STRING_WITHIN_HOSTNAME}"
    command+=" --link2symlink"
    command+=" --kill-on-exit"
    command+=" -0"
    # command+=" --change-id=999:999"
    command+=" -r $LINUX_DIR"

    #### 注意 ####
    #########################################################################
    # proot-termux 的 --sysvipc 参数会影响 virgl, 也会影响 box64 运行 ndk() ！！！
    # 
    # 2023-08-04 确认：
    # 带 --sysvipc 参数启动proot-termux，vscode就白屏(vscoce基于Electron)
    # 带 --sysvipc 参数启动proot-termux，box64 + ndk 内存分配出错
    # 无 --sysvipc 参数启动proot-termux，vscode正常
    # 无 --sysvipc 参数启动proot-termux，box64 + ndk 内存分配也出错
    #
    # 使用自己编译的proot-userland, vscode正常
    # 使用自己编译的proot-userland, box64 + ndk 内存分配也出错, box64+wine64正常, box86+wine32正常
    #
    # 使用网上下载的proot-userland, vscode正常
    # 使用网上下载的proot-userland, box64 + ndk 正常,           box64+wine64正常, box86+wine32卡死->sendmsg not implement
    # 
    #########################################################################

	if [ -f ${app_home}/sysvipc ]; then
        if [ "${sysvipc_function_test}" != "" ]; then
            echo "有：$sysvipc_function_test"
            command+=" --sysvipc"
        else
            echo "无 --sysvipc 参数"
        fi
    fi

    # # 保留，不要删除
    # if [ "${HOST_CPU_ARCH}" == "arm64" ] && [ "${vmCpuArchId}" == "1" ]; then
    #     command+=" -q ./cputrans/qemu-x86_64-static"
    #     command+=" -L"
    # fi
    # if [ "${HOST_CPU_ARCH}" == "amd64" ] && [ "${vmCpuArchId}" == "0" ]; then
    #     command+=" -q ./cputrans/qemu-aarch64-static"
    #     command+=" -L"
    # fi
    # if [ -f $LINUX_DIR/home/droidvm/nn ]; then
    #     command+=" -q $LINUX_DIR/home/droidvm/nn"
    # fi

    ## 为了能在proot环境中使用opengles (2024.04.09添加，proot中的gl4es待测试)
    tmpdir="/apex"; if [ -d ${tmpdir} ]; then command+=" -b ${tmpdir}"; fi
    tmpdir="/acct"; if [ -d ${tmpdir} ]; then command+=" -b ${tmpdir}"; fi
    tmpdir="/odm"; if [ -d ${tmpdir} ]; then command+=" -b ${tmpdir}"; fi
    tmpdir="/odm_dlkm"; if [ -d ${tmpdir} ]; then command+=" -b ${tmpdir}"; fi
    tmpdir="/oem"; if [ -d ${tmpdir} ]; then command+=" -b ${tmpdir}"; fi
    tmpdir="/product"; if [ -d ${tmpdir} ]; then command+=" -b ${tmpdir}"; fi
    tmpdir="/sys"; if [ -d ${tmpdir} ]; then command+=" -b ${tmpdir}"; fi
    tmpdir="/system"; if [ -d ${tmpdir} ]; then command+=" -b ${tmpdir}"; fi
    tmpdir="/system_ext"; if [ -d ${tmpdir} ]; then command+=" -b ${tmpdir}"; fi
    tmpdir="/vendor"; if [ -d ${tmpdir} ]; then command+=" -b ${tmpdir}"; fi
    tmpdir="/vendor_dlkm"; if [ -d ${tmpdir} ]; then command+=" -b ${tmpdir}"; fi
    ## end of opengles

    # ## start of vulkan test，在这里加上的话，会导致 sudo -D 失败，所以这里不能加！
    # command+=" -b ${app_home}/n"
    # ## end of vulkan

    # # uos-fake
    # if [ -f $LINUX_DIR/etc/lsb-release.uos ]; then
    #     command+=" -b $LINUX_DIR/etc/lsb-release.uos:/etc/lsb-release"
    # fi
    # if [ -f $LINUX_DIR/etc/lsb-release.uos ]; then
    #     command+=" -b $LINUX_DIR/usr/lib/os-release.uos:/usr/lib/os-release"
    # fi

    # if [ -d /linkerconfig ]; then
    command+=" -b /linkerconfig"
    # fi
    if [ -d $LINUX_DIR/opt/apps/termux ]; then
    command+=" -b $LINUX_DIR/opt/apps/termux:/data/data/com.termux/files"
    fi
    command+=" -b /system -b /dev -b /:/host-rootfs"
    command+=" -b /dev/urandom:/dev/random"
    command+=" -b /dev"
    command+=" -b /proc"
    command+=" -b /proc/self/fd:/dev/fd"
    command+=" -b /proc/self/fd/0:/dev/stdin"
    command+=" -b /proc/self/fd/1:/dev/stdout"
    command+=" -b /proc/self/fd/2:/dev/stderr"

    command+=" -b ${LINUX_FAKE_PROC_DIR}/.loadavg:/proc/loadavg"
    command+=" -b ${LINUX_FAKE_PROC_DIR}/.stat:/proc/stat"
    command+=" -b ${LINUX_FAKE_PROC_DIR}/.uptime:/proc/uptime"
    command+=" -b ${LINUX_FAKE_PROC_DIR}/.version:/proc/version"
    command+=" -b ${LINUX_FAKE_PROC_DIR}/.vmstat:/proc/vmstat"
    # command+=" -b ${LINUX_FAKE_PROC_DIR}/mounts:/proc/self/mounts"

    # command+=" -b ${LINUX_FAKE_PROC_DIR}/stat:/proc/stat"
    # command+=" -b ${LINUX_FAKE_PROC_DIR}/version:/proc/version"
    # command+=" -b ${LINUX_FAKE_PROC_DIR}/bus:/proc/bus"
    # command+=" -b ${LINUX_FAKE_PROC_DIR}/buddyinfo:/proc/buddyinfo"
    # command+=" -b ${LINUX_FAKE_PROC_DIR}/cgroups:/proc/cgroups"
    # command+=" -b ${LINUX_FAKE_PROC_DIR}/consoles:/proc/consoles"
    # command+=" -b ${LINUX_FAKE_PROC_DIR}/crypto:/proc/crypto"
    # command+=" -b ${LINUX_FAKE_PROC_DIR}/devices:/proc/devices"
    # command+=" -b ${LINUX_FAKE_PROC_DIR}/diskstats:/proc/diskstats"
    # command+=" -b ${LINUX_FAKE_PROC_DIR}/execdomains:/proc/execdomains"
    # command+=" -b ${LINUX_FAKE_PROC_DIR}/fb:/proc/fb"
    # command+=" -b ${LINUX_FAKE_PROC_DIR}/filesystems:/proc/filesystems"
    # command+=" -b ${LINUX_FAKE_PROC_DIR}/interrupts:/proc/interrupts"
    # command+=" -b ${LINUX_FAKE_PROC_DIR}/iomem:/proc/iomem"
    # command+=" -b ${LINUX_FAKE_PROC_DIR}/ioports:/proc/ioports"
    # command+=" -b ${LINUX_FAKE_PROC_DIR}/kallsyms:/proc/kallsyms"
    # command+=" -b ${LINUX_FAKE_PROC_DIR}/keys:/proc/keys"
    # command+=" -b ${LINUX_FAKE_PROC_DIR}/key-users:/proc/key-users"
    # command+=" -b ${LINUX_FAKE_PROC_DIR}/kpageflags:/proc/kpageflags"
    # command+=" -b ${LINUX_FAKE_PROC_DIR}/loadavg:/proc/loadavg"
    # command+=" -b ${LINUX_FAKE_PROC_DIR}/locks:/proc/locks"
    # command+=" -b ${LINUX_FAKE_PROC_DIR}/misc:/proc/misc"
    # command+=" -b ${LINUX_FAKE_PROC_DIR}/modules:/proc/modules"
    # command+=" -b ${LINUX_FAKE_PROC_DIR}/pagetypeinfo:/proc/pagetypeinfo"
    # command+=" -b ${LINUX_FAKE_PROC_DIR}/partitions:/proc/partitions"
    # command+=" -b ${LINUX_FAKE_PROC_DIR}/sched_debug:/proc/sched_debug"
    # command+=" -b ${LINUX_FAKE_PROC_DIR}/softirqs:/proc/softirqs"
    # command+=" -b ${LINUX_FAKE_PROC_DIR}/timer_list:/proc/timer_list"
    # command+=" -b ${LINUX_FAKE_PROC_DIR}/uptime:/proc/uptime"
    # command+=" -b ${LINUX_FAKE_PROC_DIR}/vmallocinfo:/proc/vmallocinfo"
    # command+=" -b ${LINUX_FAKE_PROC_DIR}/vmstat:/proc/vmstat"
    # command+=" -b ${LINUX_FAKE_PROC_DIR}/zoneinfo:/proc/zoneinfo"

    # # for vulkan test => 实测失败！
    # command+=" -b ${LINUX_DIR}/home"

    command+=" -b /sys"
    command+=" -b $PROOT_TMP_DIR:/dev/shm"
    command+=" -b $app_home:/exbin" # 这一行会导致ndk-vulkan-demo运行失败！ 改成在下面创建链接了，实测这样可能会导致安装不了软件，又改回了
    command+=" -b $app_home"          # 映射了这个目录后 dotnet 才可以运行！
    # command+=" -b /system/fonts:/usr/share/fonts/truetype/droid"
    command+=" -b /sdcard"
    command+=" -b /storage"     # 安卓外接的otg U盘会挂在这个路径下，权限与 /sdcard 共享
    command+=" -w /root"
    command+=" /usr/bin/env -i"
    command+=" APP_INTERNAL_DIR=$app_home"
    command+=" HOME=/root"
    command+=" TMPDIR=/tmp"
    command+=" PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games:/exbin"
    command+=" TERM=vt100"	#不同的终端类型支持不同的功能，比如：终端文字着色，光标随意定位。。。，不设置的话不能在终端中运行 reset 指令
    command+=" LANG=C.UTF-8"
    # command+=" APP_STDIO_NAME=${APP_STDIO_NAME}"

    path_getifaddrs_client=/exbin/tools/getifaddrs/getifaddrs_bridge_client_lib.so
    mkdir -p $LINUX_DIR/etc/autoruns
    busybox pidof getifaddrs_bridge_server
    bFoundProc=$?
	if [ $bFoundProc -eq 0 ] && [ -f ${tools_dir}/getifaddrs/getifaddrs_bridge_client_lib.so ] && [ "${vmCpuArchId}" == "0" ]; then
    	echo "LD_PRELOAD=${path_getifaddrs_client}" > $LINUX_DIR/etc/autoruns/vm_runtime_env.sh
        command+=" LD_PRELOAD=${path_getifaddrs_client}"
    else
        cat $LINUX_DIR/etc/autoruns/vm_runtime_env.sh|grep -v "LD_PRELOAD=${path_getifaddrs_client}" > $LINUX_DIR/etc/autoruns/vm_runtime_env.sh
    fi
    command+=" $LINUX_LOGIN_COMMAND"
    # command+=" /bin/bash --login"


    # # proot有路径绑定vulkan就识别不到GPU
    # rm -rf $LINUX_DIR/exbin
    # ln -sf $app_home $LINUX_DIR/exbin

    remove_flag_files

    echo ""
    echo2apk 'starting linux bash...'

    # $command 2>&1
    # $command 2>&1 >$APP_STDIO_NAME <$APP_STDIO_NAME &
    $command 2>&1
}


function startvm_using_proot_with_ndk_vulkan() {

    # 目前的测试发现，要能在proot环境中调用ndk编译的vulkan程序，需要满足两个条件：
    # 1). 以宿主的根目录做为虚拟系统的根目录 (但这样做又无权限列出根目录的文件列表)
    # 2). 不能映射这个路径：/data/user/0/com.zzvm/files (但 dotnet 却是需要这映射这个路径的)

    chmod 755 ${PROOT_BINARY_DIR}/*
    chmod 755 ${PROOT_BINARY_DIR}/loader/*

    sysvipc_function_test=`${PROOT_BINARY_DIR}/proot --help|grep sysvipc`

    VM_HOSTNAME=`cat ${LINUX_DIR}/etc/hostname 2>/dev/null`
    if [ "$VM_HOSTNAME" == "" ]; then
        VM_HOSTNAME=DroidVM
    fi

    case "${vmCpuArchId}" in
        "1")
            export TMP_ARCH=x86_64
            ;;
        *)
            export TMP_ARCH=aarch64
            ;;
    esac

    ANDROID_KERNEL_RELEASE=`uname -r`
    ANDROID_KERNEL_VERSION=`uname -v`
    ANDROID_KERNEL_VERSION="#1"

    KERNEL_STRING_WITHIN_HOSTNAME="\\Linux\\${VM_HOSTNAME}\\${ANDROID_KERNEL_RELEASE}\\${ANDROID_KERNEL_VERSION}\\${TMP_ARCH}\\domainname\\-1\\"    # 参考：https://github.com/termux/proot/issues/80 以及 proot 源码中的 src\extension\kompat\kompat.c

    remove_flag_files
    # cd ${LINUX_DIR} && ln -sf ./etc etl

    echo ""
    echo2apk 'starting linux bash...'

    export PROOT_TMP_DIR=${LINUX_DIR}/tmp
    export PROGRAM=${app_home}/main_ndk-vulkan-demo1
    command="${PROOT_BINARY_DIR}/proot"
    command+=" -H"
    command+=" --kernel-release=${KERNEL_STRING_WITHIN_HOSTNAME}"
    command+=" --link2symlink"
    command+=" --kill-on-exit"
    command+=" -0"
    command+=" -r /"
	if [ -f ${app_home}/sysvipc ]; then
        if [ "${sysvipc_function_test}" != "" ]; then
            echo "有：$sysvipc_function_test"
            command+=" --sysvipc"
        else
            echo "无 --sysvipc 参数"
        fi
    fi
    if [ -d $LINUX_DIR/opt/apps/termux ]; then
    command+=" -b $LINUX_DIR/opt/apps/termux:/data/data/com.termux/files"
    fi
    command+=" -r /"
    command+=" -0"
    command+=" -w /root"
    ## -b ${app_home} 绑定后：
    ## 1). 无法使用 sudo -D 指令!
    ## 2). proot 环境中能成功调用vulkan
    ## 3). lx终端中cd /exbin后菜单栏打开新窗口，路径变为安卓路径
    ##
    ## -b ${app_home} 不绑定：
    ## 1). 可以使用 sudo -D 指令!
    ## 2). proot 环境中不能调用vulkan
    ## 3). lx终端中cd /exbin后菜单栏打开新窗口，路径还是 /exbin
    ##
    ## => 总算搞清楚了！
    ## ndk-vulkan程序所在的目录，对应的安卓路径，必须完全相同的映射到虚拟系统中！
    # command+=" -b ${app_home}"
    command+=" -b ${app_home}/n"
    command+=" -b ${app_home}:/exbin"
    command+=" -b ${LINUX_DIR}/lib:/lib"
    command+=" -b ${LINUX_DIR}/usr:/usr"
    command+=" -b ${LINUX_DIR}/var:/var"
    command+=" -b ${LINUX_DIR}/tmp:/tmp"
    command+=" -b ${LINUX_DIR}/etc:/system/etc"
    command+=" -b ${LINUX_DIR}/opt:/opt"
    command+=" -b ${LINUX_DIR}/run:/run"
    command+=" -b ${LINUX_DIR}/boot:/boot"
    command+=" -b ${LINUX_DIR}/sbin:/sbin"
    command+=" -b ${LINUX_DIR}/root:/root"
    command+=" -b ${LINUX_DIR}/home:/home"
    command+=" -b ${LINUX_DIR}/usr/bin/bash:/bin/bash"
    command+=" -b ${LINUX_DIR}/usr/bin/bash:/bin/sh"
    command+=" -b /dev/urandom:/dev/random"
    command+=" -b $PROOT_TMP_DIR:/dev/shm"
    command+=" -b /proc/self/fd:/dev/fd"
    command+=" -b /proc/self/fd/0:/dev/stdin"
    command+=" -b /proc/self/fd/1:/dev/stdout"
    command+=" -b /proc/self/fd/2:/dev/stderr"
    command+=" -b ${LINUX_FAKE_PROC_DIR}/.loadavg:/proc/loadavg"
    command+=" -b ${LINUX_FAKE_PROC_DIR}/.stat:/proc/stat"
    command+=" -b ${LINUX_FAKE_PROC_DIR}/.uptime:/proc/uptime"
    command+=" -b ${LINUX_FAKE_PROC_DIR}/.version:/proc/version"
    command+=" -b ${LINUX_FAKE_PROC_DIR}/.vmstat:/proc/vmstat"
    command+=" /usr/bin/env -i"
    command+=" APP_INTERNAL_DIR=$app_home"
    command+=" HOME=/root TMPDIR=/tmp"
    command+=" ENABLEVK=1"
    command+=" PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games:/exbin"
    command+=" TERM=vt100"
    command+=" LANG=C.UTF-8"
    # command+=" APP_STDIO_NAME=${APP_STDIO_NAME}"

    # path_getifaddrs_client=/exbin/tools/getifaddrs/getifaddrs_bridge_client_lib.so
    # mkdir -p $LINUX_DIR/etc/autoruns
    # busybox pidof getifaddrs_bridge_server
    # bFoundProc=$?
	# if [ $bFoundProc -eq 0 ] && [ -f ${tools_dir}/getifaddrs/getifaddrs_bridge_client_lib.so ] && [ "${vmCpuArchId}" == "0" ]; then
    # 	echo "LD_PRELOAD=${path_getifaddrs_client}" > $LINUX_DIR/etc/autoruns/vm_runtime_env.sh
    #     command+=" LD_PRELOAD=${path_getifaddrs_client}"
    # else
    #     cat $LINUX_DIR/etc/autoruns/vm_runtime_env.sh|grep -v "LD_PRELOAD=${path_getifaddrs_client}" > $LINUX_DIR/etc/autoruns/vm_runtime_env.sh
    # fi

    command+=" $LINUX_LOGIN_COMMAND"
    # command+=" ${app_home}/tools/vm_init.sh"

    # $command 2>&1
    # $command 2>&1 >$APP_STDIO_NAME <$APP_STDIO_NAME &
    # cd ${app_home}
    # pwd
    unset LD_PRELOAD
    $command 2>&1

}


#################################################################################
echo "LINUX_DIR => $LINUX_DIR"
echo "${CURRENT_OS_NAME}" > ${app_home}/droidvm_vars_currosname

create_dir_filerecv

which su >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "设备未root，正在尝试以proot方式加载rootfs"
    if [ -f ${app_home}/app_boot_config/cfg_rootfs_sameAsHost.txt ]; then
        startvm_using_proot_with_ndk_vulkan
    else
        startvm_using_proot
    fi
else
    echo "设备已root，正在尝试以chroot方式加载rootfs"
    # startvm_using_chroot
    startvm_using_proot
fi

if [ -f $LINUX_DIR/tmp/req_reboot ]; then
    echo ""
    echo "正在重新启动"
    echo "================================"
    echo ""
    cd ${app_home}

    cat droidvm_vars.sh|grep "VM_BOOTTYPE=warm"
    if [ $? -ne 0 ]; then
        echo "export VM_BOOTTYPE=warm" >> droidvm_vars.sh
    fi

    exec ./droidvm_main.sh
else
    echo ""
    echo "虚拟机已停止"
    echo "================================"
    echo ""
fi