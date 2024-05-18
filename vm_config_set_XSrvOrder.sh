#!/bin/bash

action=$1

gui_title="XServer优先设置"

if [ "$action" == "" ]; then
	action="Xvfb xlorie"
fi

echo "$action">${DirGuiConf}/xserver_order.txt
gxmessage -title "${gui_title}" "XServer优先级已设置为 ${action}  ，重启生效"  -center
