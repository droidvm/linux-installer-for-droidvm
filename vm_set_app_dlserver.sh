#!/bin/bash


action=$1
if [ "$action" == "" ]; then
	action=tencent
fi

rlt=1
if [ "$action" == "show" ]; then
	notepad ${APP_FILENAME_URLDLSERVER} &
	exit 0
elif [ "$action" == "tencent" ]; then
	shortmsg="腾讯云"
	echo "export APP_URL_DLSERVER=https://droidvmres-1316343437.cos.ap-shanghai.myqcloud.com"	> ${APP_FILENAME_URLDLSERVER}
	rlt=$?
elif [ "$action" == "pubweb" ]; then
	shortmsg="虚拟电脑官方网站"
	echo "export APP_URL_DLSERVER=http://124.221.123.125/apps/droidvm/downloads"				> ${APP_FILENAME_URLDLSERVER}
	rlt=$?
else
	shortmsg="本地调试服务器"
	echo "export APP_URL_DLSERVER=http://192.168.1.5/apps/droidvm/downloads"					> ${APP_FILENAME_URLDLSERVER}
	rlt=$?
fi

if [ $rlt -eq 0 ]; then
	cat <<- EOF > /tmp/msg.txt

	系统下载地址已设置为：${shortmsg},
	下次打开app时生效。

	以下资源文件会从此地址下载：
	-----------------------------------------------------------------
		远程文件名                      | 本地文件路径
	-----------------------------------------------------------------
	1). 系统镜像                        | \${app_home}/ (解压完删除)
	2). linux-installer-for-droidvm.zip | \${app_home}/tools.zip
	3). ex_ndk_tools.zip                | \${tools_dir}/ex_ndk_tools.zip
	4). 软件管家收录的软件的安装包      | 软件管家临时目录
	-----------------------------------------------------------------

	EOF
else
	cat <<- EOF > /tmp/msg.txt

	系统下载地址设置失败

	EOF
fi

gxmessage -title "系统下载点" -file /tmp/msg.txt -center
