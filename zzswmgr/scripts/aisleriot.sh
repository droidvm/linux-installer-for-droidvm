#!/bin/bash

SWNAME=aisleriot

action=$1
if [ "$action" == "" ]; then action=安装; fi

# pwd
. ./scripts/common.sh

if [ "${action}" == "卸载" ]; then
	sudo apt-get remove -y ${SWNAME}
else
	sudo apt-get install -y --no-install-recommends ${SWNAME}
  exit_if_fail $? "${SWNAME} 安装失败"

  gxmessage -title "提示" "安装完成，请查看桌面上的软件目录"  -center
fi
