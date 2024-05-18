#!/bin/bash

SWNAME=adb

action=$1
if [ "$action" == "" ]; then action=安装; fi

# pwd
. ./scripts/common.sh

if [ "${action}" == "卸载" ]; then
	sudo apt-get remove -y ${SWNAME}
else
	sudo apt-get install -y --no-install-recommends ${SWNAME}
  exit_if_fail $? "${SWNAME} 安装失败"

	cp -rf ./ezapp/adbutils/adbme.sh  /usr/bin/adbme
	exit_if_fail $? "安装失败，无法复制文件到 /usr/bin/adbme"

	cp -rf ./ezapp/adbutils/opadb.sh  /usr/bin/opadb
	exit_if_fail $? "安装失败，无法复制文件到 /usr/bin/opadb"

  chmod 755 /usr/bin/adbme
  chmod 755 /usr/bin/opadb

  echo "正在生成桌面文件"
  tmpfile=${DIR_DESKTOP_FILES}/adbme.desktop
  echo "[Desktop Entry]"    > ${tmpfile}
  echo "Encoding=UTF-8"			>>${tmpfile}
  echo "Version=0.9.4"			>>${tmpfile}
  echo "Type=Application"   >>${tmpfile}
  echo "Terminal=true"      >>${tmpfile}
  echo "Name=ADBme"         >>${tmpfile}
  echo "Exec=adbme"         >> ${tmpfile}
  echo "Comment=adb自连 通过tcp-adb通道连接设备自身">> ${tmpfile}
  cp2desktop ${tmpfile}

  echo "正在生成桌面文件"
  tmpfile=${DIR_DESKTOP_FILES}/opadb.desktop
  echo "[Desktop Entry]"    > ${tmpfile}
  echo "Encoding=UTF-8"			>>${tmpfile}
  echo "Version=0.9.4"			>>${tmpfile}
  echo "Type=Application"   >>${tmpfile}
  echo "Terminal=true"      >>${tmpfile}
  echo "Name=开adb"         >>${tmpfile}
  echo "Exec=opadb"         >> ${tmpfile}
  echo "Comment=为通过USB线连入的手机/平板打开tcp-adb通道">> ${tmpfile}
  cp2desktop ${tmpfile}


  gxmessage -title "提示" "${SWNAME} 安装完成"  -center
fi
