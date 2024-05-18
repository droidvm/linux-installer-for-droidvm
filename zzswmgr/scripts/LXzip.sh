#!/bin/bash

SWNAME=lxzip

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
	# 	Icon=lxqt-archiver
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
	# 	exec lxqt-archiver \$@
	# EOF
	# exit_if_fail $? "启动脚本生成失败"
	# chmod 755 ${tmpfile}


	tmpfile=${DIR_DESKTOP_FILES}/${SWNAME}.desktop
	mv -f ${DIR_DESKTOP_FILES}/lxqt-archiver.desktop  ${tmpfile}
	sed -i 's#Name=LXQt File Archiver#Name=LXzip#g'   ${tmpfile}
	cp2desktop ${tmpfile}

	cd /usr/bin && ln -sf lxqt-archiver lxzip

	update-desktop-database /usr/share/applications/

	gxmessage -title "提示"     $'\n安装完成，请刷新桌面\n\n'  -center
}


if [ "${action}" == "卸载" ]; then
	apt-get remove  -y lxqt-archiver
else
	echo "和libfm冲突，无中文界面，放弃！"
	exit 5

	apt-mark hold libfm4
	apt-get install -y lxqt-archiver lxqt-archiver-l10n unzip xz-utils zip unrar cpio
	# sudo apt-get -o APT::Install-Suggests="true" install -y lxqt-archiver
	sw_create_desktop_file
fi

: '

查看文件的mimetype:
==============================================
file --mime-type 74703.tar.gz


查看文件的关联程序:
==============================================
gio mime application/gzip


更新文件的关联程序(可能需要重启桌面环境):
==============================================
update-mime-database    /usr/share/mime
update-desktop-database /usr/share/applications/

/usr/share/lxqt-archiver/translations 中没有简体中文语言包:
https://translate.lxqt-project.org/projects/lxqt-desktop/lxqt-archiver/zh_CN/

linguist_releases	https://mirrors.tuna.tsinghua.edu.cn/qt/
lconvert
msg2qm

github仓库上的源码，是包含了的！
https://github.com/lxqt/lxqt-archiver


'
