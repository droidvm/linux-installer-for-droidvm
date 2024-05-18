#!/bin/bash

my_USERNAME=`whoami`
my_desktop_dir=/root/Desktop
files_for_msg=
files_for_del=

if [ -z "$1" ]; then
    exit 0
fi

if [ "$UID" != "0" ]; then
    my_desktop_dir="/home/${my_USERNAME}/Desktop"
fi


index=1
for arg in $*
do
    if [[ $my_desktop_dir == $arg* ]]; then
        continue
    fi

    # echo "arg: $index = $arg"
    if [ "${files_for_msg}" == "" ]; then
        files_for_msg=${arg}
    else
        files_for_msg="${files_for_msg}
${arg}"
    fi

    files_for_del="${files_for_del} ${arg}"

    let index+=1
done

if [ "${files_for_del}" == "" ]; then
    gxmessage -title "错误" "没有选中待删除的文件，或不能删除 ${my_desktop_dir}"  -center
    exit 0
fi

msg_header="确定要删除以下文件吗？
"
msg_footer="
"

gxmessage -title "提示" "${msg_header}${files_for_msg}${msg_footer}"  -center -buttons "确定:1,取消:0"
if [ $? -eq 1 ]; then
    rm -rf ${files_for_del}
fi
