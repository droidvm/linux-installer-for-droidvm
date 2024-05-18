#!/bin/bash

function getpid() {
	ps aux|grep "xpra start --bind-tcp="|grep "${srvprt}"|grep -v grep|awk '{print $2}'
}

action=$1
SRVNAM=xpra
srvprt=7894
srvpid=$(getpid)
echo srvpid:$srvpid


if [ "$action" == "" ]; then
	action=stop
fi

which xpra >/dev/null 2>&1
if [ $? -ne 0 ]; then
	cat <<- EOF > /tmp/msg.txt

		xpra 未安装，请先安装！

		安装步骤为：
		1). 在桌面上打开软件管家
		2). 在软件管家主界面，点击左侧的 “远程桌面” 按钮
		3). 然后翻找 “xpra” 软件包并安装好

	EOF
	gxmessage -title "网页远程控制" -file /tmp/msg.txt -center
	exit 1
fi


if [ "$action" == "stop" ]; then
	if [ "$srvpid" == "" ]; then
		gxmessage -title "信息" "${SRVNAM}未运行"  -center
		exit 0
	  else
		${app_home}/busybox kill $srvpid
		rlt=$?
		if [ $rlt -ne 0 ]; then
			gxmessage -title "错误" "${SRVNAM}停止失败"  -center -fg red
			exit $rlt
		fi

		gxmessage -title "信息" "${SRVNAM}已停止"  -center
		exit $rlt
	fi
fi


if [ "$srvpid" == "" ]; then
	if [ 1 -eq 1 ]; then
		cd ~
		cat <<- EOF > /tmp/xpra_DE.sh
			#!/bin/bash
			pcmanfm &
			exec lxterminal
		EOF
		chmod a+x /tmp/xpra_DE.sh
		xpra start --bind-tcp=*:${srvprt} --html=on --start=/tmp/xpra_DE.sh
		# nohup xpra -p ${srvprt} bash 2>/tmp/xpra.log &
		sleep 1
		srvpid=$(getpid)
	fi
  else
	echo "已经启动"
fi

if [ "$srvpid" == "" ]; then
	gxmessage -title "错误" "${SRVNAM}启动失败"  -center -fg red # -geometry 800x400 -wrap -default okay -font "sans 20" 
	exit
fi

cat <<- EOF > /tmp/ip.txt

通过${SRVNAM}控制此模拟器
================================
端口为${srvprt}, 请在电脑上使用浏览器打开以下网址
EOF

/exbin/tools/busybox ifconfig 2>/dev/null|grep '192'| \
awk '{print $2}'|awk -v FS=":" -v OFS="" -v header="http://" -v tail=":${srvprt}" '{print header,$2,tail}' \
>>/tmp/ip.txt


cat <<- EOF >> /tmp/ip.txt


关闭这个窗口不影响功能.

EOF

# /exbin/tools/busybox ifconfig|grep 'inet ' >> /tmp/ip.txt
# scite /tmp/ip.txt
gxmessage -title "远程控制" -file /tmp/ip.txt -center
