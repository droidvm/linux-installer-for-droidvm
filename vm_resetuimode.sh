#!/bin/bash
rm -rf ${DirGuiConf}
rm -rf ~/.config/gtk2
${tools_dir}/vm_startx.sh xserver
