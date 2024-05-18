#!/bin/bash

SWNAME=rp2

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh


if [ "${action}" == "卸载" ]; then
	sudo apt-get install --fix-missing -y
else
	sudo apt-get install --fix-missing -y
fi

