#!/bin/bash

action=$1
server_port=8000

# tmpfilename=/tmp/flag_enable_web_control

if [ "$action" == "" ]; then
	action=stop
fi

if [ "$action" == "stop" ]; then
	echo -e -n "\x0510014" >/exbin/ipc/control
	# rm -rf $tmpfilename
	rm -rf /tmp/enable_webctrl
	gxmessage -title "web远程控制" "已经停止"  -center
	exit 0
fi

# touch $tmpfilename
# chmod 666 $tmpfilename
echo -e -n "\x0510013" >/exbin/ipc/control

touch /tmp/enable_webctrl

cat <<- EOF > /tmp/webcontrolflagmsg.txt

通过浏览器控制此模拟器
================================
请在同一wifi下的电脑或手机上用网页浏览器访问以下地址:

EOF

/exbin/tools/busybox ifconfig 2>/dev/null|grep '192'| \
awk '{print $2}'|awk -v FS=":" -v OFS="" -v header="http://" -v tail=":${server_port}" '{print header,$2,tail}' \
>>/tmp/webcontrolflagmsg.txt



cat <<- EOF >> /tmp/webcontrolflagmsg.txt


关闭这个窗口不影响功能.

EOF

gxmessage -title "web远程控制" -file /tmp/webcontrolflagmsg.txt -center
