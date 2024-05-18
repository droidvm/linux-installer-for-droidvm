#!/bin/bash

action=$1
if [ "$action" == "" ]; then
	action=off
fi

if [ "$action" == "on" ]; then
    echo "#hide_sys_statusbar" > ${NOTIFY_PIPE}
    echo "#hide_btn_panel" > ${NOTIFY_PIPE}
else
    echo "#show_sys_statusbar" > ${NOTIFY_PIPE}
    echo "#show_btn_panel" > ${NOTIFY_PIPE}
fi
