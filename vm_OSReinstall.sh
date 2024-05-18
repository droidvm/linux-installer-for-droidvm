#!/bin/bash

gxmessage -title "确定要重装系统吗？" "请注意，若确定要重装，当前系统的文件将全部被删除，且不可恢复"  -center -buttons "我确定:1,取消:0"
if [ $? -eq 1 ]; then
    rm -rf ${tools_dir}/startvm.sh
    gxmessage -title "重新安装系统" "重新安装系统的标志已创建, 下次启动时生效"  -center
fi
