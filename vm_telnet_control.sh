#!/bin/bash

# ps aux|grep telnetd|grep -v grep|awk '{print $2,$11,$12,$13,$14,$15,$16,$17}'
# $(pidof busybox)

action=$1
telnetd_port=5556
telnetd_pid=$(ps aux|grep "busybox telnetd -p ${telnetd_port}"|grep -v grep|awk '{print $2}')
echo telnetd_pid:$telnetd_pid


if [ "$action" == "" ]; then
	action=stop
fi

if [ "$action" == "stop" ]; then
	if [ "$telnetd_pid" == "" ]; then
		gxmessage -title "信息" "telnetd未运行"  -center
		exit 0
	  else
		${app_home}/busybox kill $telnetd_pid
		rlt=$?
		if [ $rlt -ne 0 ]; then
			gxmessage -title "错误" "telnetd停止失败"  -center -fg red
			exit $rlt
		fi

		gxmessage -title "信息" "telnetd已停止"  -center
		exit $rlt
	fi
fi


if [ "$telnetd_pid" == "" ]; then
	if [ 1 -eq 1 ]; then
		cd ~
		${app_home}/busybox telnetd -p ${telnetd_port} -l "/bin/bash" &
		sleep 1
		telnetd_pid=$(ps aux|grep "busybox telnetd -p ${telnetd_port}"|grep -v grep|awk '{print $2}')
	fi
  else
	echo "已经启动"
fi

if [ "$telnetd_pid" == "" ]; then
	gxmessage -title "错误" "telnetd启动失败"  -center -fg red # -geometry 800x400 -wrap -default okay -font "sans 20" 
	exit
fi

cat <<- EOF > /tmp/ip.txt

通过telnet控制此模拟器
================================
端口为5556, 请在电脑上使用telnet指令进行连接
EOF

/exbin/tools/busybox ifconfig 2>/dev/null|grep '192'| \
awk '{print $2}'|awk -v FS=":" -v OFS="" -v header="telnet  " -v tail="  ${telnetd_port}" '{print header,$2,tail}' \
>>/tmp/ip.txt


cat <<- EOF >> /tmp/ip.txt


关闭这个窗口不影响功能.

EOF

# /exbin/tools/busybox ifconfig|grep 'inet ' >> /tmp/ip.txt
# scite /tmp/ip.txt
gxmessage -title "远程控制" -file /tmp/ip.txt -center
