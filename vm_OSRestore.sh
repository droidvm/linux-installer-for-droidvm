#!/bin/bash

LINUX_TAR=imgbak/bak_${CURRENT_OS_NAME}.tar
LINUX_ZIP=${tools_dir}/${LINUX_TAR}.gz

if [ ! -f ${LINUX_ZIP} ]; then
    gxmessage -title "错误" "当前系统未备份过！"  -center
    exit 0
fi

gxmessage -title "请确认" "系统还原需要重启，确定要继续吗？"  -center -buttons "确定:1,取消:0"
if [ $? -eq 1 ]; then
    cp -rf ${tools_dir}/def_restorevm.sh	${tools_dir}/restorevm.sh
	# touch /tmp/req_reboot
    # echo "#reboot" > "${NOTIFY_PIPE}"
    reboot
fi
