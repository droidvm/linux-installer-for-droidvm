#!/bin/bash

SWNAME=ark

action=$1
if [ "$action" == "" ]; then action=安装; fi

if [ "${action}" == "卸载" ]; then
	sudo apt-get remove -y ${SWNAME}
else
	sudo apt-get install -y ${SWNAME}
fi
