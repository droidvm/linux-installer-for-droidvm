#!/bin/bash

: '

在公网服务器运行：
port4controller=7000 # 主控制端请主动连接这个端口
port4controllee=6000 # 被控制端请主动连接这个端口
for num in {1..5}  
do  
	nc -ll -p ${port4controller}  < tmpfifo  | nc -ll -p ${port4controllee} > tmpfifo
done  



在控制端运行：
telnet 124.221.123.125 7000

gmessage -title "提示" " 请让我操作，操作完我会关闭这个弹窗 " -center &
gmessage -title "提示" " 在操作 " -center &

/exbin/tools/vm_updateBootScript.sh

./ezapp/zzllq/bin/python ./tmp/dl_wps_via_playwright.py
DISPLAY= sudo ./scripts/wps.sh

重新识别U盘
/etc/autoruns/autoruns_after_gui/map_otg_udisk.sh


制作启动盘
DISPLAY= /opt/apps/mkbootudisk/mkbootudisk.sh
cd /opt/apps/qemu-linux-amd64
DISPLAY= ./qemu-linux-amd64.sh ../mkbootudisk

mkdir -p /udiskpart1
mount /dev/sda1 /udiskpart1

usbip detach -p 00

usbip attach -r 192.168.1.6 -b 1-2

unzip -oq /mnt/shared/winpe.zip -d /udiskpart1/



'


natshell_addr=124.221.123.125
natshell_port=6000


gmessage -title "远程协助" $'\n 此功能需要联系开发者，开发者开启服务端后才能使用！ \n\n' -center  -buttons "我已联系:1,取消:0"


telnetd_port=6789
${app_home}/busybox telnetd -p ${telnetd_port} -l "/bin/bash"



for num in {1..60}  
do  

	socat TCP:124.221.123.125:${natshell_port} TCP:127.0.0.1:${telnetd_port} 2>/dev/null
	if [ $? -ne 0 ]; then
		echo -e "${num} 请稍等，远程协助的控制端正在启动。。。\n";
		sleep 1
	fi

done

echo "已停止连接"
