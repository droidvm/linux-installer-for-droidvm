#!/bin/bash

# 设置控制台窗口的标题栏
PS1=$PS1"\[\e]0;安装xfce4\a\]"


which startxfce4 >/dev/null 2>&1
if [ $? -eq 0 ]; then
    gxmessage -title "提示" $'\nxfce4已安装过\n若需切换回jwm，请运行如下指令：\necho "0" > ${app_home}/app_boot_config/cfg_use_xfce4.txt\n'  -center
    exit 0
fi


echo "正在安装xfce4, 需往系统可执行目录写入文件"
echo "请输入密码进行授权"
echo "当前账户的密码默认是:droidvm"
sudo echo ""

function exit_if_fail() {
    rlt_code=$1
    fail_msg=$2
    if [ $rlt_code -ne 0 ]; then
      echo "\n错误码: ${rlt_code}, ${fail_msg}"
      read -s -n1 -p "按任意键退出"
      exit $rlt_code
    fi
}


sudo apt install -y --no-install-recommends xfce4
exit_if_fail $? "xfce4安装失败"


echo "1" > ${app_home}/app_boot_config/cfg_use_xfce4.txt

echo "xfce4安装完成."
gxmessage -title "提示" "xfce4安装完成, 要现在启动xfce4吗？"  -center  -buttons "确定:1,取消:0"
if [ $? -eq 1 ]; then
  /exbin/tools/vm_startx.sh xwinman
fi
