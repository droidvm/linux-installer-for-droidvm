#!/bin/bash

natshell_addr=124.221.123.125
natshell_port=7000

command -v natshell >/dev/null 2>&1
if [ $? -ne 0 ]; then
	gxmessage -title "错误"     $'\n远程协助启动失败，版本号1.03或1.03以上的虚拟电脑才支持远程协助\n\n'  -center -fg red
	exit
fi

cd ~
natshell ${natshell_addr} ${natshell_port}
if [ $? -ne 0 ]; then
	gxmessage -title "错误"     $'\n远程协助启动失败，请联系开发人员\n\n'  -center -fg red
fi
