#!/bin/bash

# /tmp/.X11-unix/
# /tmp/.X1-lock

action=$1

if [ "$action" == "" ]; then
	action=normal_start
fi

function init_uimode() {
	echo "\${DirGuiConf}: ${DirGuiConf}" >>/tmp/test.txt

	curruser=`whoami`
	needinit=0
	if [ ! -d ${DirGuiConf} ]; then
		needinit=1
	fi
	if [ ! -f ${PATHUIMODE} ]; then
		needinit=1
	fi
	if [ ! -f ${PATH_VMDPI} ]; then
		needinit=1
	fi

	if [ $needinit -eq 0 ]; then
		echo "当前用户(${curruser})的 uimode 已初始化过"
		return
	else
		echo "当前用户(${curruser})的 uimode 正在初始化"
	fi

	rm -rf ${DirBakConf}
	mkdir -p ${DirGuiConf} 2>/dev/null
	cp -rf ${tools_dir}/misc/def_xconf/. ${DirBakConf}

	# default uimode
	${tools_dir}/vm_setuimode.sh phone

	# ls -al ~/.droidvm/

	rm -rf ~/.jwmrc
	ln -sf ~/.droidvm/.jwmrc ~/.jwmrc

	# mimetype 关联启动
	mkdir -p ~/.config 2>/dev/null
	cp -rf ${DirBakConf}/common/mimeapps.list  ~/.config/mimeapps.list

	# 右键菜单
	mkdir -p ~/.local/share/file-manager/actions 2>/dev/null
	cp -rf ${DirBakConf}/common/.local/share/file-manager/actions/*  ~/.local/share/file-manager/actions/

	chmod 755 ${tools_dir}/zzswmgr/zzswmgr.py
}

function run_once() {
	#Start DBUS session bus for trash/回收站
	# grep show_trash=1 ~/.config/pcmanfm/default/desktop-items-0.conf
	# if [ $? -eq 0 ]; then
	if [ -f ${app_home}/app_boot_config/trash_enable ]; then
		echo "正在启动回收站相关进程"
		if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
			eval $(dbus-launch --sh-syntax --exit-with-session)
		fi
		/usr/libexec/gvfsd &
	fi
}

function resize_screen() {
	tmp_fbw=$1
	tmp_fbh=$2

	echo "screent resizing to ${tmp_fbw} ${tmp_fbh}"

	# set -x	# echo on
	# ## 用这种方式切换分辨率，会导致 DisplayWidth() 取到的值 和 从屏幕文件中取到的 fb_width 不一致！
	# # xrandr --fb ${tmp_fbw}x${tmp_fbh}

	xrandr
	mode_name=${tmp_fbw}x${tmp_fbh}
	xrandr --newmode "${mode_name}" \
	109.00 \
	${tmp_fbw} ${tmp_fbw} ${tmp_fbw} ${tmp_fbw}  \
	${tmp_fbh} ${tmp_fbh} ${tmp_fbh} ${tmp_fbh} \
	-hsync +vsync

	if [ "${XSRV_NAME}" == "Xvfb" ] || [ "${XSRV_NAME}" == "xlorie" ]; then
		xrandr --addmode screen "${mode_name}"
	fi
	if [ "${XSRV_NAME}" == "Xtigervnc" ]; then
		xrandr --addmode VNC-0 "${mode_name}"
	fi
	xrandr -s ${mode_name}
	xrandr

	# set +x	# echo off
}

function xconfig() {
	# 实测在proot环境中无效的配置项
	# Xcursor.size: 64
	# gxmessage*faceSize: 80

	cat <<- EOF > ~/.Xresources

	Xft.dpi: ${VM_DPI}
	Xcursor.size: 64

	xterm*locale: zh_CN.UTF-8
	xterm*faceName: Monospace
	xterm*faceSize: 14
	xterm*scrollBar: true
	xterm*rightScrollBar: true

	gxmessage*locale: zh_CN.UTF-8
	gxmessage*faceName: Monospace
	gxmessage*faceSize: 30

	EOF

	echo "xrdb -merge ~/.Xresources  i"
	xrdb -merge ~/.Xresources
	echo "xrdb -merge ~/.Xresources  o"
}

function propt_webCtrl_msg() {

	# 固定端口!
	server_port=8000

	cat <<- EOF > /tmp/msg.txt

	通过浏览器控制此模拟器
	================================
	请在同一wifi下的电脑或手机上用网页浏览器访问以下地址:

	EOF

	/exbin/tools/busybox ifconfig 2>/dev/null|grep '192'| \
	awk '{print $2}'|awk -v FS=":" -v OFS="" -v header="http://" -v tail=":${server_port}" '{print header,$2,tail}' \
	>>/tmp/msg.txt

	cat <<- EOF >> /tmp/msg.txt

	关闭这个窗口不影响功能.

	EOF

	gxmessage -title "web远程控制" -file /tmp/msg.txt -center
}

function rm_flag_files() {


	if [ -f ${APP_FILENAME_URLTOOLS} ]; then
		# if [ "1.32" == "${APP_RELEASE_VERSION}" ]; then
		if [ 1 -eq 0 ]; then
			# 测试时不删除
			:
		else
			rm -rf ${APP_FILENAME_URLTOOLS}
		fi
	fi

	if [ -f /tmp/firsttime_bootmsg.txt ]; then
		gxmessage -title "欢迎使用虚拟电脑" -file /tmp/firsttime_bootmsg.txt  -center
		rm -rf /tmp/firsttime_bootmsg.txt
	fi

	if [ -f /tmp/osbackupmsg.txt ]; then
		gxmessage -title "系统备份信息" -file /tmp/osbackupmsg.txt  -center -buttons "打开目录:0,我知道了:1"
        case "$?" in
            "0")
                open ${tools_dir}/imgbak/
                ;;
            *) 
				:
                ;;
        esac
		rm -rf /tmp/osbackupmsg.txt
	fi

	if [ -f /tmp/osrestoremsg.txt ]; then
		gxmessage -title "系统还原信息" -file /tmp/osrestoremsg.txt  -center
		rm -rf /tmp/osrestoremsg.txt
	fi

	if [ "${ENABLE_WEB_CONTROL}" != "" ]; then propt_webCtrl_msg; fi
}

function checkif_xwindowmgr_started() {
	if [ -f /tmp/xwindowmgr_started ]; then
		echo "xwindowmgr 启动成功"  > ${APP_STDIO_NAME}
	else
		echo -e "\n\nxwindowmgr 启动失败\n当前xserver: ${XSRV_NAME}\n正在切换成Xvfb\n请重新打开虚拟电脑\n\n" | tee "/exbin/tmp/promptmsg.txt"  > ${APP_STDIO_NAME}
		echo2apk "#promptmsg"

		echo "Xvfb xlorie">${DirGuiConf}/xserver_order.txt
	fi
}

function start_xserver() {

	# test for xlorie
	# echo "192.168.1.13:2">/tmp/x_remote_server_addr

	if [ -f /tmp/x_remote_server_addr ]; then
		x11_redirect_to=`cat /tmp/x_remote_server_addr`
	fi

	if [ "$x11_redirect_to" != "" ]; then
		(sleep 3;echo killing...;pkill controllee) &
		DISPLAY=${x11_redirect_to} controllee -tryxserver
		if [ $? -ne 0]; then
			echo "远端xserver连接失败：${x11_redirect_to}"
			x11_redirect_to=
			rm -rf /tmp/x_remote_server_addr
		fi

	fi

	if [ "$x11_redirect_to" != "" ]; then

		echo "x11 redirecting..."
		pwd

		export DISPLAY=$x11_redirect_to
		export PULSE_SERVER=tcp:127.0.0.1:4713

		if [ -f /tmp/xstarted ]; then
			exit 0
		fi
	
		touch /tmp/xstarted
		if [ "$action" == "normal_start" ]; then
			echo2apk 'LinuxStarted'
		fi

		# 既然已经开启X11重定向的功能，视为XServer已经在远端运行着了
		# 这里将不再启动XServer！
		echo -e "\nX11屏幕转发地址: |${x11_redirect_to}|"
		echo -e "若转发失败，请删除这个文件：/tmp/x_remote_server_addr"
		echo -e "\n\n\n"

	else
		displayid=
		pidof_xserver=
		xserver_listen_port=

		if [ -f ~/fb_control/controllee ]; then
			echo "found newer controllee at ~/fb_control/controllee"
			echo "copy to "`pwd`
			cp -f ~/fb_control/controllee ${app_home}/
			chmod 755 ${app_home}/controllee
		fi

		# 2024.04.10 确定：6002 在部分机型上启动不了的，还是得从6004开始
		for testport in {6004..6005}
		do
			echo "testing port ${testport}"
			controllee -trybind ${testport} 2>/dev/null
			if [ $? -eq 0 ]; then
				xserver_listen_port=${testport}
				displayid=$(($testport-6000))
				break;
			fi
		done
		if [ "${displayid}" == "" ] || [ "${xserver_listen_port}" == "" ]; then
			echo -e "图形进程启动失败! \n 6002..6005 端口都被占用"
			echo "$action"

			if [ "$action" == "normal_start" ]; then
				exit 2
			fi
		fi

		export XSRV_NAME=
		export DISPLAY=:${displayid}
		export MAX_FRAMEBUFFER_WIDTH=4096
		export MAX_FRAMEBUFFER_HEIGHT=4096
		export PULSE_SERVER=tcp:127.0.0.1:4713


		if [ -f /tmp/xstarted ]; then
			exit 0
		fi

		# touch /tmp/xstarted

		if [ "$action" == "normal_start" ]; then
			source ${app_home}/droidvm_startfb.sh
		else
			source ${APP_FBFILENAME}
		fi
		# cd ~

		. ${tools_dir}/vm_getuimode.rc

		export VM_DPI=`cat ${PATH_VMDPI}`
		# if [ -f ${PATH_VMDPI} ]; then
		# 	export VM_DPI=`cat ${PATH_VMDPI}`
		# fi
		# if [ "$VM_DPI" == "" ]; then
		# 	echo 150> ${PATH_VMDPI}
		# 	export VM_DPI=150
		# fi

		PATH_XSrvOrder=${DirGuiConf}/xserver_order.txt
		if [ -f ${PATH_XSrvOrder} ]; then
			XSrvOrder=`cat ${PATH_XSrvOrder}`
		fi
		# if [ -f ${PATH_XSrvOrder}.1 ]; then
		# 	XSrvOrder=`cat ${PATH_XSrvOrder}.1`
		# fi
		if [ "${XSrvOrder}" == "" ]; then
			# XSrvOrder="Xtigervnc Xvfb" # Xwayland

			# xlorie 不能排首位，好几个机型黑屏卡住
			XSrvOrder="Xvfb xlorie Xtigervnc" # Xwayland

			# XSrvOrder="xlorie Xvfb Xtigervnc" # Xwayland
		fi

		echo ""
		echo "starting XServer:"
		echo "===================================="
		echo "  DISPLAY: $DISPLAY"
		echo "XSrvOrder: $XSrvOrder"
		echo " language: ${LC_ALL}"
		echo "   uimode: ${uimode}"
		echo "  APP_DPI: ${APP_DPI}"
		echo "   VM_DPI: ${VM_DPI}"
		echo ""

		echo ""

		# xconfig

		MAX_RESOLUTION="4096x4096"

		# java 版本的xserver: https://gitee.com/yelam2022/android-xserver
		# for i in `ls -A`; do echo "|$i|"; done
		for xsrv in ${XSrvOrder}
		do
			# echo "$xsrv"
			rm -rf /tmp/.X11-unix/*
			rm -rf /tmp/.X${displayid}-lock

			if [ "${xsrv}" == "xlorie" ]; then
				echo "正在启动xserver-xlorie"
				# ${RECOMMEND_SCREEN_WIDTH}x${RECOMMEND_SCREEN_HEIGHT}
				echo -e "xlorie 走 x11 协议，可在小于 ${MAX_RESOLUTION} 的范围内，动态调整为任意的分辨率"
				echo "#startlorie ${DISPLAY} ${VM_DPI}">$NOTIFY_PIPE

				sleep 1
				# pidof_xserver=`pidof com.zzvm:serviceX11srv`
				# echo "${xsrv}进程ID: $pidof_xserver"
				# ps ax
			fi
			if [ "${xsrv}" == "Xvfb" ]; then
				echo "正在启动xserver-xvfb"
				echo -e "xvfb 走 x11 协议，可在小于 ${MAX_RESOLUTION} 的范围内，动态调整任意的分辨率"
				export WST_SCREEN_SAVETO=/exbin/ipc/Xvfb_screen0

				# # 这几行指令会触发跟鸿蒙4.0一样的错误现象
				# mkdir -p /tmp/.X11-unix/X0 2>/dev/null
				# echo "ls -al /tmp/.X11-unix/"
				# ls -al /tmp/.X11-unix/

				# LD_LIBRARY_PATH=/gl4es-port/lib  # 可用于Xvfb，但貌似没加速作用
				Xvfb +extension XTEST +extension XFIXES +extension DAMAGE +extension RANDR +extension DOUBLE-BUFFER \
				-ac -listen tcp ${DISPLAY} -screen 0 ${MAX_FRAMEBUFFER_WIDTH}x${MAX_FRAMEBUFFER_HEIGHT}x24 -fbdir ${app_home}/ipc -dpi ${VM_DPI} &
				# nohup Xvfb +extension XTEST +extension XFIXES +extension DAMAGE +extension RANDR +extension DOUBLE-BUFFER \
				# -ac -listen tcp ${DISPLAY} -screen 0 ${MAX_FRAMEBUFFER_WIDTH}x${MAX_FRAMEBUFFER_HEIGHT}x24 -fbdir ${app_home}/ipc -dpi ${VM_DPI} &
				# -a -nocursor 

				# 分辨率比较大的时候，映射fb文件耗时久一点， 所以这里比其它两个xserver多等一秒钟
				sleep 0.1
				# pidof_xserver=`pidof Xvfb`
				# # if [ ${action} == "normal_start" ]; then
				# # fi

				# if [ "$pidof_xserver" == "" ]; then
				# 	echo ""
				# 	echo ""
				# 	echo "鸿蒙4.0中不能创建 unix-socket 文件？"
				# 	Xvfb +extension XTEST +extension XFIXES +extension DAMAGE +extension RANDR +extension DOUBLE-BUFFER \
				# 	-ac -listen tcp -nolisten unix   ${DISPLAY} -screen 0 ${MAX_FRAMEBUFFER_WIDTH}x${MAX_FRAMEBUFFER_HEIGHT}x24 -fbdir ${app_home}/ipc -dpi ${VM_DPI} &

				# 	sleep 0.1
				# 	pidof_xserver=`pidof Xvfb`
				# fi
			fi
			if [ "${xsrv}" == "Xtigervnc" ]; then
				echo "正在启动xserver-tigervnc"
				echo -e "Xtigervnc 走 x11协议，可在小于 ${MAX_RESOLUTION} 的范围内，动态调整任意的分辨率，改完源码测试，发现Xtigervnc不能在本地显示光标。。。"
				export WST_SCREEN_SAVETO=/exbin/ipc/Xvfb_screen0
				# Xtigervnc +extension XTEST +extension XFIXES +extension DAMAGE -retro ${DISPLAY} \
				# -geometry ${RECOMMEND_SCREEN_WIDTH}x${RECOMMEND_SCREEN_HEIGHT} -depth 24 -dpi ${VM_DPI} +extension MIT-SHM &

				Xtigervnc -nolisten unix +extension XTEST +extension XFIXES +extension DAMAGE +extension RANDR +extension DOUBLE-BUFFER -retro ${DISPLAY} \
				-geometry ${MAX_FRAMEBUFFER_WIDTH}x${MAX_FRAMEBUFFER_HEIGHT} -depth 24 -dpi ${VM_DPI} +extension MIT-SHM &
				# -PasswordFile /tmp/tigervnc.m4Yl5C/passwd -SecurityTypes VncAuth -auth /home/droidvm/.Xauthority &

				sleep 1
				# pidof_xserver=`pidof Xtigervnc`
			fi
			if [ "${xsrv}" == "Xwayland" ]; then
					echo -e "【仅供内部测试用】\n weston 走 wayland 协议，不支持动态调整分辨率，实测单独使用wayland很好，但套接一个xserver，就出奇的慢"
					export XDG_RUNTIME_DIR=${HOME}
					export WST_SCREEN_SAVETO=/exbin/ipc/Xvfb_screen0
					unset WAYLAND_DISPLAY
					# weston -B headless-backend.so --xwayland --use-gl --width=${RECOMMEND_SCREEN_WIDTH} --height=${RECOMMEND_SCREEN_HEIGHT} & # --scale=5 &
					weston -B headless-backend.so --use-gl --width=${RECOMMEND_SCREEN_WIDTH} --height=${RECOMMEND_SCREEN_HEIGHT} >/dev/null 2>&1 & # --scale=5 &
					export WAYLAND_DISPLAY=wayland-1
					sleep 2

					echo "正在启动xserver-xwayland"
					Xwayland ${DISPLAY} +extension XTEST +extension XFIXES +extension DAMAGE -ac -dpi ${VM_DPI} &
					# pidof_xserver=`pidof Xwayland`
					sleep 1
			fi

			# controllee -trybind ${xserver_listen_port} 2>/dev/null	# 这条指令在高通 "SDM660 AIE" CPU 上会卡住！
			# controllee -tryxserver									# 这条指令也会在部分机型上卡住

			# SEC_SLEEP=2
			# (sleep $SEC_SLEEP;echo killing...;pkill controllee) &
			controllee -tryxserver
			if [ $? -ne 0 ]; then
				export XSRV_NAME=
				echo "${xsrv} 启动失败"
				echo ""
				# if [ -f ${PATH_XSrvOrder}.1 ]; then
				# 	rm -rf ${PATH_XSrvOrder}.1
				# fi
			else
				export XSRV_NAME=${xsrv}
				# if [ -f ${PATH_XSrvOrder}.1 ]; then
				# 	cp -f ${PATH_XSrvOrder}.1  ${PATH_XSrvOrder}
				# fi
				# sleep ${SEC_SLEEP}
				break
			fi
		done

		# echo -e "\n\n"
		# echo "===================================="
		# echo "xserver进程ID: $pidof_xserver"
		# echo "===================================="
		# echo -e "\n\n"

		if [ "${XSRV_NAME}" == "" ]; then
			echo -e "图形进程启动失败! \n你需要卸载掉虚拟电脑并重新安装！\n\n注意：\n 在虚拟系统安装过程中，请保持前台运行，不要切换应用"
			echo "$action"

			if [ "$action" == "normal_start" ]; then
				exit 2
			fi

		fi
		echo "===================================="
		echo "图形进程启动成功: ${XSRV_NAME}"
		echo "===================================="

		echo "${XSRV_NAME}" > /tmp/xstarted

		ENABLE_WEB_CONTROL=""
		if [ -f /tmp/enable_webctrl ] && [ "${XSRV_NAME}" == "Xvfb" ]; then
		# if [ $SCRIPT_DEBUG -eq 1 ] && [ "${XSRV_NAME}" == "Xvfb" ]; then
		# if [ "${uimode}" == "pc" ] && [ "${XSRV_NAME}" == "Xvfb" ]; then
			ENABLE_WEB_CONTROL=" -enablews"
		fi

		echo "starting controllee: ${action}"

		# # -enablews 
		# # controllee -enablepc -block_size 100 -onreschange /exbin/tools/vm_startx.sh -fbin /exbin/ipc/Xvfb_screen0 2>&1 >$APP_STDIO_NAME &
		# controllee -enablepc -block_size 100 -onreschange /exbin/tools/vm_startx.sh -fbin /exbin/ipc/Xvfb_screen0 2>&1 &
		# # nohup controllee -enablepc -block_size 100 -onreschange /exbin/tools/vm_startx.sh -fbin /exbin/ipc/Xvfb_screen0 2>&1 &


		# 2024.05.09 测试
		controllee ${ENABLE_WEB_CONTROL} -enablepc -block_size 100 -onreschange /exbin/tools/vm_startx.sh -fbin /exbin/ipc/Xvfb_screen0 2>&1 &


		if [ -f /exbin/ipc/clipboard ]; then
			xclip -selection clipboard -i /exbin/ipc/clipboard &
		fi

		# bash

		if [ "$action" == "normal_start" ]; then
			echo2apk 'LinuxStarted'
		fi


	fi

	echo '#vmSwitch2DesktopMode'>${NOTIFY_PIPE}
}

function close_xserver() {
	rm -rf /tmp/xstarted

	echo '#vmSwitch2ConsoleMode'>${NOTIFY_PIPE}
	echo "#stoplorie">$NOTIFY_PIPE

	pkill -f com.zzvm:serviceX11srv
	pkill Xvfb
	pkill Xtigervnc
	pkill weston
	pkill controllee
}

function autoruns_before_gui() {
	dir_scripts=/etc/autoruns/autoruns_before_gui
    if [ -d ${dir_scripts} ]; then
        # ls -al ${dir_scripts}
        echo "${dir_scripts} 加载中..."
        for i in ${dir_scripts}/*.sh; do
            if [ -r $i ]; then
                echo "$i"
                . $i
            fi
        done
        unset i
    fi
}

function autoruns_after_gui() {
    # lxterminal patch
	dir_scripts=/etc/autoruns/autoruns_after_gui
    if [ -d ${dir_scripts} ]; then
        # ls -al ${dir_scripts}
        echo -e "\n正在启动：${dir_scripts}/*.sh"
        for i in ${dir_scripts}/*.sh; do
            if [ -r $i ]; then
                echo "$i"
                . $i
            fi
        done
        unset i
    fi

	dir_scripts=/etc/autoruns/autoruns_after_gui
    if [ -d ${dir_scripts} ]; then
        # ls -al ${dir_scripts}
        echo -e "\n正在启动：${dir_scripts}/*.desktop"
        for i in ${dir_scripts}/*.desktop; do
            if [ -r $i ]; then
                echo "$i"
                xopen $i
            fi
        done
        unset i
    fi
}

function setup_theme() {
	echo "正在设置 系统主题 环境变量"
	# export GTK2_RC_FILES=/usr/share/themes/Adwaita/gtk-2.0/gtkrc

	GTK_THEME=`cat ${PATH_GTK_THEME_NAME}`
	if [ "${GTK_THEME}" == "" ]; then
		GTK_THEME="Adwaita"
	fi
	export GTK_THEME

	echo "export GTK_THEME=\"${GTK_THEME}\"" >> /etc/autoruns/vm_runtime_env.sh

	mkdir -p ~/.config/gtk2/
	echo ''								> ~/.config/gtk2/gtkrc
	echo 'include "gtk_icon.rc"'		>>~/.config/gtk2/gtkrc
	echo 'include "gtk_theme.rc"'		>>~/.config/gtk2/gtkrc
	echo 'include "gtk_font.rc"'		>>~/.config/gtk2/gtkrc
	echo ''														>>~/.config/gtk2/gtkrc
	# echo 'include "/usr/share/themes/Adwaita/gtk-2.0/gtkrc"'	>>~/.config/gtk2/gtkrc

	if [ ! -f ~/.config/gtk2/gtk_icon.rc ]; then
		# echo 'gtk-icon-theme-name = "Adwaita"'					> ~/.config/gtk2/gtk_icon.rc
		echo 'gtk-icon-theme-name = "elementary-xfce"'			> ~/.config/gtk2/gtk_icon.rc
		echo 'gtk-cursor-theme-size = 64'						>>~/.config/gtk2/gtk_icon.rc
	fi

	# if [ ! -f ~/.config/gtk2/gtk_theme.rc ]; then
	# 	echo 'gtk-theme-name = "Adwaita"'						> ~/.config/gtk2/gtk_theme.rc
	# fi
	echo "gtk-theme-name = \"${GTK_THEME}\""					> ~/.config/gtk2/gtk_theme.rc

	if [ ! -f ~/.config/gtk2/gtk_font.rc ]; then
		echo 'gtk-font-name="Sans 12"'							> ~/.config/gtk2/gtk_font.rc
	fi

	export GTK2_RC_FILES=~/.config/gtk2/gtkrc



}

function setup_vars() {
	export PATH=$PATH:/usr/games
}

function start_xwindowmgr() {

	# 启动过程中，图形界面还未完全加载时，如果用户旋转了屏幕，得杀的旧的检测进程
	pkill -f vm_startex_delay_check_winmgr.sh
	vm_startex_delay_check_winmgr.sh &
	# rm -rf /tmp/xwindowmgr_started
	# (sleep 8;checkif_xwindowmgr_started) &

	# if [ "${force_copy_xconf_files}" == "" ] || [ ${force_copy_xconf_files} -eq 0 ]; then
	# 	if [ -f ${APP_FILENAME_URLTOOLS} ]; then
	# 		export force_copy_xconf_files=1
	# 	else
	# 		export force_copy_xconf_files=0
	# 	fi
	# fi
	source ${tools_dir}/vm_configx.sh
	source ${tools_dir}/vm_onXstarted.sh

	setup_theme
	setup_vars

	ps -ax | grep svc_virgl | grep -v grep
	if [ $? -eq 0 ]; then
		# export GALLIUM_DRIVER=virpipe
		# export MESA_GL_VERSION_OVERRIDE=4.0
		echo ""
	fi

	# 2024.05.18 挪到这里
	echo "正在运行 xconfig"
	xconfig



	# echo "USE_XFCE4_3: ${USE_XFCE4}"
	tmp_dsk_file="${HOME}/Desktop/switch_desktop_env.desktop"
	if [ ${USE_XFCE4} -eq 0 ]; then
		echo "正在启动 jwm"
		jwm &
		sleep 1
		echo "正在启动 pcmanfm"
		pcmanfm --desktop &
		# (whsdfsdssdfile true; do pcmanfm --desktop; done) &
		if [ -f ${app_home}/app_boot_config/opacity_enable ]; then
			echo "正在启动透明显示效果混合程序"
			compton &
		fi

		which startxfce4 >/dev/null 2>&1
		if [ $? -eq 0 ]; then
			echo "[Desktop Entry]"				> ${tmp_dsk_file}
			echo "Encoding=UTF-8"				>>${tmp_dsk_file}
			echo "Version=0.9.4"				>>${tmp_dsk_file}
			echo "Type=Application"				>>${tmp_dsk_file}
			echo "Name=切换到xfce"				>>${tmp_dsk_file}
			echo "Exec=/exbin/tools/vm_set_desktop_env.sh xfce"	>>${tmp_dsk_file}
			echo ""								>>${tmp_dsk_file}
		fi
	else
		echo "正在启动 xfce4"
		unset GALLIUM_DRIVER
		unset MESA_GL_VERSION_OVERRIDE
		startxfce4 &

		echo "[Desktop Entry]"				> ${tmp_dsk_file}
		echo "Encoding=UTF-8"				>>${tmp_dsk_file}
		echo "Version=0.9.4"				>>${tmp_dsk_file}
		echo "Type=Application"				>>${tmp_dsk_file}
		echo "Name=切换到pcmanfm"			>>${tmp_dsk_file}
		echo "Exec=/exbin/tools/vm_set_desktop_env.sh pcmanfm"	>>${tmp_dsk_file}
		echo ""								>>${tmp_dsk_file}
	fi

	# dbus-launch --exit-with-session startxfce4
	# spacefm --desktop &
	# pcmanfm --set-wallpaper=#223366 &
	# jwm &
	# startxfce4 &
	# icewm-session &
	# lxsession -s LXDE &
	# GALLIUM_DRIVER=virpipe  MESA_GL_VERSION_OVERRIDE=4.0 wine explorer /desktop=shell,${RECOMMEND_SCREEN_WIDTH}x${RECOMMEND_SCREEN_HEIGHT} &

	sleep 1

	# Xft.size: 16
	# Xcursor.size: 32		# 这个设置项，不起作用
	# Xcursor.size: 64px	# 这个设置项也不起作用
	# Xcursor.theme: Adwaita
	# cat <<- EOF > ~/.Xresources

	# Xft.dpi: ${VM_DPI}

	# xterm*locale: zh_CN.UTF-8
	# xterm*faceName: Monospace
	# xterm*faceSize: 10
	# xterm*scrollBar: true
	# xterm*rightScrollBar: true

	# gxmessage*locale: zh_CN.UTF-8
	# gxmessage*faceName: Monospace
	# gxmessage*faceSize: 30
	# EOF
	# xrdb -merge ~/.Xresources

	# # 放这里 jwm 在 xlorie 下鼠标指针不会显示大指针
	# echo "正在运行 xconfig"
	# xconfig

	if [ -f /tmp/xstarted ]; then export XSRV_NAME=`cat /tmp/xstarted 2>/dev/null`;	fi
	if [ "${XSRV_NAME}" == "Xvfb" ] || [ "${XSRV_NAME}" == "Xtigervnc" ]; then # || [ "${XSRV_NAME}" == "xlorie" ]; then
		echo "正在将画面铺满屏幕"
		resize_screen ${RECOMMEND_SCREEN_WIDTH} ${RECOMMEND_SCREEN_HEIGHT}
	fi

	touch /tmp/xwindowmgr_started

	rm_flag_files &

	echo "正在启动 vm_onZerogo"
	${tools_dir}/vm_onZerogo.sh "$action"
}

function close_xwindowmgr() {
	pkill pcmanfm
	pkill jwm
	pkill fcitx
}

function notify_app() {
	echo "#x11restarted" > ${NOTIFY_PIPE}
}

function performe_normal_start() {
	rm -rf /tmp/x_remote_server_addr


	autoruns_before_gui

	start_xserver
	run_once
	start_xwindowmgr

	autoruns_after_gui
}

function performe_sresize() {
	# if [ -f /tmp/xstarted ]; then export XSRV_NAME=`cat /tmp/xstarted 2>/dev/null`;	fi
	# if [ "${XSRV_NAME}" == "Xtigervnc" ]; then
	# 	close_xwindowmgr
	# 	pid_tvnc=`pidof Xtigervnc`

	# 	echo "pid_tvnc: $pid_tvnc"
	# 	echo $APP_FBFILENAME
	# 	cat $APP_FBFILENAME

	# 	if [ "$pid_tvnc" != "" ]; then
	# 		echo "正在添加显示分辨率: ${RECOMMEND_SCREEN_WIDTH}x${RECOMMEND_SCREEN_HEIGHT}"
	# 		kill -s SIGUSR1 $pid_tvnc
	# 	fi
	# 	sleep 0.2
	# 	source $APP_FBFILENAME
	# 	xrandr
	# 	xrandr -s ${RECOMMEND_SCREEN_WIDTH}x${RECOMMEND_SCREEN_HEIGHT}
	# 	sleep 0.2

	# 	notify_app
	# 	start_xwindowmgr
	# else
		close_xwindowmgr
		# close_xserver
		# start_xserver
		resize_screen ${RECOMMEND_SCREEN_WIDTH} ${RECOMMEND_SCREEN_HEIGHT}
		notify_app
		start_xwindowmgr
	# fi
}

function performe_xserver() {
	close_xwindowmgr
	close_xserver
	init_uimode
	start_xserver
	notify_app
	start_xwindowmgr
}

function performe_xwinman() {
	close_xwindowmgr
	start_xwindowmgr
}

function run_as_daemon() {

	echo "正在为当前用户调用 /etc/profile"
	source /etc/profile

	init_uimode

	if [ -x ./custom_startx.sh ]; then
		echo "正在调用 启动X的自定义脚本"
		# ./custom_startx.sh  2>&1 >$APP_STDIO_NAME <$APP_STDIO_NAME &
		./custom_startx.sh  2>&1 &
		echo2apk 'LinuxStarted'
		exit 0
	fi


	USE_XFCE4=`cat ${app_home}/app_boot_config/cfg_use_xfce4.txt 2>/dev/null`
	# echo "USE_XFCE4_1: ${USE_XFCE4}"
	if [ "$USE_XFCE4" == "" ]; then
		# echo "cat ${app_home}/app_boot_config/cfg_use_xfce4.txt"
		# cat ${app_home}/app_boot_config/cfg_use_xfce4.txt 2>/dev/null
		USE_XFCE4=0
	fi

	which startxfce4 >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		# echo "startxfce4 not found"
		USE_XFCE4=0
	fi
	# echo "USE_XFCE4_2: ${USE_XFCE4}"

	performe_normal_start
	
	# 进程不退出！
	rm -rf ${X_DAEMON_PIPE}
	mkfifo ${X_DAEMON_PIPE}
	while true
	do
		X_ACTION_REQ=`head -n 1 ${X_DAEMON_PIPE}`
		echo "X_ACTION_REQ: $X_ACTION_REQ"
		# source $0

		cd ~
		source /exbin/tools/vm_config.sh
		case "${X_ACTION_REQ}" in
			"sresize")
				performe_sresize
				;;
			"xserver")
				performe_xserver
				;;
			"xwinman") 
				performe_xwinman
				;;
			*)
				;;
		esac
	done
}




echo ""
echo ""
echo "startx action: ${action}"
cd ~
source /exbin/tools/vm_config.sh

case "${action}" in
	"sresize")
		echo "sresize">${X_DAEMON_PIPE}
		;;
	"xserver")
		echo "xserver">${X_DAEMON_PIPE}
		;;
	"xwinman") 
		echo "xwinman">${X_DAEMON_PIPE}
		;;
	*)
		run_as_daemon
		;;
esac

