#!/bin/bash

function services_before_gui() {
	dir_scripts=/etc/autoruns/services_before_gui
    if [ -d ${dir_scripts} ]; then
        # ls -al ${dir_scripts}
        echo "${dir_scripts} 加载中..."
        for i in ${dir_scripts}/*.sh; do
            if [ -r $i ]; then
                echo "$i"
                . $i
            fi
        done
        unset i
    fi
}

function services_after_gui() {
	dir_scripts=/etc/autoruns/services_after_gui
    if [ -d ${dir_scripts} ]; then
        # ls -al ${dir_scripts}
        echo "${dir_scripts} 加载中..."
        for i in ${dir_scripts}/*.sh; do
            if [ -r $i ]; then
                echo "$i"
                . $i
            fi
        done
        unset i
    fi
}

function create_scdard_link() {
    if [ -r /sdcard ]; then
        rm -rf /home/droidvm/Desktop/SD卡.desktop
        rm -rf /home/droidvm/Desktop/SD卡
        ln -s -f /sdcard /home/droidvm/Desktop/SD卡
    else
        rm -rf /home/droidvm/Desktop/SD卡
		cat <<- EOF >> /home/droidvm/Desktop/SD卡.desktop
				[Desktop Entry]
				Encoding=UTF-8
				Version=0.9.4
				Type=Application
				Name=SD卡
				Terminal=false
				Exec=/exbin/tools/vm_scan_sdcard.sh
				Path=~/
		EOF
    fi
}

function start_dbus_server() {
    # system-dbus
    mkdir -p /run/dbus 2>/dev/null
    rm -rf /run/dbus/pid
    if [ -x /usr/bin/dbus-daemon ]; then
        /usr/bin/dbus-daemon --system --nofork &
    fi
    # dbus-send --system --print-reply --dest=org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.appearance.color-scheme
}

function start_update_script() {
    # 以root权限调用升级脚本
    if [ -f ${APP_FILENAME_URLTOOLS} ]; then
    chmod a+x ${tools_dir}/updates/${APP_RELEASE_VERSION}.sh
    ${tools_dir}/updates/${APP_RELEASE_VERSION}.sh
    fi
}

function start_gui_desktop() {

    # sudo -u droidvm ${tools_dir}/vm_startx.sh 2>&1 >$APP_STDIO_NAME &
    currdir=`pwd`
    echo ""
    # echo "sudo -u droidvm -D ${currdir} ${tools_dir}/vm_startx.sh 2>&1"
    # sudo -u droidvm -D ${currdir} ${tools_dir}/vm_startx.sh 2>&1 &
    echo "vm_startx.sh"
    su droidvm -c ${tools_dir}/vm_startx.sh 2>&1 &

    services_after_gui
}

if [ "$UID" == "0" ]; then

    if [ ! -f /tmp/LinuxStarted ]; then

        touch /tmp/LinuxStarted

        #################################################################################
        if [ 0 -eq 1 ]; then
            echo2apk "正在启动 telnetd, port: 5556"
            busybox telnetd -p 5556 -l /bin/bash &
            # exit 0
        fi

        if [ -f /tmp/osrestoremsg.txt ]; then
            echo ""
                        # todo
            #             echo "系统还原后，网络用不了，临时加个补丁在这，如果没作用，请忽略连接过的wifi并重新输入密码连接"

            #             mkdir -p /run/systemd/resolve
            #             touch /run/systemd/resolve/stub-resolv.conf
            #             echo 'nameserver 114.114.114.114' > /etc/resolv.conf
            #             echo 'nameserver 8.8.4.4'         >>/etc/resolv.conf

            # cat <<- EOF > /etc/hosts
            # # IPv4.
            # 127.0.0.1   localhost.localdomain localhost

            # # IPv6.
            # ::1         localhost.localdomain localhost ip6-localhost ip6-loopback
            # fe00::0     ip6-localnet
            # ff00::0     ip6-mcastprefix
            # ff02::1     ip6-allnodes
            # ff02::2     ip6-allrouters
            # ff02::3     ip6-allhosts
            # EOF

            #             echo "which 指令也要重新安装"
            #             apt reinstall -y which
        fi


        source ${app_home}/droidvm_vars_setup.sh
		source ${tools_dir}/vm_config.sh

        start_dbus_server
        services_before_gui

        if [ "${vmGraphicsx}" == "1" ]; then
            echo "UID: $UID, calling vm_startx.sh"

            create_scdard_link

            # 仅供测试
            if [ 1 -eq 0 ]; then
                
                source ${app_home}/droidvm_startfb.sh
                # source /exbin/tools/vm_config.sh
                # echo "正在为当前用户调用 /etc/profile"
                # source /etc/profile
                rm -rf /tmp/x_remote_server_addr
                displayid=0
                pidof_xserver=
                export DISPLAY=:${displayid}
                echo "正在启动xserver-xvfb"
                nohup Xvfb +extension XTEST +extension XFIXES +extension DAMAGE +extension RANDR +extension DOUBLE-BUFFER \
                -ac -listen tcp :0 -screen 0 4096x4096x24 -fbdir /exbin/ipc -dpi 150 &

                sleep 0.1

                echo "正在启动 controllee"
                nohup controllee -enablepc -block_size 100 -onreschange /exbin/tools/vm_startx.sh -fbin /exbin/ipc/Xvfb_screen0 2>&1 &
                echo2apk 'LinuxStarted'

                jwm &
                # pcmanfm &

            else

                start_update_script
                
                start_gui_desktop

                # source ${tools_dir}/vm_onZerogo.sh
                # echo2apk 'LinuxStarted'
            fi
        else
            echo ""
            echo "要安装图形界面，请运行: "
            echo "setup-gui.sh"
            echo "setup-gui-min.sh"
            echo "两条指令二选一即可, 其中带 min 字样的脚本，安装的是最小化的图形界面"
            echo ""

			if [ -f ${APP_FILENAME_URLTOOLS} ]; then
				rm -rf ${APP_FILENAME_URLTOOLS}
			fi

            source ${tools_dir}/vm_onZerogo.sh
            echo2apk 'LinuxStarted'
        fi

        # 保留勿删！！！
        # # echo 这个放到这里，比较容易被杀后台！
        exec /bin/bash
        # # sleep 1000

        # 仅供测试
        # busybox telnetd -p 5556 -l /bin/bash &
        # nmftpsrv -p 5557 -c gb18030 -d /home/droidvm/ &


    fi

fi
