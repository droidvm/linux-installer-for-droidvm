#!/bin/bash

adbport=1111

function _EXIT() {
    read -s -n1 -p "按任意键退出"
    exit $1
}

function open_tcp_adb_for_usbdeivce() {
    iface=""
    /exbin/zzotg 2>/dev/null|grep -v rescode >/tmp/usbdevices
    devices=`cat /tmp/usbdevices`
    dev_count=`cat /tmp/usbdevices|wc -l`
    if [ "$devices" == "" ]; then
        dev_count=0
    fi
    echo "|  devices: $devices|"
    echo "|dev_count: $dev_count|"
    echo ""
    if [ $dev_count -lt 1 ]; then
        echo -e "未识别到可用的otg设备，\\e[96m手机的OTG功能是否已打开？\\e[0m"
        _EXIT -1
    fi
    if [ $dev_count -gt 1 ]; then
        gui_title="请选择USB串口设备"
        iface=`cat /tmp/usbdevices|yad --title="${gui_title}" --text="\n从下列设备中选一个:\n" \\
        --button="确定:0"  --button="取消:1" --list --column="已识别到的设备" --width=800 --height=300 --print`
        ret=$?
        if [ $ret -ne 0 ]; then _EXIT -1; fi
    else
        iface=$devices
    fi
    iface=`echo $iface| awk -v FS="," '{print $1}'`
    echo "已选择的设备：$iface"

        echo "正在映射设备"
        /exbin/zzotg adb $adbport "$iface" $usbcfg >/tmp/mapped_rlt 2>/dev/null
        maprlt=$?
    if [ $maprlt -ne 0 ]; then
        /exbin/zzotg adb $adbport "$iface" $usbcfg >/tmp/mapped_rlt 2>/dev/null
        maprlt=$?
    fi
    if [ $maprlt -ne 0 ]; then
        echo "$iface tcp-adb通道打开失败"
        _EXIT -1
    else
        cat /tmp/mapped_rlt
        _EXIT 0

    fi

}

function helpmsg() {
    echo "通过USB线连入此设备的手机/平板, 此脚本可为其打开tcp-adb通道"
}

helpmsg
open_tcp_adb_for_usbdeivce
