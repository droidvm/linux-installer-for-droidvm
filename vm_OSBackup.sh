#!/bin/bash

# gxmessage -title "系统备份" "系统备份功能未实现！"  -center
# exit 0

gxmessage -title "请确认" "系统备份需要重启，确定要继续吗？"  -center -buttons "确定:1,取消:0"
if [ $? -eq 1 ]; then
    cp -rf ${tools_dir}/def_backupvm.sh	${tools_dir}/backupvm.sh
	# touch /tmp/req_reboot
    # echo "#reboot" > "${NOTIFY_PIPE}"
    reboot
fi
