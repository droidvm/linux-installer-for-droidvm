#!/bin/bash

action=$1

tmpfilename=/exbin/sysvipc

if [ "$action" == "" ]; then
	action=erase
fi

if [ "$action" == "erase" ]; then
	rm -rf $tmpfilename
	gxmessage -title "sysvipc标志文件" "功能已禁用，重启生效"  -center
	exit 0
fi

touch $tmpfilename
chmod 666 $tmpfilename


cat <<- EOF > /tmp/debugflagmsg.txt

sysvipc功能启用标志文件已创建
下次打开app时生效
标志文件路径：/exbin/sysvipc

此功能仅用于开发调试。

要擦除此标志文件,
请点击 "开始使用" -> "控制台"" -> "proot管理" -> "sysvipc功能" -> "关" 菜单项.

请注意：
#########################################################################
# proot-termux 的 --sysvipc 参数会影响 virgl, 也会影响 box64 运行 ndk() ！！！
# 
# 2023-08-04 确认：
# 带 --sysvipc 参数启动proot-termux，vscode就白屏(vscoce基于Electron)
# 带 --sysvipc 参数启动proot-termux，box64 + ndk 内存分配出错
# 无 --sysvipc 参数启动proot-termux，vscode正常
# 无 --sysvipc 参数启动proot-termux，box64 + ndk 内存分配也出错
#
# 使用自己编译的proot-userland, vscode正常
# 使用自己编译的proot-userland, box64 + ndk 内存分配也出错, box64+wine64正常, box86+wine32正常
#
# 使用网上下载的proot-userland, vscode正常
# 使用网上下载的proot-userland, box64 + ndk 正常,           box64+wine64正常, box86+wine32卡死->sendmsg not implement
# 
#########################################################################

关闭这个窗口不影响功能.

EOF

gxmessage -title "sysvipc标志文件" -file /tmp/debugflagmsg.txt -center




