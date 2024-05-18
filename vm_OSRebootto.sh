#!/bin/bash

: '
在安卓终端手动恢复
cp -rf ./vm/ubuntu-arm64/etc/droidvm/bootup_scripts/* ./

'

LINUX_DIR=$1

if [ "$CONSOLE_ENV" == "android" ]; then
    echo "app_home:${app_home}"
	source droidvm_vars.sh
fi


if [ "${LINUX_DIR}" == "" ] || [ "${LINUX_DIR}" == "-h" ]; then
    echo "已安装的系统如下，请以下列目录名中的一个作为参数运行此脚本"
    ls -1 ${app_home}/vm/
else
    source ${app_home}/droidvm_vars_setup.sh

    if [ "${LINUX_DIR}" == "setup" ]; then
            if [ "${vmGraphicsx}" == "1" ]; then
                gxmessage -title "确定要重启以安装其它系统吗？" $'请注意重装过程中不要覆盖到当前系统\n否则当前系统的文件将全部被删除，且不可恢复\n'  -center -buttons "我确定:1,取消:0"
                if [ $? -eq 1 ]; then
                        rm -rf ${tools_dir}/startvm.sh
                        sleep 1
						# touch /tmp/req_reboot
                        # echo "#reboot" > "${NOTIFY_PIPE}"
                        reboot
                fi
            else
                        rm -rf ${tools_dir}/startvm.sh
                        sleep 1
						# touch /tmp/req_reboot
                        # echo "#reboot" > "${NOTIFY_PIPE}"
                        reboot
            fi
    else
        LINUX_DIR=${app_home}/vm/${LINUX_DIR}

        if [ -d   ${LINUX_DIR} ]; then
            if [ "${vmGraphicsx}" == "1" ]; then
                gxmessage -title "请确认" "确定要重启到 ${LINUX_DIR} 吗？"  -center -buttons "确定:1,取消:0"
                if [ $? -eq 1 ]; then
                            cp -f ${LINUX_DIR}/etc/droidvm/bootup_scripts/*                 ${app_home}
                        if [ -d   ${LINUX_DIR}/etc/droidvm/bootup_scripts/tools ]; then
                            cp -f ${LINUX_DIR}/etc/droidvm/bootup_scripts/tools/startvm.sh  ${tools_dir}
                        fi
                        sleep 1
						# touch /tmp/req_reboot
                        # echo "#reboot" > "${NOTIFY_PIPE}"
                        reboot
                fi
            else
                            cp -f ${LINUX_DIR}/etc/droidvm/bootup_scripts/*                 ${app_home}
                        if [ -d   ${LINUX_DIR}/etc/droidvm/bootup_scripts/tools ]; then
                            cp -f ${LINUX_DIR}/etc/droidvm/bootup_scripts/tools/startvm.sh  ${tools_dir}
                        fi
                        sleep 1
						# touch /tmp/req_reboot
                        # echo "#reboot" > "${NOTIFY_PIPE}"
                        reboot
            fi
        else
            if [ "${vmGraphicsx}" == "1" ]; then
                gxmessage -title "失败" "目录不存在：${LINUX_DIR}"  -center
            else
                echo "目录不存在：${LINUX_DIR}"
            fi
        fi
    fi
fi
