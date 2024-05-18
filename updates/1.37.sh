#!/bin/bash

source ${tools_dir}/vm_config.sh

# ln -sf /usr/bin/lxterminal /usr/bin/cmd
# ln -sf /usr/bin/python3    /usr/bin/python

(cd /usr/bin && ln -sf lxterminal  cmd)
(cd /usr/bin && ln -sf python3     python)


swname=xclip
which ${swname} >/dev/null 2>&1
if [ $? -ne 0 ]; then
	echo ""
	echo "正在补装软件: ${swname}"
	apt-get install -y ${swname}
fi

swname=l3afpad
which ${swname} >/dev/null 2>&1
if [ $? -ne 0 ]; then
	echo ""
	echo "正在补装软件: ${swname}"
	apt-get install -y ${swname}
    # ln -sf /usr/bin/l3afpad /usr/bin/notepad
	(cd /usr/bin && ln -sf l3afpad  notepad)
fi
sed -i "s|L3afpad|notepad|" /usr/share/applications/l3afpad.desktop

swname=lxtask
which ${swname} >/dev/null 2>&1
if [ $? -ne 0 ]; then
	echo ""
	echo "正在补装软件: ${swname}"
	apt-get install -y ${swname}
fi



echo ""
echo "正在更新开始菜单"
cp -f ${tools_dir}/misc/def_xconf/common/menu.jwmrc   ${DirBakConf}/common/menu.jwmrc

mv -f $0 $0.bak
