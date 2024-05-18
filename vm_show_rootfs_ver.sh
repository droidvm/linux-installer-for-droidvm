#!/bin/bash


cat <<- EOF > /tmp/msg.txt

rootfs版本信息
====================================================

EOF

lsb_release -a >> /tmp/msg.txt

cat <<- EOF >> /tmp/msg.txt

EOF

gxmessage -title "rootfs版本信息" -file /tmp/msg.txt -center
