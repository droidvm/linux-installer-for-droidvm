#!/bin/bash

: '

https://www.jianshu.com/p/6d45af6d8966
https://www.bilibili.com/read/cv14624341/   # 在基于Debian系统的主机上安装及使用Klipper
https://gitee.com/miroky/kiauh/blob/master/scripts/moonraker.sh
https://gitee.com/miroky/klipper/blob/master/scripts/install-ubuntu-22.04.sh
https://docs.mainsail.xyz/setup/getting-started/manual-setup

https://gitee.com/Neko-vecter/mainsail-releases/releases/download/v2.8.0/mainsail.zip
https://docs.mainsail.xyz/setup/getting-started/manual-setup	# mainsail 官网上的安装教程

https://github.com/Arksine/moonraker/blob/master/docs/installation.md	# moonraker 官方文档

https://gitee.com/Neko-vecter/fluidd-config			# fluidd 官方配置文档


修复功能问题：
https://docs.fluidd.xyz/configuration/initial_setup
https://docs.fluidd.xyz/configuration/moonraker


'

SWNAME=fluidd
DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh

function sw_download() {
	case "${CURRENT_VM_ARCH}" in
		"arm64")

				if [ ! -d /opt/apps/klipper ] || [ ! -d /opt/apps/moonraker ]; then
					echo ""								> /tmp/msg.txt
					echo "请先安装klipper和moonraker"	>>/tmp/msg.txt
					echo ""								>>/tmp/msg.txt
					gxmessage -title "提示" -file /tmp/msg.txt -center
					exit 1
				fi

				# apt-get install -y git
				# exit_if_fail $? "解压工具unzip安装失败"

				DEB_PATH=./downloads/${SWNAME}.zip
				app_dir=/opt/apps/${SWNAME}

				swUrl=https://gitee.com/Neko-vecter/fluidd-releases/releases/download/v1.26.3/fluidd.zip
				download_file2 "${DEB_PATH}" "${swUrl}"
				exit_if_fail $? "下载失败，网址：${swUrl}"

				# download_file3 "${app_dir}" "${swUrl}"


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
				apt-get install -y unzip
				exit_if_fail $? "解压工具unzip安装失败"

				apt-get install -y nginx
				exit_if_fail $? "依赖工具安装失败"

				echo "正在解压. . ."
				unzip -oq ${DEB_PATH} -d ${app_dir}
				exit_if_fail $? "安装失败，软件包：${DEB_PATH}"

				# # fluidd 配置文件
				# rm -rf   ${app_dir}/fluidd-config
				# mkdir -p ${app_dir}/fluidd-config 2>/dev/null
			    # fluidd_cfg="https://gitee.com/Neko-vecter/fluidd-config.git"
				# git clone --recurse-submodules "${fluidd_cfg}" "${app_dir}/fluidd-config";
				# exit_if_fail $? "fluidd配置文件下载失败"
				# ln -sf ${app_dir}/fluidd-config/fluidd.cfg /mnt/printer_data/config/fluidd.cfg

				cp -f ${ZZSWMGR_MAIN_DIR}/scripts/res/fluidd_ex_config.cfg /mnt/printer_data/config/

				cat <<- EOF > /etc/nginx/sites-available/fluidd
					# /etc/nginx/sites-available/fluidd

					server {
						listen 9999;

						access_log /var/log/nginx/fluidd-access.log;
						error_log /var/log/nginx/fluidd-error.log;

						# disable this section on smaller hardware like a pi zero
						gzip on;
						gzip_vary on;
						gzip_proxied any;
						gzip_proxied expired no-cache no-store private auth;
						gzip_comp_level 4;
						gzip_buffers 16 8k;
						gzip_http_version 1.1;
						gzip_types text/plain text/css text/xml text/javascript application/javascript application/x-javascript application/json application/xml;

						# web_path from fluidd static files
						root /opt/apps/fluidd;

						index index.html;
						server_name _;

						# disable max upload size checks
						client_max_body_size 0;

						# disable proxy request buffering
						proxy_request_buffering off;

						location / {
							try_files \$uri \$uri/ /index.html;
						}

						location = /index.html {
							add_header Cache-Control "no-store, no-cache, must-revalidate";
						}

						location /websocket {
							proxy_pass http://apiserver/websocket;
							proxy_http_version 1.1;
							proxy_set_header Upgrade \$http_upgrade;
							proxy_set_header Connection \$connection_upgrade;
							proxy_set_header Host \$http_host;
							proxy_set_header X-Real-IP \$remote_addr;
							proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
							proxy_read_timeout 86400;
						}

						location ~ ^/(printer|api|access|machine|server)/ {
							proxy_pass http://apiserver\$request_uri;
							proxy_http_version 1.1;
							proxy_set_header Upgrade \$http_upgrade;
							proxy_set_header Host \$http_host;
							proxy_set_header X-Real-IP \$remote_addr;
							proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
							proxy_set_header X-Scheme \$scheme;
							proxy_read_timeout 600;
						}
					}
				EOF

				cat <<- EOF > /etc/nginx/conf.d/common_vars.conf
					# /etc/nginx/conf.d/common_vars.conf

					map \$http_upgrade \$connection_upgrade {
						default upgrade;
						'' close;
					}
				EOF

				cat <<- EOF > /etc/nginx/conf.d/upstreams.conf
					# /etc/nginx/conf.d/upstreams.conf
					upstream apiserver {
						ip_hash;
						server 127.0.0.1:7125;
					}

					#upstream mjpgstreamer1 {
					#    ip_hash;
					#    server 127.0.0.1:8080;
					#}
				EOF

				# 删除原来的文件链接，原来的配置文件里面端口号是80，会影响启动，因为在安卓proot环境下不能使用1024以下的端口号！
				rm -rf /etc/nginx/sites-enabled/default
				ln -s -f /etc/nginx/sites-available/fluidd /etc/nginx/sites-enabled/default

				# 生成 fluidd 专用的 moonraker.conf 和 printer.cfg
				cp /opt/apps/moonraker/moonraker.conf.base /mnt/printer_data/config/moonraker.conf
				cp /opt/apps/klipper/printer.cfg.base      /mnt/printer_data/config/printer.cfg

				chmod 666 /mnt/printer_data/config/moonraker.conf
				chmod 666 /mnt/printer_data/config/printer.cfg

				cat <<- EOF >> /mnt/printer_data/config/printer.cfg

					# fluidd 的扩展配置、宏
					# 来源：https://gitee.com/Neko-vecter/fluidd-config.git
					[include fluidd_ex_config.cfg]
				EOF
				cp -f /mnt/printer_data/config/printer.cfg /mnt/printer_data/config/printer.bak.fluidd

				tmpdata="

					# # 自动升级？
					# [update_manager]
					# channel: dev
					# refresh_interval: 168

					# [update_manager fluidd]
					# type: web
					# channel: stable
					# repo: fluidd-core/fluidd
					# path: ${app_dir}

				"
				echo "${tmpdata}" >> /mnt/printer_data/config/moonraker.conf
				exit_if_fail $? "配置文件创建失败！"

				STARTUP_SCRIPT_FILE=${app_dir}/fluidd
				cat <<- EOF > ${STARTUP_SCRIPT_FILE}
					#!/bin/bash
					APPNAME_WEB_CTRL=fluidd
					
					echo "正在向创建 \$APPNAME_WEB_CTRL 配置文件的链接到 /mnt/printer_data/config/printer.cfg, /mnt/printer_data/config/moonraker.conf"
					# sudo -A ln -sf /mnt/printer_data/config/prnt_${SWNAME}.conf /mnt/printer_data/config/printer.cfg
					# sudo -A ln -sf /mnt/printer_data/config/moon_${SWNAME}.conf /mnt/printer_data/config/moonraker.conf

					echo "正在启动moonraker, 请访问 http://本设备IP地址:7125/ "
					sudo -A moonraker 2>&1 >/dev/null &

					sudo -A pkill nginx
					sudo -A ln -f -s /etc/nginx/sites-available/\$APPNAME_WEB_CTRL /etc/nginx/sites-enabled/default
					sudo -A /usr/sbin/nginx -g 'daemon on; master_process on;'
				EOF
				chmod 755 ${STARTUP_SCRIPT_FILE}
				cp -f ${STARTUP_SCRIPT_FILE}  /usr/bin/

				## 以上配置完，并用 sudo -A /usr/sbin/nginx -g 'daemon on; master_process on;' 启动nginx后
				## 访问这个地址 http://192.168.1.13:9999/server/info ，应该能获取获取到moonraker的信息！
				## 如果访问不到，则是nginx的反向代理配置得有问题



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



