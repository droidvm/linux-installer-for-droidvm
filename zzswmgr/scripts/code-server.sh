#!/bin/bash

SWNAME=code-server
SWVER=4.23.1

# 注意安装顺序，后装者依赖前装者
DEB_PATH1=./downloads/${SWNAME}.deb

DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}
app_dir=/opt/apps/${SWNAME}
srvprt=5560

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh

function sw_download() {
	tmpdns=`cd /exbin && droidexec ./vm_getHostByName.sh mirror.ghproxy.com`
	exit_if_fail $? "DNS解析失败"
	echo "$tmpdns" >> /etc/hosts

	case "${CURRENT_VM_ARCH}" in
		"arm64")
			swUrl="https://mirror.ghproxy.com/https://github.com/coder/code-server/releases/download/v${SWVER}/code-server_${SWVER}_arm64.deb"
			download_file_axel "${DEB_PATH1}" "${swUrl}"
			exit_if_fail $? "下载失败，网址：${swUrl}"
		;;
		"amd64")
			swUrl="https://mirror.ghproxy.com/https://github.com/coder/code-server/releases/download/v${SWVER}/code-server_${SWVER}_amd64.deb"
			download_file_axel "${DEB_PATH1}" "${swUrl}"
			exit_if_fail $? "下载失败，网址：${swUrl}"
		;;
		*) exit_unsupport ;;
	esac
}

function sw_install() {

	# mkdir -p ${app_dir}

	# echo "正在解压. . ."
	# tar -xzf ${DEB_PATH1} --overwrite -C ${app_dir}
	# exit_if_fail $? "安装失败，软件包：${DEB_PATH1}"

	install_deb ${DEB_PATH1} # ${DEB_PATH2} ${DEB_PATH3}
	exit_if_fail $? "安装失败，软件包：${DEB_PATH}"

}

function sw_create_desktop_file() {
	echo "正在生成桌面文件"

	tmpfile=${DIR_DESKTOP_FILES}/${SWNAME}.desktop
	cat <<- EOF > ${tmpfile}
		[Desktop Entry]
		Name=${SWNAME}
		GenericName=${SWNAME}
		Exec=${SWNAME}
		Terminal=true
		Type=Application
	EOF
	cp2desktop ${tmpfile}

	mkdir -p /home/${ZZ_USER_NAME}/.config/code-server
	cat <<- EOF > /home/${ZZ_USER_NAME}/.config/code-server/config.yaml
		bind-addr: 0.0.0.0:${srvprt}
		auth: password
		password: droidvm
		cert: false
	EOF

	# echo "正在生成启动程序"
	# tmpfile=/usr/bin/${SWNAME}
	# cat <<- EOF > ${tmpfile}
	# 	#!/bin/bash
	# 	tmp_server_port=${srvprt}
	# 	function showaddr2() {
	# 		/exbin/tools/busybox ifconfig 2>/dev/null|grep '192'| \\
	# 		awk '{print \$2}'|awk -v FS=":" -v OFS="" -v header="http://" -v tail=":\${tmp_server_port}" '{print header,\$2,tail}' \\
	# 		>/tmp/ip.txt

	# 		echo -e "\\e[96m请使用浏览器访问：\\e[0m"
	# 		cat /tmp/ip.txt
	# 		echo ""

	# 		echo "默认用户：droidvm"
	# 		echo "默认密码：droidvm"
	# 	}

	# 	if [ ! -f ${app_dir}/filebrowser.db ]; then
	# 		echo "正在初始化配置"
	# 		cd ${app_dir}
	# 		${app_dir}/filebrowser -d ${app_dir}/filebrowser.db config init
	# 		${app_dir}/filebrowser -d ${app_dir}/filebrowser.db config set --address 0.0.0.0
	# 		${app_dir}/filebrowser -d ${app_dir}/filebrowser.db config set --port ${srvprt}
	# 		${app_dir}/filebrowser -d ${app_dir}/filebrowser.db users add droidvm droidvm --perm.admin --locale zh-cn

	# 		# 查看配置
	# 		# ${app_dir}/filebrowser -d ${app_dir}/filebrowser.db config cat
	# 		# ${app_dir}/filebrowser -d ${app_dir}/filebrowser.db users ls
	# 	fi
	# 	# 延后2秒显示
	# 	( sleep 2; showaddr2 & ) &

	# 	cd ${app_dir}
	# 	${app_dir}/filebrowser -d ${app_dir}/filebrowser.db -a 0.0.0.0 -p \${tmp_server_port} -r ~/  
	# 	read -s -n1 -p "按任意键退出"
	# EOF
	# chmod 755 ${tmpfile}

	# echo "正在复制初始配置文件"
	# cp -f ${ZZSWMGR_MAIN_DIR}/scripts/res/alist/data.db-wal  ${app_dir}/data/

	gxmessage -title "提示"     $'\n安装完成\n\n'  -center
}

if [ "${action}" == "卸载" ]; then
	# echo "暂不支持卸载"
	# exit 1
	rm -rf ${DEB_PATH1}

	rm -rf /usr/bin/${SWNAME}

	rm -rf /opt/apps/${SWNAME}

	rm2desktop ${SWNAME}.desktop

	apt-get clean
else
	sw_download
	sw_install
	sw_create_desktop_file
fi

