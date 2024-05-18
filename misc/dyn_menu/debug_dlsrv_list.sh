#!/bin/bash

echo "<JWM>"

if [ $SCRIPT_DEBUG -eq 1 ]; then
	cat <<- EOF
		<Program label="设置为虚拟电脑官方网站(带宽小，不稳定)" >/exbin/tools/vm_set_app_dlserver.sh pubweb</Program>
		<Program label="设置为本地调试服务器(仅用于调试，勿选)" >/exbin/tools/vm_set_app_dlserver.sh local</Program>
	EOF
fi

echo "</JWM>"
