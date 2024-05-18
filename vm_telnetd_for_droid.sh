#!/bin/bash

echo "#droidconsole" > ${NOTIFY_PIPE}

telnetd_port=5555

cat <<- EOF > /tmp/ip.txt

通过telnet连接安卓控制台
================================
端口为5555, 请在电脑上使用telnet指令进行连接
EOF

/exbin/tools/busybox ifconfig 2>/dev/null|grep '192'| \
awk '{print $2}'|awk -v FS=":" -v OFS="" -v header="telnet  " -v tail="  ${telnetd_port}" '{print header,$2,tail}' \
>>/tmp/ip.txt

sleep 0.2
lxterminal -e /exbin/tools/vm_connect_android_consle_via_telnet.sh &

cat <<- EOF >> /tmp/ip.txt

安卓系统为了保证支付功能的安全性，
设计了非常严格、复杂的权限管理系统,

普通应用即使能打开控制台, 权限也非常有限,

若需要更高级别的权限,
请使用安卓开发者模式中的 adb shell

若adb shell提供的权限还不够您使用,
可以考虑 【舍弃手机安全性】,
把手机破解、越狱以获取root权限 —— 但不建议您这么做。

关闭这个窗口不影响功能.

EOF

# /exbin/tools/busybox ifconfig|grep 'inet ' >> /tmp/ip.txt
# scite /tmp/ip.txt
gxmessage -title "安卓控制台" -file /tmp/ip.txt -center
