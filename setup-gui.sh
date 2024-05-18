#!/bin/bash

SETUP_MIN_GUI=$1

source ${tools_dir}/vm_config.sh

echo "正在安装图形界面所需的软件包"

ANDROID_LANG="${APP_LANGUAGE}_${APP_COUNTRY}"

function exit_if_fail() {
    rlt_code=$1
    fail_msg=$2
    if [ $rlt_code -ne 0 ]; then
      echo -e "错误码: ${rlt_code}\n${fail_msg}"
	  whoami
	  exec /bin/bash
      exit $rlt_code
    fi
}

function install_patchs() {
	# chmod 755 ${tools_dir}/patchs/arm64/so_patch_libfm.sh
	# . ${tools_dir}/patchs/arm64/so_patch_libfm.sh

    if [ "${CURRENT_VM_ARCH}" != "arm64" ]; then
        echo "只编译了arm64架构的补丁包"
        return
    fi

    dpkg -i ${tools_dir}/patchs/${CURRENT_VM_ARCH}/libfm4_1.3.2-1_arm64.deb
    exit_if_fail $? "libfm4 补丁安装失败"

    dpkg -i ${tools_dir}/patchs/${CURRENT_VM_ARCH}/libfm-gtk4_1.3.2-1_arm64.deb
    exit_if_fail $? "libfm 补丁安装失败"

    # dpkg -i ${tools_dir}/patchs/${CURRENT_VM_ARCH}/tigervnc-standalone-server_1.12.0+dfsg-8ubuntu0.23.10.1_arm64.deb
    # exit_if_fail $? "tigervnc 补丁安装失败"
}

function install_sw() {
  pkgnames=$@
  echo "install_sw ${pkgnames}"
  apt-get install -y ${pkgnames}
  rlt_code=$?
  if [ $rlt_code -ne 0 ]; then
    apt-get --fix-broken install -y
    rlt_code=$?
	if [ $? -ne 0 ]; then return ${rlt_code}; fi

	dpkg --configure -a
    rlt_code=$?
	if [ $? -ne 0 ]; then return ${rlt_code}; fi

    apt-get install -y ${pkgnames}
    rlt_code=$?

    return ${rlt_code}
  fi
  return ${rlt_code}
}


function setup_lang() {
    # if [ "${ANDROID_LANG}" == "zh_CN" ]; then
    # if [ "${APP_LANGUAGE}" == "zh" ]; then
        # /usr/share/locales
        # /usr/share/locale
        # /usr/share/i18n/locales

        # export LANG=zh_CN.UTF-8
        # export LANGUAGE=zh_CN.UTF-8
        # export LC_CTYPE=zh_CN.UTF-8
        # export LC_NUMERIC=zh_CN.UTF-8
        # export LC_TIME=zh_CN.UTF-8
        # export LC_COLLATE=zh_CN.UTF-8
        # export LC_MONETARY=zh_CN.UTF-8
        # export LC_MESSAGES=zh_CN.UTF-8
        # export LC_PAPER=zh_CN.UTF-8
        # export LC_NAME=zh_CN.UTF-8
        # export LC_ADDRESS=zh_CN.UTF-8
        # export LC_TELEPHONE=zh_CN.UTF-8
        # export LC_MEASUREMENT=zh_CN.UTF-8
        # export LC_IDENTIFICATION=zh_CN.UTF-8
        # export LC_ALL=zh_CN.UTF-8	  

        echo2apk '正在设置轻中文环境'

        echo "正在安装简体中文字体"

        if [ "${LINUX_DISTRIBUTION}" == "debian" ]; then
        echo "zh_CN.UTF-8 UTF-8">>/etc/locale.gen
        fi

        install_sw locales ttf-wqy-microhei
        # fc-list   #列出已经安装的字体
        # xlsfonts  #列出已经安装的字体, 与 fc-list 列出的字体列表不迥，这个指令列出的是 x11-classical 可用的字体列表
        # 字体设置文件：misc\def_xconf\uimode_phone\.jwmrc 和 misc\def_xconf\uimode_phone\lxterminal.conf(习惯上终端都使用等宽字体)

        locale-gen ${ANDROID_LANG}.UTF-8
        echo ''                               		    >> /etc/profile
        echo "export TZ='${APP_TIMEZONE}'"      		>> /etc/profile
        echo "export LANG=${ANDROID_LANG}.UTF-8"        >> /etc/profile
        echo "export LANGUAGE=${ANDROID_LANG}.UTF-8"    >> /etc/profile
        echo "export LC_ALL=${ANDROID_LANG}.UTF-8"      >> /etc/profile
        echo "export LC_CTYPE=${ANDROID_LANG}.UTF-8"    >> /etc/profile
        echo "export LC_MESSAGE=${ANDROID_LANG}.UTF-8"  >> /etc/profile   # 关联路径: /usr/share/locale/zh_CN/LC_MESSAGES/, 决定pcmanfm,jwm能否汉化
        chmod 755 /etc/profile

        source /etc/profile

    # fi
}

if [ "$UID" == "0" ]; then

    echo "export vmGraphicsx=1" >> ${app_home}/droidvm_vars_setup.sh
    echo "export vmGraphicsx=1" >> /etc/droidvm/bootup_scripts/droidvm_vars_setup.sh

    # echo2apk '正在复制安卓字体文件'
    # # #################################################################################
    # mkdir -p /usr/share/fonts/truetype/droid
    # cp -f /host-rootfs/system/fonts/*  /usr/share/fonts/truetype/droid/
    # # cp -Rf /host-rootfs/system/fonts /usr/share/fonts/truetype
    # # mv -f /usr/share/fonts/truetype/fonts /usr/share/fonts/truetype/droid
    # exit_if_fail $? "安卓字体文件复制失败"


    # # apt-mark hold gvfs-daemons udisks2

    # echo2apk '正在安装基础工具: sudo ps ping vim, gpg, apt-utils, binutils glmark2...'
    # apt-get install vim gpg apt-utils -y

    # # sudo apt-get install -y android-tools-adb
    # # adb connect IP:PORT
    # # apt-get install procps net-tools iputils-ping iproute2 vim gpg apt-utils binutils glmark2 -y
    # # ln -f -s ${tools_dir}/busybox /bin/ps
    # # ln -f -s ${tools_dir}/busybox /bin/top
    # # ln -f -s ${tools_dir}/busybox /bin/tar

    # # 音量控制器
    # apt-get install pavucontrol -y

    # echo2apk '正在安装glmark2'
    # apt-get install glmark2 -y

    # echo "\n"
    # echo "ANDROID LANGUAGE:$APP_LANGUAGE"
    # echo "ANDROID  COUNTRY:$APP_COUNTRY"
    # echo '===================================='

    # if [ "${APP_LANGUAGE}_${APP_COUNTRY}" == "zh_CN" ]; then
    #   echo2apk '正在安装中文语言包'
    #   apt-get install --no-install-recommends locales language-pack-zh-hans -y
    #   locale-gen zh_CN.UTF-8
    #   echo ''                               >> /etc/profile
    #   echo "export TZ='Asia/Shanghai'"      >> /etc/profile
    #   echo 'export LANG=zh_CN.UTF-8'        >> /etc/profile
    #   echo 'export LANGUAGE=zh_CN.UTF-8'    >> /etc/profile
    #   echo 'export LC_ALL=zh_CN.UTF-8'      >> /etc/profile
    #   echo 'export LC_CTYPE=zh_CN.UTF-8'    >> /etc/profile
    #   echo 'export LC_MESSAGE=zh_CN.UTF-8'  >> /etc/profile   # 关联路径: /usr/share/locale/zh_CN/LC_MESSAGES/, 决定pcmanfm,jwm能否汉化

    #   source /etc/profile
    #   echo2apk '正在安装中文输入法'
    #   apt-get install fcitx-table-wbpy -y
    # fi


    # echo2apk '正在安装图形显示环境(约1分钟)'
    # export DEBIAN_FRONTEND=noninteractive
    # apt-get install --no-install-recommends xvfb -y

    # echo2apk '正在安装图显的扩展模块'
    # apt-get install --no-install-recommends libx11-dev libxdamage-dev libxtst-dev libxfixes-dev -y

    # echo2apk '正在安装图显的桌面环境(约4分钟)'
    # # apt-get install xfce4 -y
    # # apt-get install icewm -y
    # # apt-get install --no-install-recommends dbus-x11 jwm spacefm -y
    # apt-get install --no-install-recommends jwm -y
    # apt-get install pcmanfm libfm-modules -y
    # apt-get install dbus-x11 -y

    # # apt-get install --no-install-recommends dbus-x11 xfce4 -y
    # # apt-get install --no-install-recommends lxde-core -y
    # # apt-get install --no-install-recommends icewm -y
    # # apt-get install icewm -y
    # # apt-get install wine -y

    # echo2apk '正在安装常用的x11软件'
    # # sudo apt-get install ttf-wqy-microhei -y #中文字体 https://blog.csdn.net/pythonyzh2019/article/details/109510690
    # # apt-get install --no-install-recommends xvkbd -y
    # apt-get install l3afpad curl lxterminal gxmessage yad x11-xserver-utils xfonts-100dpi -y
    # apt-get install gnome-themes-standard -y

    # # xterm 太老，经常是装完启动不了, 决定永远不使用了

    # # hexdump, used by wps-office
    # # apt-get install -y bsdmainutils

    # # apt-get install chromium-browser -y
    # # apt-get install --no-install-recommends xterm -y
    # # 字体选用："Noto Sans CJK SC Regular"
    # # apt-get install --no-install-recommends lxterminal -y
    # # apt-get install xfce4-terminal -y


    # # echo2apk '正在安装 gcc make pkg-config'
    # # apt-get install gcc make -y


    # =================================================================



    echo2apk '正在安装图形显示环境(约10分钟)'

    setup_lang

    export DEBIAN_FRONTEND=noninteractive
    install_sw --no-install-recommends xvfb
    exit_if_fail $? "xvfb 安装失败，请使用手机流量网络，或者断开wifi，并忽略已连接的wifi、然后输入密码重新连接，然后再重新打开虚拟电脑"

    # install_sw tigervnc-standalone-server tigervnc-common tigervnc-tools
    # exit_if_fail $? "tigervnc 安装失败，请使用手机流量网络，或者断开wifi，并忽略已连接的wifi、然后输入密码重新连接，然后再重新打开虚拟电脑"

    install_sw --no-install-recommends libx11-dev libxdamage-dev libxtst-dev libxfixes-dev
    exit_if_fail $? "xserver 扩展组件 安装失败"

    install_sw --no-install-recommends jwm
    exit_if_fail $? "jwm 安装失败"

    install_sw                         pcmanfm libfm-modules
    exit_if_fail $? "pcmanfm 安装失败"

    install_sw --no-install-recommends l3afpad curl lxterminal gxmessage yad x11-xserver-utils xfonts-100dpi
    exit_if_fail $? "gxmessage 安装失败"

    ln -sf /usr/bin/lxterminal /usr/bin/cmd
    exit_if_fail $? "cmd 安装失败"

    ln -sf /usr/bin/l3afpad /usr/bin/notepad
    exit_if_fail $? "notepad 安装失败"

    # 剪贴板依赖
    install_sw xclip
    exit_if_fail $? "xclip 安装失败"

    if [ "${SETUP_MIN_GUI}" == "" ]; then
        install_sw inetutils-telnet
        install_sw gnome-themes-standard
        install_sw elementary-xfce-icon-theme
        install_sw gnome-themes-extra		# ubuntu-23.4 需要手动安装 Adwaita 样式
        install_sw dbus-x11 sudo xdg-utils man-db lxtask
        install_sw gvfs
        install_sw at-spi2-core
        install_sw wget	vim					# 下载工具，不支持https
        install_sw command-not-found
        install_sw openssh-server
        install_sw libgtk-3-dev
        exit_if_fail $? "libgtk-3-dev 安装失败"

        # install_sw aria2					# 下载工具, 支持https，不稳定，经常有用户在使用软件管家安装软件时aria2下载失败
        install_sw axel
        install_sw nomacs					# 图片查看器
        # install_sw gjs
        install_sw socat
        exit_if_fail $? "socat 安装失败"
    fi

    if [ "${LINUX_DISTRIBUTION}" == "debian" ]; then
        install_sw python3-gi
        exit_if_fail $? "python3-gi 安装失败"

    fi

    apt-get update

    # sudo -u droidvm ${tools_dir}/vm_copy_xconfig_files.sh
    # export force_copy_xconf_files=1
    # source ${tools_dir}/vm_configx.sh
    cp -f ${app_home}/doc/firsttime_bootmsg.txt /tmp/firsttime_bootmsg.txt

    install_patchs

    apt-get clean
    echo2apk '安装已完成，请重新打开app'

else
    echo "错误！你必须使用root权限运行此脚本"
fi
