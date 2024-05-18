#!/bin/bash

# 设置控制台窗口的标题栏
PS1=$PS1"\[\e]0;安装box\a\]"


box86Path=`which box86 2>>/dev/null`
box64Path=`which box64 2>>/dev/null`

if [ "${box86Path}" != "" ] && [ "${box64Path}" != "" ]; then
      gxmessage -title "提示" "box86/64已安装，继续安装将会覆盖现在有版本，确定要继续吗？"  -center -buttons "确定:1,取消:0"
      if [ $? -ne 1 ]; then
            exit 0
      fi
fi

curr_arch=`uname -m`
if [ "${curr_arch}" != "aarch64" ]; then
    gxmessage -title "信息" "当前非arm64架构，box不能运行，无需安装！"  -center
    exit 0
fi



function exit_if_fail() {
    rlt_code=$1
    fail_msg=$2
    if [ $rlt_code -ne 0 ]; then
      echo "\n错误码: ${rlt_code}, ${fail_msg}"
      read -s -n1 -p "按任意键退出"
      exit $rlt_code
    fi
}

echo "正在安装box, 需往系统可执行目录写入文件"
echo "请输入密码进行授权"
echo "当前账户的密码默认是:droidvm"
sudo echo "正在安装box86和box64"

echo ""                                                         > /tmp/msg.txt
echo "请注意："                                                 >>/tmp/msg.txt
echo "将从私人发布的apt软件仓库下载box86和box64，是否继续？"    >>/tmp/msg.txt
echo "这个私人网站极不稳定，经常不能访问，导致无法下载安装"     >>/tmp/msg.txt
echo "若碰上这种情况，可以双击桌面的\"编译box\"，进行编译安装"  >>/tmp/msg.txt
echo ""                                                         >>/tmp/msg.txt
echo "box86/64的虚拟电脑中的编译过程, 总耗时也不过15分钟左右"   >>/tmp/msg.txt
echo ""                                                         >>/tmp/msg.txt
gxmessage -title "请确认" -file /tmp/msg.txt  -center -buttons "继续安装:1,取消安装:0"
if [ $? -ne 1 ]; then
    exit 0
fi
echo "将从私人发布的apt仓库下载box86和box64!"


echo "deb https://itai-nelken.github.io/weekly-box86-debs/debian/ ./" > /etc/apt/sources.list.d/box86.list
echo "deb https://ryanfortner.github.io/box64-debs/debian         ./" > /etc/apt/sources.list.d/box64.list

wget https://itai-nelken.github.io/weekly-box86-debs/debian/KEY.gpg -O tmp_key_32.gpg
wget https://ryanfortner.github.io/box64-debs/KEY.gpg               -O tmp_key_64.gpg

echo "正在导入仓库访问密钥"
rm -rf /etc/apt/trusted.gpg.d/box86-debs-archive-keyring.gpg
rm -rf /etc/apt/trusted.gpg.d/box64-debs-archive-keyring.gpg
cat tmp_key_32.gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/box86-debs-archive-keyring.gpg
cat tmp_key_64.gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/box64-debs-archive-keyring.gpg

echo "正在刷新可下载软件列表..."
sudo apt update

echo "正在安装box86..."
sudo apt install box86 -y
exit_if_fail $? "box86安装失败"


echo "正在安装box64..."
sudo apt install box64 -y
exit_if_fail $? "box64安装失败"


echo "正在启用 multi-arch ..."
sudo dpkg --add-architecture armhf && sudo apt-get update

echo "正在安装 arm32版libc6 ..."
sudo apt install libc6:armhf -y

box86 -v
box64 -v


which wine >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo ""                                         > /tmp/msg.txt
    echo "检测到wine已经安装，是否现在启动wine？"   >>/tmp/msg.txt
    echo "提示：第一次启动wine会非常慢"             >>/tmp/msg.txt
    gxmessage -title "提示" -file /tmp/msg.txt -center -buttons "启动:1,取消:0"
    if [ $? -eq 1 ]; then
        WINEARCH=win64 /usr/local/bin/box64 wine64 explorer
        # WINEARCH=win64 /usr/local/bin/box64 wine64 /sdcard/winrar-x64-621scp.exe
    fi
fi


echo "box86/64安装完成."
gxmessage -title "提示" "box86/64安装完成."  -center
# read -s -n1 -p "按任意键继续 ... "
