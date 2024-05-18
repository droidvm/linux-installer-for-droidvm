#!/bin/bash

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
    ln -sf /usr/bin/l3afpad /usr/bin/notepad
fi

ln -sf /usr/bin/lxterminal /usr/bin/cmd
