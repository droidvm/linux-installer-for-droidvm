#!/bin/bash

ln -s -f /home/droidvm                         /home/droidvm/Desktop/文件
ln -s -f /usr/share/applications               /home/droidvm/Desktop/软件
cp -f ${tools_dir}/misc/def_desktop/*.desktop  /home/droidvm/Desktop/




# mkdir -p ${tools_dir}/misc/helper
# unzip -o ${tools_dir}/misc/helper.zip -d ${tools_dir}/misc/helper
# chmod a+x ${tools_dir}/misc/helper/*.sh
# echo 'unzip finished'
# # mv -f ${tools_dir}/misc/helper/3d_virpipe.desktop  /home/droidvm/Desktop/
# # mv -f ${tools_dir}/misc/helper/3d_llvmpipe.desktop /home/droidvm/Desktop/
# chown droidvm /home/droidvm/Desktop/*.desktop
