#!/bin/bash

SWNAME=zip

action=$1
if [ "$action" == "" ]; then action=安装; fi

if [ "${action}" == "卸载" ]; then
	sudo apt-get remove  -y zip unzip
else
	sudo apt-get install -y zip unzip
fi
