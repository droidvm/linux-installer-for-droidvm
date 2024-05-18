#!/bin/bash

: '

https://www.jianshu.com/p/6d45af6d8966
https://www.bilibili.com/read/cv14624341/   # 在基于Debian系统的主机上安装及使用Klipper
https://gitee.com/mirrors_Gottox/octo4a/blob/master/scripts/setup-klipper.sh
https://gitee.com/miroky/klipper/blob/master/scripts/install-ubuntu-22.04.sh

'

SWNAME=pysolfc
DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}
SWVER=3.5.5

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh


function sw_download() {
	apt-get install -y git
	exit_if_fail $? "git安装失败"

	case "${CURRENT_VM_ARCH}" in
		"arm64")
				app_dir=/opt/apps/${SWNAME}
				swUrl=https://mirror.ghproxy.com/https://github.com/shlomif/PySolFC
				download_file3 "${app_dir}" "${swUrl}"
				exit_if_fail $? "下载失败，网址：${swUrl}"

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
				apt-get install -y gettext python3-venv python3-setuptools libjpeg-dev pysolfc-cardsets make # python3-attr 
				exit_if_fail $? "依赖库安装失败"

				export PKGTREE=${app_dir}
				export env_dir=$PKGTREE/env

				echo "正在创建python vENV"
				python3 -m venv ${env_dir}

				${env_dir}/bin/pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
				# ${env_dir}/bin/python3 -m pip install --upgrade setuptools wheel
				${env_dir}/bin/pip install setuptools wheel configobj six attr attrs random2 pysol-cards
				# ${env_dir}/bin/pip install six
				# # ${env_dir}/bin/pip install attrs==23.2.0 -i https://pypi.org/simple # 从官方仓库安装
				# ${env_dir}/bin/pip uninstall attrs
				# ${env_dir}/bin/pip install random2
				# ${env_dir}/bin/pip install pysol-cards

				# pysolfc 不支持中文哦。。。
				# sed -i "s|de fr|de fr zh_CN.UTF-8|" ${app_dir}/Makefile
				sed -i "s|\#\!/usr/bin/env python|\#\!${env_dir}/bin/python|" ${app_dir}/setup.py
				sed -i "s|\#\!/usr/bin/env python3|\#\!${env_dir}/bin/python3|" ${app_dir}/scripts/all_games.py
				sed -i "s|\#\!/usr/bin/env python3|\#\!${env_dir}/bin/python3|" ${app_dir}/html-src/gen-html.py
				cd ${app_dir} && ./contrib/install-pysolfc.sh

				cp -rf /usr/share/games/pysolfc/. ${app_dir}/data/

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
				rm2desktop ${SWNAME}.desktop

				STARTUP_SCRIPT_FILE=${app_dir}/pysolfc
				cat <<- EOF > ${STARTUP_SCRIPT_FILE}
					#!/bin/bash
					# export GALLIUM_DRIVER=virpipe
					# export MESA_GL_VERSION_OVERRIDE=4.0
					exec ${env_dir}/bin/python3 ${PKGTREE}/pysol.py \$@
				EOF
				chmod 755 ${STARTUP_SCRIPT_FILE}
				cp -f ${STARTUP_SCRIPT_FILE}  /usr/bin/

				echo "正在生成桌面文件"
				tmpfile=${DIR_DESKTOP_FILES}/${SWNAME}.desktop
				echo "[Desktop Entry]"			> ${tmpfile}
				echo "Encoding=UTF-8"			>>${tmpfile}
				echo "Version=0.9.4"			>>${tmpfile}
				echo "Type=Application"			>>${tmpfile}
				echo "Name=${SWNAME}"			>>${tmpfile}
				echo "Icon=${app_dir}/data/pysol.ico"	>> ${tmpfile}
				echo "Exec=pysolfc"						>> ${tmpfile}
				cp2desktop ${tmpfile}

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
