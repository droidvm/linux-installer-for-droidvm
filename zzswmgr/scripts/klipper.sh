#!/bin/bash

: '

https://www.jianshu.com/p/6d45af6d8966
https://www.bilibili.com/read/cv14624341/   # 在基于Debian系统的主机上安装及使用Klipper
https://gitee.com/mirrors_Gottox/octo4a/blob/master/scripts/setup-klipper.sh
https://gitee.com/miroky/klipper/blob/master/scripts/install-ubuntu-22.04.sh

'

SWNAME=klipper
DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh


function sw_download() {
	case "${CURRENT_VM_ARCH}" in
		"arm64")

				apt-get install -y git
				exit_if_fail $? "git安装失败"

				DEB_PATH=./downloads/${SWNAME}.zip
				app_dir=/opt/apps/${SWNAME}

				if [ ! -d ${app_dir} ]; then
					# # url get from https://gitee.com/mirrors_Gottox/octo4a/blob/master/scripts/setup-klipper.sh
					# swUrl=${APP_URL_DLSERVER}/klipper.zip
					# download_file2 "${DEB_PATH}" "${swUrl}"
					# exit_if_fail $? "下载失败，网址：${swUrl}"


					# swUrl=https://gitee.com/miroky/klipper
					swUrl=https://gitee.com/yelam2022/klipper
					download_file3 "${app_dir}" "${swUrl}"
					exit_if_fail $? "下载失败，网址：${swUrl}"

					echo "正在修改klipper目录的上位机C源码"
					# 补丁来源：
					# ================================================================
					# https://gitee.com/yelam2022/wireless-klipper
					# https://github.com/apollo80/wireless-klipper	# 此为原始仓库
					cd ${app_dir}
					patch -p1 < ${ZZSWMGR_MAIN_DIR}/scripts/res/klipper-host-enable-tcpsocket.patch
					exit_if_fail $? "源码修改失败：${SWNAME}"
				fi

				;;
		"amd64")
				exit_unsupport
				;;
		*) exit_unsupport ;;
	esac

}

function sw_install() {
	case "${CURRENT_VM_ARCH}" in
		"arm64")
				# apt-get install -y unzip
				# exit_if_fail $? "解压工具unzip安装失败"

				# https://gitee.com/miroky/klipper/blob/master/scripts/install-ubuntu-22.04.sh
				apt_pkgs="build-essential python3 python3-pip git python3-greenlet python3-cffi"
				apt_pkgs="${apt_pkgs} python3-serial python3-jinja2 python3-websocket python3-requests"
				apt_pkgs="${apt_pkgs} python3-venv virtualenv python3-dev libffi-dev build-essential libncurses-dev"
				apt_pkgs="${apt_pkgs} gcc make socat"

				# 编译工具，体积太大了
				# apt_pkgs="${apt_pkgs} avrdude gcc-avr binutils-avr avr-libc"
				# apt_pkgs="${apt_pkgs} stm32flash dfu-util libnewlib-arm-none-eabi"
				# apt_pkgs="${apt_pkgs} gcc-arm-none-eabi binutils-arm-none-eabi"
				apt-get install -y ${apt_pkgs}
				exit_if_fail $? "依赖库安装失败"

				# echo "正在解压. . ."
				# unzip -oq ${DEB_PATH} -d /opt/apps/
				# exit_if_fail $? "安装失败，软件包：${DEB_PATH}"
				# mv -f /opt/apps/klipper-master /opt/apps/klipper

				echo "正在将pip下载仓库地址换成国内的. . ."
				pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple


				echo "正在创建python vENV"
				python3 -m venv ${app_dir}

				echo "正在将vENV中的pip的下载仓库地址换成国内的"
				${app_dir}/bin/pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
				exit_if_fail $? "pip仓库设置出错"

				# echo "正在通过pip安装组件"
				# ${app_dir}/bin/pip install webhooks


				# download_file3 "${SRC_DIR}" "${swUrl}"
				# exit_if_fail $? "下载失败，网址：${swUrl}"

				;;
		"amd64")
				exit_unsupport
				;;
		*) exit_unsupport ;;
	esac
}

function sw_create_desktop_file() {
	case "${CURRENT_VM_ARCH}" in
		"arm64")
				rm2desktop klipper.desktop
				rm -rf /usr/share/applications/klipper.desktop
				rm -rf /usr/bin/klipper

				# rm -rf /mnt/printer_data # 可能会连带着删掉用户的其它文件，注释掉了
				mkdir -p /mnt/printer_data/config
				mkdir -p  /mnt/printer_data/logs
				mkdir -p  /mnt/printer_data/gcodes
				chmod 766 -R /mnt/printer_data

				# 创建说明文件
				cat <<- EOF > /mnt/printer_data/config/配置文件说明.txt
					虚拟电脑支持KlipperScreen(klipper的本地控制端)和klipper的两种网页端控制程序，即 mainsail 和 fluidd
					同一时间，网页端控制程序只能使用一种

					为啥printer.cfg中串口那里是个网络地址？
					===========================================
					这是因为不root的安卓，串口设备要由app映射成pty设备，
					再由虚拟系统把这个pty设备映射成tcp socket，
					所以我改了klipper上位机代码，增加了网络连接mcu的功能

					其它信息：
					===========================================
					目前已确定不支持的功能包括
					1). systemd service 重启服务，暂时的解决方法，手动在桌面上重新打开klipper
					2). dbus			获取服务信息，不需要理会
					3). temperature_host	获取上位机温度，在配置文件中注释掉获取上位温度的代码
					4). 文件在别处被修改的文件监视功能没有
					5). 暂不支持摄像头监控，后续可能会加上这个功能
					
				EOF


				echo "正在生成 klipper 的 printer.cfg => /mnt/printer_data/config/printer.cfg"
				cat <<- EOF > ${app_dir}/printer.cfg.base
					[mcu]
					# serial: /tmp/fakeserial
					# 虚拟电脑中的klipper，通过网络地址连接串口设备! 端口号8899建议不要修改
					host: 127.0.0.1
					port: 8899
					# ！！！！！！！！！！！！！！！！！！！！！！！！！！！
					# ！！！                                          ！！！
					# ！！！ 虚拟电脑中的klipper不用自己找串口设备路径！！！
					# ！！！                                          ！！！
					# ！！！！！！！！！！！！！！！！！！！！！！！！！！！
					
					# 如果手机连接了多个串口设备，那在双击桌面klipper图标启动的时候，会弹窗让你选的

					# 如果需要改串口波特率，请在桌面上对准 klipper 图标按音量加键右击，再选择用 notepad 打开
					# 然后把里面的250000改成你的波特率，改的时候注意不要多加空格，请维持原有的格式!


					[printer]
					kinematics: none
					max_velocity: 1000
					max_accel: 1000
				EOF

				STARTUP_SCRIPT_FILE=${app_dir}/ehcopwd
				cat <<- EOF > ${STARTUP_SCRIPT_FILE}
					#!/bin/bash
					echo "droidvm"
				EOF
				chmod 755 ${STARTUP_SCRIPT_FILE}
				cp -f ${STARTUP_SCRIPT_FILE}  /usr/bin/

				STARTUP_SCRIPT_FILE=${app_dir}/zzmapdevice
				cat <<- EOF > ${STARTUP_SCRIPT_FILE}
					#!/bin/bash

					tcpport=8899
					usbcfg=250000,8,1,0
					usbmsg="默认的参数"
					if [ -f /tmp/zzusb.cfg ]; then
						usbmsg="来自缓存文件 /tmp/zzusb.cfg"
						usbcfg=\`cat /tmp/zzusb.cfg\`
					fi
					if [ "\$USBCFG" != "" ]; then
						usbmsg="环境变量 \$USBCFG"
						echo "\$USBCFG">/tmp/zzusb.cfg
						usbcfg="\$USBCFG"
					fi

					. ${tools_dir}/vm_config.sh
					export app_temp=${app_home}/tmp
					export DISPLAY=${DISPLAY}

					# 选择USB转换，并映射到虚拟系统中

					function domapdevice() {
						iface=""
						/exbin/zzotg 2>/dev/null|grep -v rescode >/tmp/usbdevices
						devices=\`cat /tmp/usbdevices\`
						dev_count=\`cat /tmp/usbdevices|wc -l\`
						if [ "\$devices" == "" ]; then
							dev_count=0
						fi
						echo "|  devices: \$devices|"
						echo "|dev_count: \$dev_count|"
						echo ""
						if [ \$dev_count -lt 1 ]; then
							echo -e "未识别到可用的串口设备，\\e[96m手机的OTG功能是否已打开？\\e[0m"
							exit -1
						fi
						if [ \$dev_count -gt 1 ]; then
							gui_title="请选择USB串口设备"
							iface=\`cat /tmp/usbdevices|yad --title="\${gui_title}" --text="\n从下列设备中选一个:\n" \\
							--button="确定:0"  --button="取消:1" --list --column="已识别到的设备" --width=800 --height=300 --print\`
							ret=\$?
							if [ \$ret -ne 0 ]; then exit -1; fi
						else
							iface=\$devices
						fi
						iface=\`echo \$iface| awk -v FS="," '{print \$1}'\`
						echo "已选用的设备：\$iface"

							echo "正在映射设备：\$usbcfg(波特率,数据位，停止位，检验位), 参数来源：\${usbmsg}"
							/exbin/zzotg tcp \$tcpport "\$iface" \$usbcfg >/tmp/mapped_serial_rlt 2>/dev/null
							maprlt=\$?
						if [ \$maprlt -ne 0 ]; then
							/exbin/zzotg tcp \$tcpport "\$iface" \$usbcfg >/tmp/mapped_serial_rlt 2>/dev/null
							maprlt=\$?
						fi
						if [ \$maprlt -ne 0 ]; then
							echo "\$iface 设备映射失败"
							exit -1
						else
							ptypath=\`tail -n 1 /tmp/mapped_serial_rlt\`
							if [ "\$ptypath" == "" ]; then
								echo "\$iface => vm_pty 映射失败"
								exit -1
							fi
							echo "设备映射成功: \$iface => \$ptypath"

							# echo "正在将serial映射为tcp server"
							# tcpport=8899
							# tcpaddr=127.0.0.1:\$tcpport
							# # pkill socat
							# pid_of_socat=\`ps ax|grep -v grep|grep socat|grep "\$tcpport"|awk '{print \$1}'\`
							# if [ "\$pid_of_socat" != "" ]; then
							# 	kill \$pid_of_socat
							# fi
							# sleep 0.5
							# socat FILE:"\$ptypath",raw TCP-LISTEN:\$tcpport,fork,reuseaddr &
							# # sleep 1

							# # 先读过设备数据，就失败！！！所以这里不能轻易测试端口是否连通
							# # socat /dev/null TCP:\$tcpaddr
							# # if [ \$? -ne 0 ]; then
							# # 	echo "vm_pty => tcp 映射失败"
							# # 	exit -1
							# # fi
							# echo "设备映射成功: \$iface => \$tcpaddr"

							exit 0

						fi

					}
					# 选择USB转换，并映射到虚拟系统中

					domapdevice

				EOF
				chmod 755 ${STARTUP_SCRIPT_FILE}
				cp -f ${STARTUP_SCRIPT_FILE}  /usr/bin/

				STARTUP_SCRIPT_FILE=${app_dir}/klipper
				cat <<- EOF > ${STARTUP_SCRIPT_FILE}
					#!/bin/bash

					export SUDO_ASKPASS=/usr/bin/ehcopwd

					function start_klipper() {
						echo -e ""
						echo -e "正在启动klipper，请确保您的\\e[96m打印机控制板已经刷入klipper固件并且工作正常\\e[0m"
						echo -e "若klipper运行失败，您可以通过这个指令查看日志：cat /mnt/printer_data/logs/klippy.log"
						echo -e ""
						rm -rf /mnt/printer_data/logs/klippy.log
						sudo -A python3 /opt/apps/klipper/klippy/klippy.py /mnt/printer_data/config/printer.cfg -l /mnt/printer_data/logs/klippy.log -a /tmp/klippy.sock "\$@"
					}

					# 提供 klipper web ui 的, 网站代码分别是 /opt/apps/mainsail 和 /opt/apps/fluidd
					function start_nginx() {
						if [ "\${APPNAME_WEB_CTRL}" != "" ]; then

							/exbin/tools/busybox ifconfig 2>/dev/null|grep '192'| \\
							awk '{print \$2}'|awk -v FS=":" -v OFS="" -v header="http://" -v tail=":\${APPNAME_WEB_PORT}" '{print header,\$2,tail}' \\
							>/tmp/ip.txt

							echo ""
							echo -e "/etc/nginx/sites-enabled/default \\e[96m默认指向 \${APPNAME_WEB_CTRL}\\e[0m"
							echo ""
							echo -e "正在启动\${APPNAME_WEB_CTRL}, \\e[96m请在电脑端或别的手机上访问："
							tmpaddrs=\`cat /tmp/ip.txt\`
							if [ "\${tmpaddrs}" != "" ]; then
								echo \${tmpaddrs}
							else
								echo "http://本设备IP:\${APPNAME_WEB_PORT}"
							fi
							echo -e "\\e[0m"

							\${APPNAME_WEB_CTRL}
						fi
					}

					function start_webbrowser() {
						if [ -x /usr/bin/chromium-browser-nosandbox ]; then
							chromium-browser-nosandbox http://127.0.0.1:\${APPNAME_WEB_PORT}/ 2>&1 >/dev/null &
						fi
					}

					export USBCFG="\$USBCFG"
					zzmapdevice
					rltmap=\$?
					if [ \${rltmap} -ne 0 ]; then
						echo -e "\\e[96m启动失败：\\e[0m识别到控制板才能启动，请先使用usb数据线连接控制板"
						echo -e "\\e[96m使用说明：\\e[0mhttp://droidvm.com/cn/3DPrinter.htm"
						read -s -n1 -p "按任意键退出"
						exit \$rltmap
					fi

					echo ""
					echo -e "请输入当前用户的密码, \\e[96m默认密码：droidvm\\e[0m"
					sudo -A chmod 766 -R /mnt/printer_data

					# 等待1秒
					sleep 1

					if [ ! -x /usr/bin/moonraker ]; then
						echo -e "\\e[96mmoonraker 未安装，无法使用klipper直接控制打印机\\e[0m"
					fi

					APPNAME_WEB_CTRL=\`readlink /etc/nginx/sites-enabled/default\`
					APPNAME_WEB_CTRL=\${APPNAME_WEB_CTRL##*/}
					if   [ "\${APPNAME_WEB_CTRL}" == "mainsail" ]; then
						APPNAME_WEB_PORT=8888
					elif [ "\${APPNAME_WEB_CTRL}" == "fluidd" ]; then
						APPNAME_WEB_PORT=9999
					else
						APPNAME_WEB_CTRL=
						echo -e "\\e[96mmainsail 和 fluidd 均未安装，将不能通过网页控制3D打印机\\e[0m"
					fi
					if [ ! -x /usr/bin/\${APPNAME_WEB_CTRL} ]; then
						echo -e "\\e[96m\${APPNAME_WEB_CTRL} 没有运行权限，将不能通过网页控制3D打印机\\e[0m"
						APPNAME_WEB_CTRL=
					fi

					start_nginx

					echo ""
					echo -e "\\e[96m配置文件路径：\\e[0m/mnt/printer_data/config/"
					echo -e "\\e[96m配置教程网址：\\e[0mhttp://droidvm.com/cn/3DPrinter.htm"
					echo -e "\\e[96m查看本设备的IP\\e[0m: 开始使用 -> 远程控制 -> 查看本机IP地址"

					# 延后2秒启动浏览器
					# ( sleep 2; start_webbrowser & ) &


					# 启动 klipper
					start_klipper

				EOF
				chmod 755 ${STARTUP_SCRIPT_FILE}
				cp -f ${STARTUP_SCRIPT_FILE}  /usr/bin/

				echo "正在生成桌面文件"
				BAUDRATE="250000,8,1,0"
				tmpfile=${DIR_DESKTOP_FILES}/klipper.desktop
				echo "[Desktop Entry]"			> ${tmpfile}
				echo "Encoding=UTF-8"			>>${tmpfile}
				echo "Version=0.9.4"			>>${tmpfile}
				echo "Type=Application"			>>${tmpfile}
				echo "Name=klipper"				>>${tmpfile}
				echo "Exec=env USBCFG=${BAUDRATE} lxterminal -e klipper %f"	>> ${tmpfile}
				echo "Icon=${app_dir}/docs/img/klipper-logo.png"			>> ${tmpfile}
				cp2desktop ${tmpfile}

				tmpfile=${DIR_DESKTOP_FILES}/klipperlog.desktop
				echo "[Desktop Entry]"			> ${tmpfile}
				echo "Encoding=UTF-8"			>>${tmpfile}
				echo "Version=0.9.4"			>>${tmpfile}
				echo "Type=Application"			>>${tmpfile}
				echo "Name=查看klipper日志"		>>${tmpfile}
				echo "Exec=notepad /mnt/printer_data/logs/klippy.log"				>> ${tmpfile}
				echo "Icon=${app_dir}/docs/img/klipper-logo.png"	>> ${tmpfile}
				cp2desktop ${tmpfile}

				# 替换 lsusb
				rm -rf /usr/bin/lsusb
				ln -sf /exbin/zzotg /usr/bin/lsusb

				echo "安装已完成"
				gxmessage -title "提示" "安装已完成"  -center
				;;
		"amd64")
				exit_unsupport
				;;
		*) exit_unsupport ;;
	esac
}

if [ "${action}" == "卸载" ]; then
	echo "暂不支持卸载"
	exit 1
else
	sw_download
	sw_install
	sw_create_desktop_file
fi
