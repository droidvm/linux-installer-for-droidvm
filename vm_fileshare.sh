#!/bin/bash

# ps aux|grep ftpd|grep -v grep|awk '{print $2,$11,$12,$13,$14,$15,$16,$17}'
# $(pidof busybox)

action=$1
dir2share=$2
ftpd_port=5557
ftpd_pid=$(ps aux|grep "nmftpsrv -p ${ftpd_port}"|grep -v grep|awk '{print $2}')
echo ftpd_pid:$ftpd_pid


if [ "$action" == "" ]; then
	action=stop
fi

if [ "$dir2share" == "" ]; then
	dir2share=~/
fi

if [ "$action" == "stop" ]; then
	if [ "$ftpd_pid" == "" ]; then
		gxmessage -title "文件共享" "ftpd未运行"  -center
		exit 0
	  else
		${app_home}/busybox kill $ftpd_pid
		rlt=$?
		if [ $rlt -ne 0 ]; then
			gxmessage -title "错误" "ftpd停止失败"  -center -fg red
		fi

		gxmessage -title "文件共享" "ftpd已停止"  -center
		exit $rlt
	fi
fi


if [ "$ftpd_pid" == "" ]; then
	if [ 1 -eq 1 ]; then
		cd ~
		${app_home}/nmftpsrv -p ${ftpd_port} -c gb18030 -d ${dir2share} &
		sleep 1
		ftpd_pid=$(ps aux|grep "nmftpsrv -p ${ftpd_port}"|grep -v grep|awk '{print $2}')
	fi
  else
	echo "已经启动"
fi

if [ "$ftpd_pid" == "" ]; then
	gxmessage -title "错误" "ftpd启动失败"  -center -fg red # -geometry 800x400 -wrap -default okay -font "sans 20" 
	exit
fi

cat <<- EOF > /tmp/ip.txt

${dir2share} 已通过ftp对外共享
您可以在电脑上使用文件浏览器等ftp客户端工具访问,
运行如下指令即可读写此模拟器内的文件:

EOF

/exbin/tools/busybox ifconfig 2>/dev/null|grep '192'| \
awk '{print $2}'|awk -v FS=":" -v OFS="" -v header="explorer  ftp://" -v tail=":${ftpd_port}/" '{print header,$2,tail}' \
>>/tmp/ip.txt


cat <<- EOF >> /tmp/ip.txt

在windows电脑端上写ftp文件的2种方式:
1). 点击开始，运行，粘贴以上地址,然后回车
2). 安装专业的ftp客户端工具

注：请匆将隐私类文件进行共享! 共享功能不使用时，请立即关闭。

关闭这个窗口不影响功能.

EOF

gxmessage -title "文件共享" -file /tmp/ip.txt -center




