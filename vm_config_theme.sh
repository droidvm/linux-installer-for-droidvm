#!/bin/bash

gui_title="主题风格设置"

selecteditem=`ls -1 /usr/share/themes/|yad --title="${gui_title}" --text="\n请从系统已安装的主题中选用一个:\n" \
--button="确定:0"  --button="取消:1" --list --column="主题名称" --width=600 --height=800 --print`
ret=$?
if [ $ret -ne 0 ]; then exit 0; fi

selecteditem=${selecteditem%?}

if [ "${selecteditem}" == "" ]; then
    gxmessage -title "${gui_title}" "未选中要使用的主题名称"  -center
    exit 0
fi

echo "gtk-theme-name = \"${selecteditem}\"" > ~/.config/gtk2/gtk_theme.rc

echo "${selecteditem}">${PATH_GTK_THEME_NAME}

${tools_dir}/vm_refresh.sh
