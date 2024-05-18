#!/bin/bash

ActivityName=$1
if [ "${ActivityName}" == "" ]; then
    echo "要启动的应用包名不能为空"
    exit 1
fi

DIRCONF=~/.config/android-virt-display
FILCONF=${DIRCONF}/config.rc
if [ -d ${DIRCONF} ]; then
    mkdir -p ${DIRCONF} 2>/dev/null
fi
if [ -f ${FILCONF} ]; then
    . ${FILCONF}
fi

function saveconf() {
	cat <<- EOF > ${FILCONF}
		# 安卓虚拟屏幕信息
		# 宽
		export virtdisplayw=${virtdisplayw}

		# 高
		export virtdisplayh=${virtdisplayh}

		# dpi
		export virtdisplayd=${virtdisplayd}

		# 显示提示信息
		export virtdisplaym=${virtdisplaym}
	EOF
}


#宽，高，dpi，以及是否显示提示信息
virtdisplayw=${virtdisplayw:=768}
virtdisplayh=${virtdisplayh:=1367}
virtdisplayd=${virtdisplayd:=240}
virtdisplaym=${virtdisplaym:=1}
saveconf

if [ ${virtdisplaym} -ne 0 ]; then
	cat <<- EOF > /tmp/msg.txt

		提示
		================================
		 1). 此功能依赖adb自连通道(设备得先打开 tcp-adb 调试通道)
		 2). 此功能目前不能在投屏状态下使用(和手机投屏功能冲突！)
		 3). 请先在软件管家中安装 adb 和 scrcpy

	EOF
    gxmessage -title "提示" -file /tmp/msg.txt   -center -buttons "确定:1,不再显示:0"
    if [ $? -ne 1 ]; then
        virtdisplaym=0
        saveconf
    fi
fi


which adb >/dev/null 2>&1
if [ $? -ne 0 ]; then
    gxmessage -title "错误" "请先在软件管家中安装 adb 和 scrcpy"  -center
    exit 1
fi

which scrcpy >/dev/null 2>&1
if [ $? -ne 0 ]; then
    gxmessage -title "错误" "请先在软件管家中安装 scrcpy 和 adb"  -center
    exit 1
fi


adb shell pwd >/dev/null 2>&1
if [ $? -ne 0 ]; then
    gxmessage -title "错误" $'\nadb未连接\n请运行桌面上的ADBme，并按步骤连接\n\n'  -center
    exit 1
fi

adb shell dumpsys display|grep "type=EXTERNAL" >/dev/null 2>&1
if [ $? -eq 0 ]; then
    gxmessage -title "错误" $'\n投屏状态下此功能不可用\n\n'  -center
    exit 1
fi

echo "#createAndroidVirtDisplay ${virtdisplayw} ${virtdisplayh} ${virtdisplayd}" > "${NOTIFY_PIPE}"
sleep 1

echo -e "\n\n\n"
virDisplayid=`adb shell dumpsys window displays|grep mDisplayId|grep -v mDisplayId=0|awk '{ printf($2);  }'|cut -c 12-`
if [ "$virDisplayid" == "" ]; then
    gxmessage -title "错误" "检测不到安卓虚拟屏幕"  -center
    exit 1
    # virDisplayid=0
fi

echo "检测到扩展屏幕，屏幕ID: $virDisplayid"
echo "virDisplayid: $virDisplayid"
adb shell am start --display $virDisplayid -S ${ActivityName} # -S 是先杀掉旧进程

pidof scrcpy
if [ $? -ne 0 ]; then
    scrcpy --display=${virDisplayid} -b 20M
    # scrcpy --display=33 -b 50M --print-fps --render-driver=opengl # software
fi



: '

adb shell dumpsys window w | grep mCurrent  # 查看包名

com.ss.android.ugc.aweme/.splash.SplashActivity
adb shell am start --display $virDisplayid --windowingMode 4 com.zzvm/.VirtActivity
adb shell am start --display $virDisplayid com.microsoft.launcher/.Launcher
adb shell am start --display $virDisplayid com.zzvm/com.zzvm.MainActivity
adb shell am start --display $virDisplayid --windowingMode 100 com.tencent.mm/.ui.LauncherUI
adb shell am start --display $virDisplayid --windowingMode 4 com.zzvm/.VirtActivity
adb shell am kill com.ss.android.ugc.aweme
adb shell am force-stop com.tencent.mm
adb shell am force-stop com.ss.android.ugc.aweme
adb shell am force-stop tv.danmaku.bili


# 浮窗启动
am start --windowingMode 100 com.tencent.mm/.ui.LauncherUI
virDisplayid=76
adb shell am start --display $virDisplayid --windowingMode 100 com.tencent.mm/.ui.LauncherUI



am start --display 38 --windowingMode 4 com.zzvm/.VirtActivity          # 这个可以正常启动
am start --windowingMode 100                          # 浮窗模式
am start --windowingMode 5 -S com.zzvm/.VirtActivity  # 正常模式
am start --windowingMode 4 -S com.zzvm/.VirtActivity  # 正常模式
am start --windowingMode 3 -S com.zzvm/.VirtActivity  # 分屏模式
am start --windowingMode 2 -S com.zzvm/.VirtActivity  # 画中画，不可拖动，也不同于系统浮窗，也不显示在任务切换面板中！但在任务切换面板中点清除时，会杀掉父进程为1的所有进程
am start --windowingMode 2 -S com.zzvm/.MainActivity  # 画中画，不可拖动，也不同于系统浮窗，也不显示在任务切换面板中！但在任务切换面板中点清除时，会杀掉父进程为1的所有进程
am start --windowingMode 1 -S com.zzvm/.VirtActivity  # 正常模式
am start --windowingMode 0 -S com.zzvm/.VirtActivity  # 正常模式


'
