#!/bin/bash

sectimeout=600
adbport=1111

canceled=0
function adb_pair() {
    while true
    do
        # userinput=`yad --width=400 --title="" --text="${fail_msg}\n\n正在连接本设备\n请确保本设备的wifi调试开关已打开!\n\n请输入wifi-adb的匹配参数："                           # --form                                # --field="配对码":NUM                               # --field="配对端口":NUM
        # `
        # canceled=$?
        # if [ $canceled -ne 0 ]; then exit; fi
        # paircode=`echo $userinput|awk -v FS="|" '{print $1}'`
        # pairport=`echo $userinput|awk -v FS="|" '{print $2}'`
        # connport=`echo $userinput|awk -v FS="|" '{print $3}'`
        # echo "paircode: $paircode"
        # echo "pairport: $pairport"
        # echo "connport: $connport"
        
        echo -n "请输入匹配码："
        read -t ${sectimeout} paircode
        canceled=$?
        if [ $canceled -ne 0 ]; then exit; fi
        
        echo -n "请输入匹配码验证端口号："
        read -t ${sectimeout} pairport
        canceled=$?
        if [ $canceled -ne 0 ]; then exit; fi
        
        adb pair 127.0.0.1:$pairport $paircode
        if [ $? -ne 0 ]; then
            fail_msg="设备匹配失败，可能是匹配码或匹配端口错误"
            echo adb 安装失败
            continue
        else
            # gxmessage -title "提示" "adb匹配成功"  -center
            break
        fi
    done
}

function adb_connect() {
    while true
    do
        # userinput=`yad --width=400 --title="" --text="${fail_msg}\n\n请输入wifi-adb连接端口"                           # --form                                # --field="连接端口":NUM
        # `
        # canceled=$?
        # if [ $canceled -ne 0 ]; then exit; fi
        # connport=$userinput
        
        echo -n "请输入连接端口："
        read -t ${sectimeout} connport
        canceled=$?
        if [ $canceled -ne 0 ]; then exit; fi
        echo "connport: $connport"
        
        adb connect 127.0.0.1:$connport
        if [ $? -ne 0 ]; then
            fail_msg="设备连接失败，可能是连接端口错误"
            echo adb 安装失败
            continue
        else
            # gxmessage -title "提示" "adb连接成功"  -center
            break
        fi
    done
}

function print_succ_msg() {
    echo -e "\e[96m已解除安卓对单个应用进程数量的限制（设置为 ${max_phantom_processes}个）\e[0m"
    echo -e "(重启手机这个设置便会失效, 所以重启手机后需要重新解除限制)"
    echo -e ""
    echo -e "\e[96m请! 尽! 快! \e[0m关闭开发者选项，特别是其中的USB调试开关！"
    echo -e "\e[96m请! 尽! 快! \e[0m关闭开发者选项，特别是其中的USB调试开关！"
    echo -e "\e[96m请! 尽! 快! \e[0m关闭开发者选项，特别是其中的USB调试开关！"
    echo ""
    echo -e "\e[96mUSB调试通道\e[0m有很高的权限，不会用将\e[96m非常危险！\e[0m"
    echo -e "\e[96mUSB调试通道\e[0m可读取短信、联系人、电话拨打记录，安装应用..."
    echo -e ""
}

function adb_get_max_phantom_processes() {
    max_phantom_processes=`adb shell dumpsys activity settings | grep max_phantom_processes|awk -v FS="=" '{print $2}'`
    if [ "$max_phantom_processes" == "" ]; then
        max_phantom_processes=32
    fi
}

function adb_set_max_phantom_processes() {
    adb_get_max_phantom_processes
    if [ $max_phantom_processes -gt 2048 ]; then
        print_succ_msg
        return
    fi
    
    echo "正在解除应用进程数量的限制，当前限制为：${max_phantom_processes}个"
    adb shell device_config set_sync_disabled_for_tests persistent
    adb shell device_config put activity_manager max_phantom_processes 65536
    adb_get_max_phantom_processes
    if [ $max_phantom_processes -gt 2048 ]; then
        print_succ_msg
        return
    else
        echo -e "\e[96m应用的进程数据限制解除失败！\e[0m"
    fi
}

echo "正在启动adb-server"
adb shell pwd >/dev/null 2>&1
sleep 1
adb shell pwd >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "正在重连远端adbd"
    adb connect 127.0.0.1:${adbport}|grep connected
    if [ $? -ne 0 ]; then
        echo "adb连接失败，需要输入匹配码重新匹配。"
        echo ""
        echo -e "\e[96madb连接的步骤，请按步骤操作：\e[0m"
        echo " 1). 将手机连接到wifi网络，可以是热点网络"
        echo " 2). 在手机设置的关于本机界面中，启用手机的 \"开发者选项\""
        echo "     (连点10次设置中的 \"版本号\")"
        echo -e "     \e[96m警告：\e[0m"
        echo "     \"开发者选项\" 启用后有被偷录屏幕、恶意安装app等风险"
        echo "     解除完进程数限制后，您应该尽快关闭开发者选项！"
        echo " 3). 在虚拟电脑中，打开桌面上的 ADBme"
        echo "     提示输入匹配码时，才能继续下一步操作"
        echo " 4). 在手机上，将虚拟电脑浮窗化运行(不要关闭)"
        echo " 5). 在手机上，打开无线调试界面，获取匹配码和验证端口号"
        echo " 6). 在手机上，点击虚拟电脑底部任意按钮，弹出屏幕键盘"
        echo "     输入匹配码和验证端口"
        echo "     如果是设备自连，"
        echo "     则在匹配成功之前，不能关闭手机上弹出的匹配码"
        echo " 7). 匹配完成后，再输入adb连接端口号"
        echo ""
        
        adb_pair
        adb_connect
        
        echo "正在设置固定连接端口号: ${adbport}"
        adb tcpip ${adbport}
        adb disconnect
        sleep 0.1
        adb connect 127.0.0.1:${adbport}
    fi
fi

adb_set_max_phantom_processes
adb shell
# adb disconnect
