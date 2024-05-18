#!/bin/bash

SWNAME=libreoffice

action=$1
if [ "$action" == "" ]; then action=安装; fi

if [ "${action}" == "卸载" ]; then
	sudo apt-get remove -y ${SWNAME}
else
	sudo apt-get install -y ${SWNAME} libreoffice-l10n-zh-cn  libreoffice-help-zh-cn
fi
