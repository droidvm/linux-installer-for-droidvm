#!/bin/bash
. /etc/autoruns/autoruns_after_gui/map_otg_udisk.sh

if [ "$udisks" != "" ]; then
    exec open $dir_udisk
else
    gxmessage -title "外接U盘" "未识别到外接U盘"  -center
fi
