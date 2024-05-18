#!/bin/bash

SWNAME=nginx
DEF_PORT=8888

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh

function sw_download() {
	# # https://bbs.deepin.org/zh/post/205101
	# case "${CURRENT_VM_ARCH}" in
	# 	"arm64") swUrl=http://archive.kylinos.cn/kylin/partner/pool/com.xunlei.download_1.0.0.1_arm64.deb ;;
	# 	"amd64") swUrl=http://archive.kylinos.cn/kylin/partner/pool/com.xunlei.download_1.0.0.1_amd64.deb ;;
	# 	*) exit_unsupport ;;
	# esac

	# download_file2 "${DEB_PATH}" "${swUrl}"
	# exit_if_fail $? "下载失败，网址：${swUrl}"
	echo ""
}

function sw_install() {
	apt-get install -y nginx php-fpm redis php-redis
	exit_if_fail $? "安装失败，软件包：${SWNAME}"
}

function sw_create_desktop_file() {
	DIR_DESKTOP_FILES=/usr/share/applications
	DSK_FILE=${SWNAME}.desktop
	DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}

	DIR_PATH=/opt/apps/${SWNAME}
	[ -d ${DIR_PATH} ] || mkdir -p ${DIR_PATH} 2>&1 >/dev/null

	PHP_VER=8.1
    PHP_VER_8_2_FOUND=`ls -al /usr/sbin|grep php-fpm8.2`
    echo $PHP_VER_8_2_FOUND
    if [ "${PHP_VER_8_2_FOUND}" != "" ]; then
        PHP_VER=8.2
    fi


	# 启动、停止脚本
	FILEPATH=${DIR_PATH}/start
	cat <<- EOF > ${FILEPATH}
	#!/bin/bash

	echo ""
	echo -e "请输入当前用户的密码, \\e[96m默认密码：droidvm\\e[0m"
	sudo echo ""

	WEB_PORT=8888
	/exbin/tools/busybox ifconfig 2>/dev/null|grep '192'| \\
	awk '{print \$2}'|awk -v FS=":" -v OFS="" -v header="http://" -v tail=":\${WEB_PORT}" '{print header,\$2,tail}' \\
	>/tmp/ip.txt

	# 启动redis
	/usr/bin/redis-server /etc/redis/redis.conf --supervised systemd --daemonize no &

	# 启动php-fpm
	# cat /lib/systemd/system/php8.1-fpm.service
	sudo /usr/sbin/php-fpm${PHP_VER} --nodaemonize --fpm-config /etc/php/${PHP_VER}/fpm/php-fpm.conf &

	# 启动nginx
	/usr/sbin/nginx -t -q -g 'daemon on; master_process on;'
	config_file_checkrlt=\$?
	if [ \$config_file_checkrlt -eq 0 ]; then
		sudo /usr/sbin/nginx -g 'daemon on; master_process on;'
	else
		echo "nginx 配置文件有错误(/etc/nginx/sites-available/default)";
		read -s -n1 -p "按任意键退出"
		exit \$config_file_checkrlt
	fi

	pids_nginx=\`pidof nginx\`
	pids_phpfpm=\`pidof /usr/sbin/php-fpm${PHP_VER}\`
	if [ "\${pids_nginx}" != "" ] && [ "\${pids_phpfpm}" != "" ]; then

		echo ""
		echo ""
		echo "网站目录: /var/www/html"
		echo ""
		echo -e "nginx已启动, \\e[96m请在电脑端或手机上访问："
		tmpaddrs=\`cat /tmp/ip.txt\`
		if [ "\${tmpaddrs}" != "" ]; then
			echo \${tmpaddrs}
		else
			echo "http://本设备IP:\${WEB_PORT}"
		fi
		echo -e "\\e[0m"
		echo ""
		echo "如需将网站发布到公网"
		echo "可考虑购买云服务器"
		echo "或者使用内网穿透工具："
		echo "便宜、提供域名：https://natapp.cn/"
		echo "免费、要买域名：https://freefrp.net/"

		echo -e "按任意键关闭此黑窗（不影响 nginx 运行）\\n\\n"
		read -s -n1 

		# gxmessage -title "提示" "已启动, 试试访问 http://127.0.0.1:8888/"  -center
	else
		gxmessage -title "提示" "启动失败，权限不够！请尝试在命令行下启动: sudo $FILEPATH"  -center
	fi

	EOF
	chmod 755 ${FILEPATH}
	SCRIPT_PATH_START=${FILEPATH}



	FILEPATH=${DIR_PATH}/stop
	cat <<- EOF > ${FILEPATH}
	#!/bin/bash

	# 停止php-fpm[实测失败]
	# # cat /lib/systemd/system/php8.1-fpm.service
	# # pid=`pidof php-fpm8.1`
	# pid=$(ps aux|grep "php-fpm${PHP_VER}"|grep -v grep|awk '{print $2}')
	# sudo kill -USR2 $pid
	pkill php-fpm
	/sbin/start-stop-daemon --quiet --stop --retry QUIT/5 --pidfile /var/run/php/php${PHP_VER}-fpm.pid

	# 停止nginx
	/sbin/start-stop-daemon --quiet --stop --retry QUIT/5 --pidfile /run/nginx.pid

	# 停止 redis
	pkill redis-server
	# pid=`pidof redis-server`
	# kill $pid

	gxmessage -title "提示" "已停止"  -center

	EOF
	chmod 755 ${FILEPATH}
	SCRIPT_PATH_STOP=${FILEPATH}

	# 启动、停止 desktop-file
	tmpfile=${DIR_DESKTOP_FILES}/${SWNAME}_start.desktop
	cat <<- EOF > ${tmpfile}
	[Desktop Entry]
	Name=启动nginx
	Exec=${SCRIPT_PATH_START}
	Type=Application
	Terminal=true
	EOF
	cp2desktop ${tmpfile}

	tmpfile=${DIR_DESKTOP_FILES}/${SWNAME}_stop.desktop
	cat <<- EOF > ${tmpfile}
	[Desktop Entry]
	Name=停止nginx
	Exec=${SCRIPT_PATH_STOP}
	Type=Application
	Terminal=true
	EOF
	cp2desktop ${tmpfile}

	# nginx 配置文件
	cp -f /etc/nginx/sites-available/default /etc/nginx/sites-available/default.ori.bak
	cat <<- EOF > /etc/nginx/sites-available/default
	##
	# You should look at the following URL's in order to grasp a solid understanding
	# of Nginx configuration files in order to fully unleash the power of Nginx.
	# https://www.nginx.com/resources/wiki/start/
	# https://www.nginx.com/resources/wiki/start/topics/tutorials/config_pitfalls/
	# https://wiki.debian.org/Nginx/DirectoryStructure
	#
	# In most cases, administrators will remove this file from sites-enabled/ and
	# leave it as reference inside of sites-available where it will continue to be
	# updated by the nginx packaging team.
	#
	# This file will automatically load configuration files provided by other
	# applications, such as Drupal or Wordpress. These applications will be made
	# available underneath a path with that package name, such as /drupal8.
	#
	# Please see /usr/share/doc/nginx-doc/examples/ for more detailed examples.
	##

	# Default server configuration
	#
	server {
			listen $DEF_PORT default_server;
			listen [::]:$DEF_PORT default_server;

			# SSL configuration
			#
			# listen 443 ssl default_server;
			# listen [::]:443 ssl default_server;
			#
			# Note: You should disable gzip for SSL traffic.
			# See: https://bugs.debian.org/773332
			#
			# Read up on ssl_ciphers to ensure a secure configuration.
			# See: https://bugs.debian.org/765782
			#
			# Self signed certs generated by the ssl-cert package
			# Don't use them in a production server!
			#
			# include snippets/snakeoil.conf;

			root /var/www/html;

			# Add index.php to the list if you are using PHP
			index index.html index.htm index.php;

			server_name _;

			location / {
					# First attempt to serve request as file, then
					# as directory, then fall back to displaying a 404.
					try_files \$uri \$uri/ =404;
			}

			# pass PHP scripts to FastCGI server
			#
			location ~ \.php\$ {
				include snippets/fastcgi-php.conf;
			
				# With php-fpm (or other unix sockets):
				fastcgi_pass unix:/var/run/php/php${PHP_VER}-fpm.sock;
				# With php-cgi (or other tcp sockets):
				# fastcgi_pass 127.0.0.1:9000;

				include fastcgi_params;
			}

			# deny access to .htaccess files, if Apache's document root
			# concurs with nginx's one
			#
			#location ~ /\.ht {
			#       deny all;
			#}
	}


	# Virtual Host configuration for example.com
	#
	# You can move that to a different file under sites-available/ and symlink that
	# to sites-enabled/ to enable it.
	#
	#server {
	#       listen $DEF_PORT;
	#       listen [::]:$DEF_PORT;
	#
	#       server_name example.com;
	#
	#       root /var/www/example.com;
	#       index index.html;
	#
	#       location / {
	#               try_files \$uri \$uri/ =404;
	#       }
	#}
	EOF

	# nginx fastcgi 配置文件，用来找到php进程的
	cp -f /etc/nginx/fastcgi_params /etc/nginx/fastcgi_params.ori.bak
	cat <<- EOF > /etc/nginx/fastcgi_params
	fastcgi_param  QUERY_STRING       \$query_string;
	fastcgi_param  REQUEST_METHOD     \$request_method;
	fastcgi_param  CONTENT_TYPE       \$content_type;
	fastcgi_param  CONTENT_LENGTH     \$content_length;

	fastcgi_param  SCRIPT_NAME        \$fastcgi_script_name;
	fastcgi_param  REQUEST_URI        \$request_uri;
	fastcgi_param  DOCUMENT_URI       \$document_uri;
	fastcgi_param  DOCUMENT_ROOT      \$document_root;
	fastcgi_param  SERVER_PROTOCOL    \$server_protocol;
	fastcgi_param  REQUEST_SCHEME     \$scheme;
	fastcgi_param  HTTPS              \$https if_not_empty;

	fastcgi_param  GATEWAY_INTERFACE  CGI/1.1;
	fastcgi_param  SERVER_SOFTWARE    nginx/\$nginx_version;

	fastcgi_param  REMOTE_ADDR        \$remote_addr;
	fastcgi_param  REMOTE_PORT        \$remote_port;
	fastcgi_param  SERVER_ADDR        \$server_addr;
	fastcgi_param  SERVER_PORT        \$server_port;
	fastcgi_param  SERVER_NAME        \$server_name;

	# PHP only, required if PHP was built with --enable-force-cgi-redirect
	fastcgi_param  REDIRECT_STATUS    200;
		
	fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
	fastcgi_param PATH_INFO                \$fastcgi_script_name;
	EOF

	# redis 配置文件
	echo "ignore-warnings ARM64-COW-BUG">>/etc/redis/redis.conf


	echo "nginx默认站点目录："
	echo "====================================================="
	echo "/var/www/html";

	echo "nginx 已经启动，以下是php信息：<br><?php phpinfo(); ?>">/var/www/html/index.php

	echo "图形环境下启动停止nginx："
	echo "====================================================="
	echo "进入桌面上的 \"软件\" 目录，双击 \"启动nginx\"、\"停止nginx\" 图标 "

	echo "控制台下启动停止nginx："
	echo "====================================================="
	echo "/opt/apps/nginx/start"
	echo "/opt/apps/nginx/stop"


	echo "安装完成!"
	echo "默认端口:$DEF_PORT"
	echo "默认目录:/var/www/html"
	echo "启动步骤:桌面 -> 软件 -> 启动nginx"
}

if [ "${action}" == "卸载" ]; then
	echo "暂不支持卸载"
	exit 1
else

	sw_download
	sw_install

	sw_create_desktop_file

	gxmessage -title "提示"     $'安装完成\n默认端口:'"$DEF_PORT"$'\n默认目录:/var/www/html\n启动步骤:桌面 -> 软件 -> 启动nginx\n\n'  -center        # 一定要是单引号

fi
