#!/bin/bash

: '
创建的文件：/exbin/debug
影响的文件：droidvm_vars_setup.sh
影响的变量：SCRIPT_DEBUG
'

action=$1

tmpfilename=/exbin/debug

if [ "$action" == "" ]; then
	action=erase
fi

if [ "$action" == "erase" ]; then
	rm -rf $tmpfilename
	gxmessage -title "debug标志文件" "调试标志已删除"  -center
	exit 0
fi

touch $tmpfilename
chmod 666 $tmpfilename


cat <<- EOF > /tmp/debugflagmsg.txt

调试标志文件已创建
下次打开app时生效
文件路径：/exbin/debug

此功能仅用于开发调试。

要擦除此标志文件,
请点击 "开始使用" -> "控制台" -> "调试标记" -> "关" 菜单项.


关闭这个窗口不影响功能.

EOF

gxmessage -title "debug标志文件" -file /tmp/debugflagmsg.txt -center




