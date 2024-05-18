#!/bin/bash

action=$1

tmpfilename=/tmp/x_remote_server_addr
msgfilename=/tmp/msg.txt

gui_title="X11转发"

if [ "$action" == "" ]; then
	action=stop
fi

if [ "$action" == "stop" ]; then
	if [ ! -f $tmpfilename ]; then
		gxmessage -title "${gui_title}" "未运行"  -center
		exit 0
	fi

	rm -rf $tmpfilename
	# echo '#vmSwitch2ConsoleMode'>${NOTIFY_PIPE}
	${tools_dir}/vm_startx.sh xserver
	sleep 1
	# echo '#vmSwitch2DesktopMode'>${NOTIFY_PIPE}

	# ${tools_dir}/vm_startx.sh xserver
	# sleep 1
	# echo "XDIRTY_PIPE: ${XDIRTY_PIPE}"
	# echo "lcdFlush" >  ${XDIRTY_PIPE}
	# # gxmessage -title "${gui_title}" "已经停止"  -center
	exit 0
else
	ipaddr=`yad --entry --title "请输入远端XServer的地址" --text "请输入远端XServer的地址, 并确保远端XServer已经处于运行状态\n\nWindows端可以启动MobaXterm，然后在其菜单栏启动XServer\n" --entry-text "192.168.1.5:0"`
	
	if [ "${ipaddr}" == "" ]; then
		exit 0
	fi

	# (sleep 3;echo killing...;pkill controllee) &
	DISPLAY=${ipaddr} controllee -tryxserver
	if [ $? -ne 0]; then
		gxmessage -title "${gui_title}" "远端xserver连接失败：${ipaddr} "  -center
		exit 0
	fi

	echo ${ipaddr} > $tmpfilename
	${tools_dir}/vm_startx.sh xserver
	sleep 1

	cat <<- EOF > ${msgfilename}

	X11转发
	====================================
	功能已开启

	画面数据走 [[ USB共享网络 ]] 会比无线WIFI传输得更快！

	请注意，X11转发启动后, 虚拟电脑自带的 [[ 网页端远控 ]] 无法从开始菜单启动！

	关闭这个窗口不影响功能.

	EOF

	DISPLAY=${ipaddr} gxmessage -title "${gui_title}" -file ${msgfilename} -center

fi

# 在终端中直接运行
# echo "192.168.1.5:0">/tmp/x_remote_server_addr
# ${tools_dir}/vm_startx.sh xserver

# rm -rf /tmp/x_remote_server_addr
# ${tools_dir}/vm_startx.sh xserver
