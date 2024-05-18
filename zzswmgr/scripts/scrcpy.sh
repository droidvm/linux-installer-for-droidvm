#!/bin/bash

SWNAME=scrcpy

action=$1
if [ "$action" == "" ]; then action=安装; fi

# pwd
. ./scripts/common.sh

if [ "${action}" == "卸载" ]; then
	sudo apt-get remove -y ${SWNAME}
else
	sudo apt-get install -y ${SWNAME}
  exit_if_fail $? "安装失败"

  echo "安装完成."
  gxmessage -title "提示" "安装完成"  -center
fi
