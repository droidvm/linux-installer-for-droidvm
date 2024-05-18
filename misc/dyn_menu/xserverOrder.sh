#!/bin/bash

echo "<JWM>"

IS_XVFB=" "
IS_XLOR=" "

if [ "$XSRV_NAME" != "xlorie" ]; then
	cat <<- EOF
		<Menu label="桌面截图">
			<Program label="截图　　　　　　　　　　　　">/exbin/tools/vm_screencapture.sh</Program>
		</Menu>
	EOF
	IS_XVFB="　当前使用"
else
	IS_XLOR="　当前使用"
fi

# if [ $SCRIPT_DEBUG -eq 1 ]; then
	cat <<- EOF
		<Menu label="XServer管理">
			<Program label="优先使用xlorie(效率高，兼容差，重启生效)${IS_XLOR}"	>/exbin/tools/vm_config_set_XSrvOrder.sh "xlorie Xvfb"</Program>
			<Program label="优先使用Xvfb(兼容好，效率低，重启生效)${IS_XVFB}"	>/exbin/tools/vm_config_set_XSrvOrder.sh "Xvfb xlorie"</Program>
		</Menu>
	EOF
# fi

echo "</JWM>"
