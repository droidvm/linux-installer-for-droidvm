#!/bin/bash

cat <<- EOF > /tmp/msg.txt

    即将为您打开系统字体存放目录
    将字体库解压至字体目录后，系统即可自动识别到新字体

EOF

gxmessage -title "提示" -file /tmp/msg.txt -center

exec open /usr/share/fonts/truetype

