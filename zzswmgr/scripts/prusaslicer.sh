#!/bin/bash

SWNAME=prusaslicer
DIR_DESKTOP_FILES=/usr/share/applications
DSK_FILE=${SWNAME}.desktop
DSK_PATH=${DIR_DESKTOP_FILES}/${DSK_FILE}


action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh


if [ "${action}" == "卸载" ]; then
	sudo apt-get remove -y prusa-slicer
else
	sudo apt-get install -y prusa-slicer
	exit_if_fail $? "安装失败"

	cat <<- EOF > ${DSK_PATH}
[Desktop Entry]
Name=Prusa带图形加速
GenericName=Prusa带图形加速
Icon=PrusaSlicer
Exec=prusaslicer %F
Terminal=false
Type=Application
MimeType=model/stl;application/vnd.ms-3mfdocument;application/prs.wavefront-obj;application/x-amf;
Categories=Graphics;3DGraphics;Engineering;
Keywords=3D;Printing;Slicer;slice;3D;printer;convert;gcode;stl;obj;amf;SLA
StartupNotify=false
StartupWMClass=prusa-slicer
	EOF

	sudo cat <<- EOF > /usr/bin/prusaslicer
		#!/bin/bash
		export GALLIUM_DRIVER=virpipe
		export MESA_GL_VERSION_OVERRIDE=4.0
		exec /usr/bin/prusa-slicer \$@
	EOF
	chmod 755 /usr/bin/prusaslicer

	gxmessage -title "提示" "安装已完成，请查看桌面上的 软件 文件夹"  -center
fi
