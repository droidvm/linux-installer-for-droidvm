#!/bin/bash

gui_title="图标风格设置"

selecteditem=`ls -1 /usr/share/icons/|yad --title="${gui_title}" --text="\n请从系统已安装的图标中选用一个:\n" \
--button="确定:0"  --button="取消:1" --list --column="图标名称" --width=600 --height=800 --print`
ret=$?
if [ $ret -ne 0 ]; then exit 0; fi

selecteditem=${selecteditem%?}

if [ "${selecteditem}" == "" ]; then
    gxmessage -title "${gui_title}" "未选中要使用的图标名称"  -center
    exit 0
fi

# rm -rf ~/.icons/
# cp -f "/usr/share/icons/${selecteditem}"  ~/.icons

echo "gtk-icon-theme-name = \"${selecteditem}\"" > ~/.config/gtk2/gtk_icon.rc

${tools_dir}/vm_refresh.sh
