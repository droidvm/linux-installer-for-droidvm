#!/bin/bash

nowtime=$(date +"%Y-%m-%d_%H-%M-%S")
echo $nowtime

# # command -v convert >/dev/null 2>&1 || sudo apt-get install -y --no-install-recommends imagemagick
# # sudo apt-get install imagemagick --no-install-recommends

# if [ "${WST_SCREEN_SAVETO}" != "" ]; then
#     filepath_xwd=~/Desktop/截图_${nowtime}.xwd
#     filepath_png=~/Desktop/截图_${nowtime}.png
#     cp ${WST_SCREEN_SAVETO} ${filepath_xwd}

#     command -v convert >/dev/null 2>&1
#     if [ $? -eq 0 ]; then
#         convert ${filepath_xwd} ${filepath_png}
#         if [ $? -eq 0 ]; then
#             rm -rf ${filepath_xwd}
#         fi
#     else
#         gxmessage -title "提示" "已将屏幕截图为xwd格式，安装 imagemagick 可将图片转换为png格式"  -center
#     fi

#     # xwud -in ${filepath}
# fi

[ -f ${app_home}/screencapture ] || cp -f ${app_home}/avm_tools/${CURRENT_VM_ARCH}/screencapture ${app_home}/
chmod 755 ${app_home}/screencapture
filepath_png=~/Desktop/截图_${nowtime}.png
screencapture "${WST_SCREEN_SAVETO}"
mv -f ./out.png ${filepath_png}
