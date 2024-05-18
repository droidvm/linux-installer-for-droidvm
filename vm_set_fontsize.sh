#!/bin/bash

new_font_size=$1

if [ "$new_font_size" == "" ]; then
    new_font_size=18
fi


# jwm，替换所有匹配到的行
sed -i "s/-[0-9]*<\/Font>/-${new_font_size}<\/Font>/g"  ~/.jwmrc

# pcmanfm，，只替换匹配到的第一行
sed -i "s/ [0-9]\+/ ${new_font_size}/"  ~/.config/pcmanfm/default/desktop-items-0.conf

# lxterminal，只替换匹配到的第一行
sed -i "s/ [0-9]\+/ ${new_font_size}/"  ~/.config/lxterminal/lxterminal.conf

# gtk
sed -i "s/ [0-9]\+/ ${new_font_size}/"  ~/.config/gtk2/gtk_font.rc


# 重启桌面程序
jwm -restart
/exbin/tools/vm_refresh.sh
