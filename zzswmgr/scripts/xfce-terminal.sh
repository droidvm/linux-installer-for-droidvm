#!/bin/bash

SWNAME=xfce4-terminal

DIR_DESKTOP_FILES=/usr/share/applications

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh


function sw_create_desktop_file() {
	echo "正在生成桌面文件"

	# tmpfile=${DIR_DESKTOP_FILES}/${SWNAME}.desktop
	# cat <<- EOF > ${tmpfile}
	# 	[Desktop Entry]
	# 	Name=LXzip
	# 	GenericName=LXzip
	# 	Exec=${SWNAME} %U
	# 	Terminal=false
	# 	Type=Application
	# 	Icon=engrampa
	# 	Categories=Qt;Utility;Archiving;Compression;
	# 	MimeType=application/x-7z-compressed;application/x-7z-compressed-tar;application/x-ace;application/x-alz;application/x-ar;application/x-arj;application/x-bzip;application/x-bzip-compressed-tar;application/x-bzip1;application/x-bzip1-compressed-tar;application/x-cabinet;application/x-cbr;application/x-cbz;application/x-cd-image;application/x-compress;application/x-compressed-tar;application/x-cpio;application/x-deb;application/vnd.debian.binary-package;application/x-ear;application/x-ms-dos-executable;application/x-gtar;application/gzip;application/x-gzpostscript;application/x-java-archive;application/x-lha;application/x-lhz;application/x-lrzip;application/x-lrzip-compressed-tar;application/x-lzip;application/x-lzip-compressed-tar;application/x-lzma;application/x-lzma-compressed-tar;application/x-lzop;application/x-lzop-compressed-tar;application/x-ms-wim;application/x-rar;application/x-rar-compressed;application/x-raw-disk-image;application/x-rpm;application/x-rzip;application/x-tar;application/x-tarz;application/x-stuffit;application/x-war;application/x-xz;application/x-xz-compressed-tar;application/zstd;application/x-zstd-compressed-tar;application/x-zip;application/x-zip-compressed;application/x-zoo;application/zip;application/x-archive;application/vnd.ms-cab-compressed;
	# 	Keywords=archive;manager;compression;
	# EOF
	# cp2desktop ${tmpfile}


	# echo "正在生成启动脚本"
	# # mv -f /usr/bin/${SWNAME} /usr/bin/${SWNAME}.bak
	# tmpfile=/usr/bin/${SWNAME}
	# cat <<- EOF > ${tmpfile}
	# 	#!/bin/bash
	# 	exec engrampa \$@
	# EOF
	# exit_if_fail $? "启动脚本生成失败"
	# chmod 755 ${tmpfile}


	# tmpfile=${DIR_DESKTOP_FILES}/engrampa.desktop
	# sed -i 's#Name\[zh_CN\]=Engrampa 归档管理器#Name\[zh_CN\]=EGzip#g'		${tmpfile}
	# sed -i 's#GenericName\[zh_CN\]=归档管理器#GenericName\[zh_CN\]=EGzip#g'	${tmpfile}
	# cp2desktop ${tmpfile}

	# cd /usr/bin && ln -sf engrampa egzip

	# cp -f /usr/share/icons/elementary-xfce/apps/16/engrampa.png /usr/share/icons/hicolor/16x16/apps/engrampa.png
	# cp -f /usr/share/icons/elementary-xfce/apps/22/engrampa.png /usr/share/icons/hicolor/22x22/apps/engrampa.png
	# cp -f /usr/share/icons/elementary-xfce/apps/24/engrampa.png /usr/share/icons/hicolor/24x24/apps/engrampa.png
	# cp -f /usr/share/icons/elementary-xfce/apps/32/engrampa.png /usr/share/icons/hicolor/32x32/apps/engrampa.png

	# update-icon-caches /usr/share/icons
	# update-desktop-database /usr/share/applications/

	tmpfile=${DIR_DESKTOP_FILES}/xfce4-terminal.desktop
	cp2desktop ${tmpfile}

	gxmessage -title "提示"     $'\n安装完成\n\n'  -center
}


if [ "${action}" == "卸载" ]; then
	apt-get remove  -y xfce4-terminal
	exit_if_fail $? "卸载失败"
else
	apt-get install -y xfce4-terminal
	exit_if_fail $? "安装失败"
	sw_create_desktop_file
fi
