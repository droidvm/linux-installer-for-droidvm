#!/bin/bash

gui_title="启动输入法"
logfile=/tmp/start_fcitx.log

# echo "">${logfile}

function start_fcitx() {
    echo "正在启动 中文输入法"
    # export XMODIFIERS=@im=fcitx
    # export GTK_IM_MODULE=fcitx
    # export QT_IM_MODULE=fcitx
    # export SDL_IM_MODULE=fcitx

    # # 已移到 def_run_once.sh
    # # dbus-uuidgen > /var/lib/dbus/machine-id
    fcitx >> $logfile 2>&1 &
    exit 0
}

# command -v fcitx && start_fcitx

function start_fcitx5() {
    echo "正在启动 中文输入法"
    # export XMODIFIERS=@im=fcitx
    # export GTK_IM_MODULE=fcitx
    # export QT_IM_MODULE=fcitx
    # export SDL_IM_MODULE=fcitx

    # # 已移到 def_run_once.sh
    # # dbus-uuidgen > /var/lib/dbus/machine-id
    fcitx5 >> $logfile 2>&1 &
    exit 0
}


# if [ "${APP_LANGUAGE}_${APP_COUNTRY}" == "zh_CN" ]; then
#	command -v fcitx && start_fcitx
# fi

command -v fcitx  && start_fcitx
command -v fcitx5 && start_fcitx5

gxmessage -title "${gui_title}" "输入法启动失败，请先在软件管家中安装输入法"  -center
