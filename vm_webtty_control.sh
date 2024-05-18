#!/bin/bash


action=$1
SRVNAM=ttyd
srvprt=5559
srvpid=$(pidof ttyd.aarch64)
echo srvpid:$srvpid

: '
使用说明：
https://man.archlinux.org/man/extra/ttyd/ttyd.1.en

启动时加参数：

# 启用文件传输方式一
-t enableTrzsz=true		# 1.73 以上才能用

# 启用文件传输方式二
-t enableZmodem=true	# 1.73 以上才能用

-t fontSize=20


ttyd.aarch64  -p 8888 -t cursorStyle=bar -t lineHeight=1.5 -t 'theme={"background": "green"}' -t fontSize=30  bash


传送文件需要安装：
lrzsz

'

if [ "$action" == "" ]; then
	action=stop
fi

needtoDownload=0
if [ ! -x ${app_home}/ttyd.aarch64 ]; then
	needtoDownload=1
else
	${app_home}/ttyd.aarch64 -v|grep "1.6.3"
	if [ $? -eq 0 ]; then
	needtoDownload=1
	fi
fi

if [ $needtoDownload -eq 1 ]; then
	wget https://mirror.ghproxy.com/https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.aarch64  -O ${app_home}/ttyd.aarch64
	chmod a+x ${app_home}/ttyd.aarch64
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

FONTSIZE=16
if [ "$srvpid" == "" ]; then
	if [ 1 -eq 1 ]; then
		cd ~
		# nohup ttyd.aarch64 -p ${srvprt} -t fontSize=${FONTSIZE} bash 2>/tmp/ttyd.log &
		# nohup ttyd.aarch64 -W -p ${srvprt} -t enableZmodem=true -t enableTrzsz=true -t fontSize=${FONTSIZE} -t 'theme={"background": "green"}' bash  2>/tmp/ttyd.log &
		nohup ttyd.aarch64 -W -p ${srvprt} -t enableZmodem=true -t enableTrzsz=true -t fontSize=${FONTSIZE} bash  2>/tmp/ttyd.log &
		sleep 1
		srvpid=$(pidof ttyd.aarch64)
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
ttyd 支持在网页端 [ 上传下载 ] 文件到当前目录中，步骤为： 
1). 使用指令：sudo apt install -y lrzsz  安装 lrzsz
2). 在网页终端中运行指令: rz (下载文件则使用: sz file)
3). 选择要上传的文件

请在电脑上使用浏览器打开以下网址
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
