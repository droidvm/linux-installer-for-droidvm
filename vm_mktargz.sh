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

which tar >/dev/null 2>&1
if [ $? -ne 0 ]; then
    gxmessage -title "错误" "请先安装 tar，或者EGzip"  -center
    exit 1
fi


# if [ "$UID" != "0" ]; then
#     my_desktop_dir="/home/${my_USERNAME}/Desktop"
# fi


index=1
for arg in $*
do
    # if [[ $my_desktop_dir == $arg* ]]; then
    #     continue
    # fi

    if [ $index -eq 1 ]; then
        dir_parent=`dirname  ${arg}`
        # dir_parent=`dirname /home/droidvm/Desktop/软件/qemu.desktop`
        zip_name=`basename ${dir_parent}`
        if [ "${zip_name}" == "" ]; then
            zip_name=tmp
        fi
        if [ "${zip_name}" == "/" ]; then
            zip_name=tmp
        fi
        zip_name=${zip_name}.tar.gz
        echo "父级目录：${dir_parent}">>${log_file}
        echo "压缩文件：${zip_name}"  >>${log_file}
    fi

    # echo "arg: $index = $arg"
    arg=${arg//${dir_parent}\//}
    if [ "${files_for_msg}" == "" ]; then
        files_for_msg=${arg}
    else
        files_for_msg="${files_for_msg}
${arg}"
    fi

    files_for_zip="${files_for_zip} ${arg}"

    let index+=1
done

if [ "${files_for_zip}" == "" ]; then
    gxmessage -title "错误" "请选中要压缩的文件"  -center
    exit 0
fi

echo ${files_for_msg}>>${log_file}

# zip -r ${zip_name} ${files_for_zip}

tar -czf ${zip_name} ${files_for_zip}
