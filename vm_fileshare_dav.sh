#!/bin/bash

function getpid() {
	ps aux|grep "davserver3 -H 0.0.0.0"|grep "${srvprt}"|grep -v grep|awk '{print $2}'
}

action=$1
dir2share=$2
SRVNAM=PyWebDAV3
srvprt=5562
srvpid=$(getpid)
echo srvpid:$srvpid


if [ "$action" == "" ]; then
	action=stop
fi

if [ "$dir2share" == "" ]; then
	dir2share=~/
fi

which davserver3 >/dev/null 2>&1
if [ $? -ne 0 ]; then
	cat <<- EOF > /tmp/msg.txt

		PyWebDAV3 未安装，请先安装！

		安装步骤为：
		1). 在桌面上打开软件管家
		2). 在软件管家主界面，点击左侧的 “NAS网盘” 按钮
		3). 然后翻找 “PyWebDAV3” 软件包并安装好

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
		nohup davserver3 -H 0.0.0.0 -D ${dir2share} -n -J -P ${srvprt}  2>/tmp/davserver3.log &
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

${dir2share} 已通过webdav协议对外共享
================================
请在电脑上：
双击我的电脑，在工具栏点击 “添加一个网络位置”
添加以下网址后
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
