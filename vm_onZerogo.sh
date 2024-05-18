#!/bin/bash

# normal_start | sresize | xserver | xwinman
action=$1


DIR_AUTO_RUN=/exbin/autoruns
if [ -d ${DIR_AUTO_RUN} ]; then

    echo ""
    echo "系统启动完成，正在运行 ${DIR_AUTO_RUN} 目录中的脚本"
    for i in ${DIR_AUTO_RUN}/*.sh; do
        if [ -r $i ]; then
            echo "calling ${i}"
            . $i
        fi
    done
    unset i
fi


# echo2apk "系统已启动，若需要添加自启动代码，请修改 \${tools_dir}/vm_onZerogo.sh "
echo -e "\n\n系统已启动，若需要添加自启动代码，请修改 \${tools_dir}/vm_onZerogo.sh\n\n"
echo "startx action: ${action}(print from vm_onZerogo.sh)"


# ${tools_dir}/vm_fileshare.sh      start 2>&1 &
# ${tools_dir}/vm_telnet_control.sh start 2>&1 &

