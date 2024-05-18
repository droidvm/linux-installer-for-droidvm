#!/bin/bash

action=$1
TMP_RES=$2
server_port=6080

# tmpfilename=/tmp/flag_enable_web_control

if [ "$action" == "" ]; then
	action=stop
fi

if [ "$TMP_RES" == "" ]; then
	TMP_RES=1280x700
fi


which webvnc >/dev/null 2>&1
if [ $? -ne 0 ]; then
	cat <<- EOF > /tmp/msg.txt

		webvnc 未安装，请先安装！

		安装步骤为：
		1). 在桌面上打开软件管家
		2). 在软件管家主界面，点击左侧的 “系统” 按钮
		3). 然后翻找 “webvnc” 软件包并安装好

	EOF
	gxmessage -title "网页远程控制" -file /tmp/msg.txt -center
	exit 1
fi


if [ "$action" == "stop" ]; then
	# echo -e -n "\x0510014" >/exbin/ipc/control
	# # rm -rf $tmpfilename
	# rm -rf /tmp/enable_webctrl
	# gxmessage -title "web远程控制" "已经停止"  -center

	vncserver -kill :6
	exit 0
fi

# touch $tmpfilename
# chmod 666 $tmpfilename
# echo -e -n "\x0510013" >/exbin/ipc/control

# touch /tmp/enable_webctrl

export VNC_SCREEN_RES=${TMP_RES}
exec lxterminal -e webvnc

# cat <<- EOF > /tmp/webcontrolflagmsg.txt

# 通过浏览器控制此模拟器
# ================================
# 请在同一wifi下的电脑或手机上用网页浏览器访问以下地址:

# EOF

# /exbin/tools/busybox ifconfig 2>/dev/null|grep '192'| \
# awk '{print $2}'|awk -v FS=":" -v OFS="" -v header="http://" -v tail=":${server_port}" '{print header,$2,tail}' \
# >>/tmp/webcontrolflagmsg.txt



# cat <<- EOF >> /tmp/webcontrolflagmsg.txt


# 关闭这个窗口不影响功能.

# EOF

# gxmessage -title "web远程控制" -file /tmp/webcontrolflagmsg.txt -center
