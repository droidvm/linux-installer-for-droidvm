#!/bin/bash

: '

生成证书
cd /opt/apps/alist
openssl req -newkey rsa:2048 -nodes -keyout example.key -x509 -days 365 -out example.crt

'

SWNAME=alist
# SWVER=18.2.3

# 注意安装顺序，后装者依赖前装者
DEB_PATH1=./downloads/${SWNAME}.tar.gz

DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}
app_dir=/opt/apps/${SWNAME}

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh

function sw_download() {
	tmpdns=`cd /exbin && droidexec ./vm_getHostByName.sh mirror.ghproxy.com`
	exit_if_fail $? "DNS解析失败"
	echo "$tmpdns" >> /etc/hosts

	case "${CURRENT_VM_ARCH}" in
		"arm64")
			# https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/pool/universe/k/kdenlive/
			swUrl="https://mirror.ghproxy.com/https://github.com/alist-org/alist/releases/download/v3.33.0/alist-android-arm64.tar.gz"
			download_file_axel "${DEB_PATH1}" "${swUrl}"
			exit_if_fail $? "下载失败，网址：${swUrl}"
		;;
		"amd64")
			swUrl="https://mirror.ghproxy.com/https://github.com/alist-org/alist/releases/download/v3.33.0/alist-linux-amd64.tar.gz"
			download_file_axel "${DEB_PATH1}" "${swUrl}"
			exit_if_fail $? "下载失败，网址：${swUrl}"
		;;
		*) exit_unsupport ;;
	esac
}

function sw_install() {

	# mkdir ${ZZSWMGR_APPI_DIR}/alist
	mkdir -p ${app_dir}

	echo "正在解压. . ."
	tar -xzf ${DEB_PATH1} --overwrite -C ${app_dir}
	exit_if_fail $? "安装失败，软件包：${DEB_PATH1}"


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

	echo "正在生成启动程序"
	tmpfile=/usr/bin/${SWNAME}
	cat <<- EOF > ${tmpfile}
		#!/bin/bash
		function showaddr2() {
			tmp_server_port=5244
			/exbin/tools/busybox ifconfig 2>/dev/null|grep '192'| \\
			awk '{print \$2}'|awk -v FS=":" -v OFS="" -v header="http://" -v tail=":\${tmp_server_port}" '{print header,\$2,tail}' \\
			>/tmp/ip.txt

			echo -e "\\e[96m请使用浏览器访问：\\e[0m"
			cat /tmp/ip.txt
			echo ""

			echo "默认用户：admin"
			echo "默认密码：droidvm"
		}

		# 延后2秒显示
		( sleep 2; showaddr2 & ) &

		cd ${app_dir}
		exec ./alist server

		read -s -n1 -p "按任意键退出"
	EOF
	chmod 755 ${tmpfile}

	# echo "正在复制初始配置文件"
	# cp -f ${ZZSWMGR_MAIN_DIR}/scripts/res/alist/data.db-wal  ${app_dir}/data/

	echo "正在初始化密码"
	cd ${app_dir}
	./alist admin set droidvm
	cd ${ZZSWMGR_MAIN_DIR}


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

