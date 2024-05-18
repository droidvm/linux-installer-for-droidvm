#!/bin/bash

if [ ! -r /sdcard ]; then
    echo "正在申请访问外接U盘的权限"
    ${tools_dir}/vm_req_sdcard.sh
fi


if [ -r /sdcard ]; then
    exec open /sdcard
else
    gxmessage -title "手机SD卡" "未识别到手机SD卡，请授权访问后重试"  -center
fi
