#!/bin/bash

: '
vncserver :6 -localhost no -geometry 1280x800 -depth 32  -xstartup jwm
:6 即代表xserver的display_id, 也代表vnc server的端口号为 5906, 如果是:1那对应的端口号就是5901, :2=>5902
https://blog.csdn.net/u012625323/article/details/122419954
vncserver -kill :6

修改vnc访问密码：
vncpasswd

测试启动：
VNC_SCREEN_RES=1280x700
vncserver :6 -localhost no -geometry ${VNC_SCREEN_RES} -depth 32  -xstartup startx_for_vnc

'

SWNAME=webvnc
DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}


action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh

PKGS="tigervnc-standalone-server tigervnc-common tigervnc-tools websockify novnc"
FLAG=/etc/tigervnc/installed

if [ "${action}" == "卸载" ]; then
	sudo apt-get remove -y ${PKGS}
else
	sudo apt-get install -y --no-install-recommends  ${PKGS}
	exit_if_fail $? "安装失败"

	# touch ${FLAG}
	# exit_if_fail $? "无法创建首启动标志文件"
	# chmod 777 ${FLAG}

	# cp -f /usr/share/novnc/vnc.html /usr/share/novnc/远程控制.html
	cat <<- EOF > /usr/share/novnc/远程控制.html
		<meta charset="utf-8">
        <script>
			alert('当前网页分辨率：' + document.documentElement.clientWidth + 'x' + document.documentElement.clientHeight);
			window.location.href='vnc_lite.html'
        </script>
	EOF
	chmod 777 /usr/share/novnc/远程控制.html

	cat <<- EOF > ${DSK_PATH}
[Desktop Entry]
Name=网页远控
Comment=在电脑端通过网页浏览器控制虚拟电脑
Exec=env VNC_SCREEN_RES=1280x700 /usr/bin/webvnc %F
Terminal=true
Type=Application
	EOF
	cp2desktop ${DSK_PATH}

	sudo cat <<- EOF > /usr/bin/startx_for_vnc
		#!/bin/bash
		export DISPLAY=:6
		xhost +
		jwm &
		pcmanfm --desktop
	EOF
	chmod 755 /usr/bin/startx_for_vnc

	sudo cat <<- EOF > /usr/bin/webvnc
		#!/bin/bash

		# ~/.vnc/ 中的日志文件非常占空间！！！
		rm -rf \$HOME/.vnc/*.log

		# if [ -f ${FLAG} ]; then
		if [ ! -f \$HOME/.vnc/passwd ]; then
			echo ""
			echo "首次使用请设置vnc访问密码(密码长度6个字符以上)"
			vncpasswd
			if [ \$? -eq 0 ]; then
				rm -rf ${FLAG}
			fi
		fi

		function showaddr1() {
			novnc_port=5906
			/exbin/tools/busybox ifconfig 2>/dev/null|grep '192'| \\
			awk '{print \$2}'|awk -v FS=":" -v OFS="" -v header="" -v tail=":\${novnc_port}" '{print header,\$2,tail}' \\
			>/tmp/ip.txt

			echo -e "\\e[96m用vnc客户端连接：\\e[0m"
			cat /tmp/ip.txt
			echo ""
		}

		function showaddr2() {
			novnc_port=6080
			/exbin/tools/busybox ifconfig 2>/dev/null|grep '192'| \\
			awk '{print \$2}'|awk -v FS=":" -v OFS="" -v header="http://" -v tail=":\${novnc_port}" '{print header,\$2,tail}' \\
			>/tmp/ip.txt

			echo -e "\\e[96m用浏览器访问：\\e[0m"
			cat /tmp/ip.txt
			echo ""
		}
		function showaddr() {
			echo ""
			echo "分辨率：\${VNC_SCREEN_RES} (要修改分辨率，请用记事本编辑桌面上的启动图标)"
			echo "vnc远控、网页远控均已启动，请在电脑端："
			echo ""

			showaddr1
			echo "或者"
			showaddr2
		}

		vncserver -kill :6
		# sleep 1
		if [ "\${VNC_SCREEN_RES}" == "" ]; then
			VNC_SCREEN_RES=1280x700
		fi
		vncserver :6 -localhost no -geometry \${VNC_SCREEN_RES} -depth 32  -xstartup startx_for_vnc &
		sleep 1

		# 延后2秒显示
		( sleep 2; showaddr & ) &

		# 启动 novnc
		/usr/share/novnc/utils/novnc_proxy --vnc localhost:5906

		vncserver -kill :6


		# novnc_existed=\`ps ax|grep novnc_proxy|grep -v grep\`
		# if [ "\${novnc_existed}" == "" ]; then
		# 	/usr/share/novnc/utils/novnc_proxy --vnc localhost:5906 &
		# fi

		# read -s -n1 -p "按任意键关闭此黑窗(不影响vnc功能)"
		# read -s -n1 -p "按任意键退出"

	EOF
	chmod 755 /usr/bin/webvnc


	gxmessage -title "提示" "安装已完成，双击桌面上的 \"网页控制\" 可以启动"  -center
fi

# vncserver :6 -localhost no -geometry ${VNC_SCREEN_RES} -depth 32  -xstartup jwm &
