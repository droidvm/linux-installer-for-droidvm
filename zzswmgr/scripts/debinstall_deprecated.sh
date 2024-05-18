#!/bin/bash


SWNAME=debinstall
DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}


action=$1
insdeb=$2
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh


echo "正在安装/卸载本地DEB包: ${insdeb}"
echo -e "此操作需要输入当前用户的密码以提升权限(linux终端下输密码不会显示*号)"
echo -e "验证成功后才能继续，默认密码：droidvm"
# echo -e "验证成功后才能继续，\\e[96m默认密码：droidvm\\e[0m"
sudo echo ""

if [ "${action}" == "导入" ]; then
	echo "暂不支持卸载"
	exit 1
elif [ "${action}" == "卸载" ]; then
	echo "暂不支持卸载"
	exit 1
else
	ln -sf "${insdeb}" ./tmp/tmp.deb

	pkgname=`get_debfile_pkgname ./tmp/tmp.deb`
	if [ "wps-office" == "${pkgname}" ]; then
		gxmessage -title "提示" $'\n此安装包中的wps不能直接安装\n请使用桌面上的 软件管家 安装wps\n\n' -center
		exit 5
	fi

	echo ""
	echo "安装后如果需要卸载，您可以使用如下指令卸载这个安装包："
	echo "====================================================================================="
	echo "sudo dpkg --remove --force-remove-reinstreq ${pkgname}  # 适用于无法完整安装的软件包"
	echo "sudo apt autoremove --purge -y              ${pkgname}  # 适用于已完整安装了的软件包"
	echo ""

	# echo "ln -sf \"${insdeb}\" ./tmp/tmp.deb"
	# ls -al ./tmp/tmp.deb
	# gxmessage -title "提示" "安装已完成"  -center
	install_deb ./tmp/tmp.deb
	exit_if_fail $? "安装失败，软件包：${DEB_PATH}"

	gxmessage -title "提示" "安装已完成"  -center

	exit 0
fi
