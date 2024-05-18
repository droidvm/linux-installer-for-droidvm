#!/bin/bash

new_uimode=$1
restartX11=$2

if [ "${new_uimode}" == "" ]; then
    new_uimode=phone
fi

. ${tools_dir}/vm_getuimode.rc
old_uimode=${uimode}
if [ "$old_uimode" != "" ]; then
    ${tools_dir}/vm_xconfig_files_bakup.sh
fi


if [ "${new_uimode}" == "pc" ]; then
    echo ""                                                         > /tmp/msg.txt
    echo "切换到电脑模式后，手机上看到的字体非常小"                 >>/tmp/msg.txt
    echo "主要用于手机外接显示器或无线投屏的情况，确定要继续吗？"   >>/tmp/msg.txt
    echo ""                                                         >>/tmp/msg.txt
    gxmessage -title "请确认" -file /tmp/msg.txt   -center -buttons "确定:1,取消:0"
    if [ $? -ne 1 ]; then
            exit 0
    fi
fi


echo ${new_uimode}>${PATHUIMODE}

export force_copy_xconf_files=1
${tools_dir}/vm_xconfig_files_apply.sh

if [ "$restartX11" != "" ]; then
    echo "UI模式已变更,正在重启图形界面"
    ${tools_dir}/vm_startx.sh xserver
fi


# 【【 警告 】】
# 【【 警告 】】
# 【【 警告 】】
# 【【 警告 】】下面这一句用在这个文件里面，没必要，而且当处于X11桌面转发时，会导致闪退！！！！
# 【【 警告 】】后续都不要在这个文件中启用这行代码
# echo "#controllernewfb ${RECOMMEND_SCREEN_WIDTH} ${RECOMMEND_SCREEN_HEIGHT}" > ${NOTIFY_PIPE}
