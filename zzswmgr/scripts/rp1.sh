#!/bin/bash

SWNAME=rp1

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh

if [ "${action}" == "卸载" ]; then
	dpkg --configure -a
else
	dpkg --configure -a
fi
