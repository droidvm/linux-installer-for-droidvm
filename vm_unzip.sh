#!/bin/bash

my_USERNAME=`whoami`
my_desktop_dir=/root/Desktop
files_for_msg=
files_for_zip=
dir_work=`pwd`
log_file=/tmp/msg.txt


echo "工作目录：${dir_work}">${log_file}

if [ -z "$1" ]; then
    exit 0
fi

which unzip >/dev/null 2>&1
if [ $? -ne 0 ]; then
    gxmessage -title "错误" "请先在软件管家中安装 zip_unzip"  -center
    exit 1
fi


index=1
for arg in $*
do

	unzip -oq ${arg} -d ./

    let index+=1
done
