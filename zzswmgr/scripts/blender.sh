#!/bin/bash

SWNAME=blender
DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}


action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh


if [ "${action}" == "卸载" ]; then
	sudo apt-get remove -y ${SWNAME}
else
	sudo apt-get install -y ${SWNAME}
	exit_if_fail $? "安装失败"

	cat <<- EOF > ${DIR_DESKTOP_FILES}/${SWNAME}-3d.desktop
[Desktop Entry]
Name=blender带图形加速
Comment=以virgl加速方式启动，如不能启动，请使用原版图标启动
Exec=/usr/bin/blender3d %F
TryExec=/usr/bin/blender3d
Icon=blender
Terminal=false
Type=Application
Keywords=3d;cg;modeling;animation;painting;sculpting;texturing;video editing;video tracking;rendering;render engine;cycles;game engine;python;
MimeType=application/x-blender;
Categories=Graphics;3DGraphics;
Keywords=3D;Printing;Slicer;
	EOF

	sudo cat <<- EOF > /usr/bin/blender3d
		#!/bin/bash
		export GALLIUM_DRIVER=virpipe
		export MESA_GL_VERSION_OVERRIDE=4.0
		exec /usr/bin/blender \$@
	EOF
	chmod 755 /usr/bin/blender3d

	gxmessage -title "提示" "安装已完成，请查看桌面上的 软件 文件夹"  -center
fi
