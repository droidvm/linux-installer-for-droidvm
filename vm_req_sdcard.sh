#!/bin/bash


echo ""                                                         > /tmp/msg.txt
echo "警告！"                                                   >>/tmp/msg.txt
echo ""                                                         >>/tmp/msg.txt
echo "授予虚拟电脑访问手机SD卡、外接U盘的权限后"                >>/tmp/msg.txt
echo "虚拟电脑中安装的 所有软件也会被授权读写SD卡中的文件"      >>/tmp/msg.txt
echo ""                                                         >>/tmp/msg.txt
echo "所以，授权后："                                           >>/tmp/msg.txt
echo "请不要在SD卡中存放敏感的信息，比如：密码类、隐私照片类"   >>/tmp/msg.txt
echo ""                                                         >>/tmp/msg.txt
gxmessage -title "警告" -file /tmp/msg.txt   -center -buttons "申请权限:1,取消申请:0"
if [ $? -ne 1 ]; then
        exit 0
fi

echo "#req_sdcard_rw" > ${NOTIFY_PIPE}
