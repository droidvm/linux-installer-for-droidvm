#!/bin/bash

SWNAME=cura
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

	cat <<- EOF > ${DSK_PATH}
[Desktop Entry]
Name=Cura带图形加速
Comment=以virgl加速方式启动，如不能启动，请使用原版图标启动
Exec=/usr/bin/cura3d %F
TryExec=/usr/bin/cura3d
Icon=cura-icon
Terminal=false
Type=Application
MimeType=model/stl;application/vnd.ms-3mfdocument;application/prs.wavefront-obj;image/bmp;image/gif;image/jpeg;image/png;text/x-gcode;application/x-amf;application/x-ply;application/x-ctm;model/vnd.collada+xml;model/gltf-binary;model/gltf+json;model/vnd.collada+xml+zip;
Categories=Graphics;Education;Development;Science;
Keywords=3D;Printing;Slicer;
StartupWMClass=cura.real
	EOF

	sudo cat <<- EOF > /usr/bin/cura3d
		#!/bin/bash
		export GALLIUM_DRIVER=virpipe
		export MESA_GL_VERSION_OVERRIDE=4.0
		exec /usr/bin/cura \$@
	EOF
	chmod 755 /usr/bin/cura3d

	gxmessage -title "提示" "安装已完成，请查看桌面上的 软件 文件夹"  -center
fi
