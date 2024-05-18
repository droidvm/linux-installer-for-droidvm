#!/bin/bash

SWNAME=xfce4

action=$1
if [ "$action" == "" ]; then action=安装; fi

# pwd
. ./scripts/common.sh

if [ "${action}" == "卸载" ]; then
	sudo apt-get remove -y ${SWNAME}
else

  gxmessage -title "是否继续安装？" $'\n不建议不熟悉linux环境的新手在虚拟电脑中使用xfce\n\n虚拟电脑集成的所有界面类脚本都是针对jwm+pcmanfm桌面环境整理的\n使用xfce将不能使用虚拟电脑集成的各类便捷脚本\n\n'  -center -buttons "继续安装:0,取消安装:1"
  case "$?" in
    "0")
      :
      ;;
    *) 
      echo "您已取消安装"
      exit 1
      ;;
  esac

	sudo apt-get install -y --no-install-recommends ${SWNAME}
  exit_if_fail $? "xfce4安装失败"
  echo "1" > ${app_home}/app_boot_config/cfg_use_xfce4.txt

  echo "xfce4安装完成."
  gxmessage -title "提示" "xfce4安装完成, 重启生效"  -center

  # gxmessage -title "提示" "xfce4安装完成, 要现在启动xfce4吗？"  -center  -buttons "确定:1,取消:0"
  # if [ $? -eq 1 ]; then
  #   /exbin/tools/vm_startx.sh xwinman
  # fi
fi
