#!/bin/bash

. ${tools_dir}/vm_getuimode.rc
xconf_dir=${DirGuiConf}/uimode_${uimode}

cp -rf ~/.droidvm                                     ${xconf_dir}/
cp -rf ~/.config/pcmanfm/default/desktop-items-0.conf ${xconf_dir}/.config/pcmanfm/default/desktop-items-0.conf
cp -rf ~/.config/libfm/libfm.conf                     ${xconf_dir}/.config/libfm/libfm.conf
cp -rf ~/.config/lxterminal/lxterminal.conf           ${xconf_dir}/.config/lxterminal/lxterminal.conf
