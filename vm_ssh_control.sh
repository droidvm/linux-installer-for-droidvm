#!/bin/bash

# ps aux|grep sshd|grep -v grep|awk '{print $2,$11,$12,$13,$14,$15,$16,$17}'
# $(pidof busybox)

action=$1
sshd_port=5558
sshd_pid=$(ps aux|grep "sshd -p ${sshd_port}"|grep -v grep|awk '{print $2}')
echo sshd_pid:$sshd_pid


if [ "$action" == "" ]; then
	action=stop
fi

if [ "$action" == "stop" ]; then
	if [ "$sshd_pid" == "" ]; then
		gxmessage -title "信息" "sshd未运行"  -center
		exit 0
	  else
		${app_home}/busybox kill $sshd_pid
		rlt=$?
		if [ $rlt -ne 0 ]; then
			gxmessage -title "错误" "sshd停止失败"  -center -fg red
			exit $rlt
		fi

		gxmessage -title "信息" "sshd已停止"  -center
		exit $rlt
	fi
fi


if [ "$sshd_pid" == "" ]; then
	if [ 1 -eq 1 ]; then
		cd ~
		sudo sshd -p ${sshd_port}
		sleep 1
		sshd_pid=$(ps aux|grep "sshd -p ${sshd_port}"|grep -v grep|awk '{print $2}')
	fi
  else
	echo "已经启动"
fi

if [ "$sshd_pid" == "" ]; then
	gxmessage -title "错误" "sshd启动失败"  -center -fg red # -geometry 800x400 -wrap -default okay -font "sans 20" 
	exit
fi

cat <<- EOF > /tmp/ip.txt

通过ssh控制此模拟器
================================
端口为${sshd_port}, 请在电脑上使用ssh指令进行连接
EOF

/exbin/tools/busybox ifconfig 2>/dev/null|grep '192'| \
awk '{print $2}'|awk -v FS=":" -v OFS="" -v header="ssh -p ${sshd_port} droidvm@" -v tail="" '{print header,$2,tail}' \
>>/tmp/ip.txt


cat <<- EOF >> /tmp/ip.txt

以上指令亦适用于 vscode 客户端


关闭这个窗口不影响功能.

EOF

# /exbin/tools/busybox ifconfig|grep 'inet ' >> /tmp/ip.txt
# scite /tmp/ip.txt
gxmessage -title "远程控制" -file /tmp/ip.txt -center
