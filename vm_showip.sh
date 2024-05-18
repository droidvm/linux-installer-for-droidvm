#!/bin/bash



cat <<- EOF > /tmp/ip.txt

本机IP
================================
EOF

/exbin/tools/busybox ifconfig 2>/dev/null|grep "inet addr:"|grep -v "127.0.0.1"| \
awk '{print $2}'|awk -v FS=":" -v OFS="" -v header="" -v tail="" '{print header,$2,tail}' \
>>/tmp/ip.txt


cat <<- EOF >> /tmp/ip.txt


EOF

gxmessage -title "本机IP" -file /tmp/ip.txt -center
