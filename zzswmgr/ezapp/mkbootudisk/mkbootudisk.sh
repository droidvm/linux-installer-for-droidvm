#!/bin/bash

# export DIR_SCRIPT=`dirname $0` # 这个不准确
export DIR_SCRIPT=$(dirname $(realpath $0))
export DIR_QLinux=/opt/apps/qemu-linux-amd64
export DIR_SHARED="${DIR_SCRIPT}/shared"

function exit_if_fail() {
    rlt_code=$1
    fail_msg=$2
    if [ $rlt_code -ne 0 ]; then
      echo -e "错误码: ${rlt_code}\n${fail_msg}"
      read -s -n1 -p "按任意键退出"
      exit $rlt_code
    fi
}

PROMPTED=0
function scan_udisk_path() {
    echo "正在重新识别U盘"
    for num in {1..120}  
    do  
        sleep 1
        sync
        path2udisk=`. /etc/autoruns/autoruns_after_gui/map_otg_udisk.sh|tail -n 1`

        if [ -d "${path2udisk}" ]; then
            echo "第${num}次扫描后识别到格式化的U盘"
            break
        else
            path2udisk="/未识别到U盘"
        fi

        if [ $PROMPTED -ne 1 ] && [ $num -ge 10 ]; then
            PROMPTED=1
            echo ""							    > /tmp/msg.txt
            echo "未重新识别到格式化后的U盘"	>>/tmp/msg.txt
            echo ""							    >>/tmp/msg.txt
            echo "请拨出U盘，并等待两秒钟"      >>/tmp/msg.txt
            echo "重新插入U盘后，请点击ok"	    >>/tmp/msg.txt
            echo ""							    >>/tmp/msg.txt
            gxmessage -title "拨出U盘重新插入" -file /tmp/msg.txt -center
        fi

    done
}

if [ ! -d "${DIR_QLinux}" ]; then
    echo ""							> /tmp/msg.txt
    echo "请先安装qemu-linux-amd64"	>>/tmp/msg.txt
    echo ""							>>/tmp/msg.txt
    gxmessage -title "提示" -file /tmp/msg.txt -center
    exit 1
fi

# echo "制作U盘启动盘，需要对U盘进行重新分区"
# echo -e "这会 [[[ \e[96m清掉U盘中的所有数据\e[0m ]]]"
# echo "如需要继续请按1，按其它键取消"
# read -t 180 readrlt
# echo "您已输入: |$readrlt|"

# if [ "${readrlt}" != "1" ]; then
# 	echo "已取消"
# 	exit 6
# fi

echo ""                                                         > /tmp/msg.txt
echo "制作U盘启动盘，需要对U盘进行重新分区"                     >>/tmp/msg.txt
echo "这会清掉U盘中的所有数据，确定要继续吗？"                  >>/tmp/msg.txt
echo ""                                                         >>/tmp/msg.txt
echo "提示："                                                   >>/tmp/msg.txt
echo " 先连接U盘等安卓识别到U盘后再启动虚拟电脑"                >>/tmp/msg.txt
echo " 可以降低出错的机率"                                      >>/tmp/msg.txt
echo ""                                                         >>/tmp/msg.txt
gxmessage -title "请确认" -file /tmp/msg.txt   -center -buttons "继续:1,取消:0"
if [ $? -ne 1 ]; then
        exit 0
fi

# if [ ! -r /sdcard ]; then
#     echo "正在申请访问外接U盘的权限"
#     ${tools_dir}/vm_req_sdcard.sh
# fi

# 复制winpe文件到qemu共享目录
# echo "正在复制 winpe压缩包到到qemu共享目录. . ."
# cp -f ${DIR_SCRIPT}/winpe.zip ${DIR_SHARED}/winpe.zip
# exit_if_fail $? "winpe压缩包复制失败"
mkdir -p  ${DIR_SHARED}/winpe 2>/dev/null
unzip -oq ${DIR_SCRIPT}/winpe.zip -d ${DIR_SHARED}/winpe
exit_if_fail $? "winpe压缩包解压失败"

mkdir -p ${DIR_SHARED}/winpe/boot/freedos 2>/dev/null
unzip -oq ${DIR_SCRIPT}/freedos_x86_fat32.zip -d ${DIR_SHARED}/winpe/boot/freedos/
exit_if_fail $? "freedos压缩包解压失败"

cp -f ${DIR_SCRIPT}/freedos-tools/*  ${DIR_SHARED}/winpe/boot/freedos/bin/
exit_if_fail $? "freedos工具包复制失败"

cp -f ${DIR_SHARED}/winpe/boot/freedos/bin/autoexec.bat ${DIR_SHARED}/winpe/autoexec.bat
cp -f ${DIR_SHARED}/winpe/boot/freedos/bin/config.sys   ${DIR_SHARED}/winpe/config.sys


echo "正在启动qemu，虚拟电脑需要通过qemu+usbip的方式来格式化U盘"
FORMAT_RLT=fail
mkdir -p ${DIR_SHARED} 2>/dev/null
rm -rf ${DIR_SHARED}/autorun.rlt
cp -f ${DIR_SCRIPT}/fotmat_udisk_via_qemu.sh ${DIR_SHARED}/autorun.sh
chmod a+x ${DIR_SHARED}/*.sh
${DIR_QLinux}/qemu-linux-amd64.sh ${DIR_SHARED}

if [ -f ${DIR_SHARED}/autorun.rlt ]; then
    . ${DIR_SHARED}/autorun.rlt
fi


echo "U盘分区及格式化结果：${FORMAT_RLT}"

if [ "${FORMAT_RLT}" != "OK" ]; then
    exit_if_fail 7 "U盘格式化失败"
fi

sync
exit_if_fail $? "制作失败，无法sync"

if [ 0 -eq 1 ]; then
    echo "部分手机不能在apk中直接访问U盘，所以不可以在apk中直接解压！！！！还是得在qemu中做这个动作"
    # scan_udisk_path

    # sleep 10

    # scan_udisk_path

    # echo "识别到安卓端的U盘路径：|${path2udisk}|"
    # if [ ! -d "${path2udisk}" ] || [ ! -w "${path2udisk}" ]; then
    #     exit_if_fail 8 "U盘分区及格式化已完成，但无法向格式化后的U盘写入WINPE启动文件"
    # fi

    # cd "${path2udisk}"
    # exit_if_fail $? "无法进入U盘目录"

    # rm -rf ./Android
    # rm -rf ./LOST.DIR
    # rm -rf ./Movies
    # rm -rf ./Music
    # rm -rf ./Pictures


    # echo "正在复制 winpe 启动文件"
    # echo "正在解压. . ."
    # unzip -oq ${DIR_SCRIPT}/winpe.zip -d ${path2udisk}
    # exit_if_fail $? "winpe文件解压失败"

    # sync
    # exit_if_fail $? "winpe文件复制失败"
fi

echo ""
echo ""
echo "启动U盘已制作完成"
echo "如果需要，您可以使用如下指令来调用qemu对启动U盘进行启动测试："
echo "sudo qemu-system-i386 -hda /dev/sdc"
echo "\"D:\\Program Files\\qemu\\qemu-system-x86_64.exe\" -m 768  -hda \\\\.\\PhysicalDrive2"

echo ""                                                                     > /tmp/msg.txt
echo "启动U盘已制作完成。"                                                  >>/tmp/msg.txt
echo ""                                                                     >>/tmp/msg.txt
echo "winpe启动文件只使用了U盘第一个分区，U盘第二个分区你可以放其它文件"    >>/tmp/msg.txt
# echo "winpe启动文件只使用了U盘第一个分区，U盘第二个分区未格式化"          >>/tmp/msg.txt
# echo "如果需要，您可以在启动到winpe环境后对U盘第二个分区进行格式化"       >>/tmp/msg.txt
echo ""                                                                     >>/tmp/msg.txt
echo "新分区中的Android、music等文件夹是安卓强制创建的，可以删除"           >>/tmp/msg.txt
echo "ghost等工具在U盘 ExTools 目录中"                                      >>/tmp/msg.txt
echo ""                                                                     >>/tmp/msg.txt
gxmessage -title "提示" -file /tmp/msg.txt  -center
