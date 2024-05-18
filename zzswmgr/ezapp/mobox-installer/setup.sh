#!/bin/bash

: '
cd Z:\usr\glibc\opt\apps\
   Z:\usr\glibc\opt\apps\install.bat

cd Z:\usr\glibc\opt\prefix\d3d\
   Z:\usr\glibc\opt\prefix\d3d\wined3d-8.20.bat

cd Z:\usr\glibc\opt\prefix\mesa\
   Z:\usr\glibc\opt\prefix\mesa\virgl-mesa-24.bat

D:
cd \
CubeMap.exe

'

# export DIR_SCRIPT=`dirname $0`
# export DIR_SCRIPT=`dirname $0` # 这个不准确
export DIR_SCRIPT=$(dirname $(realpath $0))


# wine开始菜单项依赖此路径，请不要改动！
export PREFIX=/data/data/com.termux/files/usr
export INSTALL_WOW64=1


echo "正在安装mobox的工具"
pkg update
pkg install -y x11-repo
pkg install -y wget  openssl  hashdeep  ncurses-utils  tsu  dialog  patchelf  xorg-xmessage

echo "Updating package manager"
mkdir -p $PREFIX/glibc/opt/package-manager/installed 2>/dev/null
function wget-git-q {
    wget -q --retry-connrefused --tries=0 --header "PRIVATE-TOKEN: $PRIVATE_TOKEN" "https://gitlab.com/api/v4/projects/$PROJECT_ID/repository/files/$1/raw?ref=main" -O $2
    return $?
}

if [ "$INSTALL_WOW64" = "1" ]; then
echo "PRIVATE_TOKEN=glpat-h5r7HjKoPKZPxmfg79xs
PROJECT_ID=54240888">$PREFIX/glibc/opt/package-manager/token
else
echo "PRIVATE_TOKEN=glpat-Xs4HfrCkMpbedkPycqzP
PROJECT_ID=52465323">$PREFIX/glibc/opt/package-manager/token
fi

# 安装package-manager
. $PREFIX/glibc/opt/package-manager/token
PATH_MOBOX_PKGMGR=$PREFIX/glibc/opt/package-manager/package-manager
# [ -f ${PATH_MOBOX_PKGMGR} ] || wget-git-q "package-manager" ${PATH_MOBOX_PKGMGR}
wget-git-q "package-manager" ${PATH_MOBOX_PKGMGR}
ls -al ${PATH_MOBOX_PKGMGR}
. ${PATH_MOBOX_PKGMGR}

# 安装基础软件包
sync-all

# 安装wine
if [ "$INSTALL_WOW64" = "1" ]; then
  sync-package wine-9.1-vanilla-wow64
else
  sync-package wine-ge-custom-8-25
fi

# 创建/usr/bin/mobox
# ln -sf $PREFIX/glibc/opt/scripts/mobox $PREFIX/bin/mobox
cat <<- EOF > $PREFIX/bin/mobox
	#!/bin/bash
	# \${PREFIX}/glibc/opt/scripts/start-wine.sh
	echo "要设置mobox，请输入 \"mbcfg\""
  chmod a+x \${HOME}/mobox-installer/*.sh
	\${HOME}/mobox-installer/start-wine.sh
EOF
chmod a+x $PREFIX/bin/mobox

cat <<- EOF > $PREFIX/bin/mbcfg
	#!/bin/bash
	\${PREFIX}/glibc/opt/scripts/mobox
EOF
chmod a+x $PREFIX/bin/mbcfg

echo "安装完成。"
echo "要启动mobox，请输入 \"mobox\""
echo "要设置mobox，请输入 \"mbcfg\""
