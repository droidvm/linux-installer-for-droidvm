#!/bin/bash

action=$1
server_port=8000

tmpfilename=/tmp/enable_webctrl

if [ "$action" == "" ]; then
	action=stop
fi

if [ "$action" == "stop" ]; then
	rm -rf ${tmpfilename}
	/exbin/tools/vm_setuimode.sh phone 1
	exit 0
fi

if [ "${XSRV_NAME}" != "Xvfb" ]; then
	gxmessage -title "错误"     $'\n此功能仅可在XServer为Xvfb的情况下使用\n\n请点击\n 开始使用->显示设置->XServer管理 进行切换\n切换后重试\n\n'  -center
	exit 0
fi

touch ${tmpfilename}
/exbin/tools/vm_setuimode.sh pc    1
