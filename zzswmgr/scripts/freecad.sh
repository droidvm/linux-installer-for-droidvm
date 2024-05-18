#!/bin/bash

SWNAME=freecad
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
Name=cad带图形加速
Name[de]=FreeCAD
Name[pl]=FreeCAD
Name[ru]=FreeCAD
Comment=以virgl加速方式启动，如不能启动，请使用原版图标启动
Comment[de]=Feature-basierter parametrischer Modellierer
Comment[ru]=Система автоматизированного проектирования
GenericName=CAD Application
GenericName[de]=CAD-Anwendung
GenericName[pl]=Aplikacja CAD
GenericName[ru]=Система автоматизированного проектирования
Exec=/usr/bin/freecad3d %F
Terminal=false
Type=Application
Icon=org.freecadweb.FreeCAD
Categories=Graphics;Science;Education;Engineering;
StartupNotify=true
MimeType=application/x-extension-fcstd;model/obj;model/iges;image/vnd.dwg;image/vnd.dxf;model/vnd.collada+xml;application/iges;model/iges;model/step;model/step+zip;model/stl;application/vnd.shp;model/vrml;
	EOF

	sudo cat <<- EOF > /usr/bin/freecad3d
		#!/bin/bash
		export GALLIUM_DRIVER=virpipe
		export MESA_GL_VERSION_OVERRIDE=4.0
		exec /usr/bin/freecad - --single-instance \$@
	EOF
	chmod 755 /usr/bin/freecad3d

	gxmessage -title "提示" "安装已完成，请查看桌面上的 软件 文件夹"  -center
fi
