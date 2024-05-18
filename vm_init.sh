#!/bin/bash

# /exbin/main_ndk-vulkan-demo1

# echo ""
# echo ""
# echo "init.sh 中的PATH环境变量1"
# echo $PATH
# echo ""
# echo ""

# export app_home=/exbin
# export CONSOLE_ENV=linux

# rm -rf /exbin
# ln -sf $APP_INTERNAL_DIR /exbin

# source /exbin/tools/vm_config.sh
# source /root/.bashrc
source /etc/profile

# echo ""
# echo ""
# echo "init.sh 中的PATH环境变量2"
# echo $PATH
# echo ""
# echo ""

if [ ! -f /linkerconfig/ld.config.txt ]; then
    mkdir -p /linkerconfig 2>/dev/null
    touch /linkerconfig/ld.config.txt
    chmod 766 /linkerconfig/ld.config.txt
fi


# 获取安卓端dns，填到虚拟系统中
. ${tools_dir}/vm_init_dns.sh

if [ -f ${tools_dir}/run_once.sh ]; then
    chmod 777 ${tools_dir}/run_once.sh
    source ${tools_dir}/run_once.sh
# else
#     echo "skip running ${tools_dir}/run_once.sh"
#     ls -al ${tools_dir}/run_once.sh
fi


if [ -f ${tools_dir}/vm_onstarted.sh ]; then
    chmod 777 ${tools_dir}/vm_onstarted.sh
    exec ${tools_dir}/vm_onstarted.sh
else
    exec /bin/bash
fi

