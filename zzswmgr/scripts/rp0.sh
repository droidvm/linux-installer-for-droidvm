#!/bin/bash

SWNAME=rp0

action=$1
if [ "$action" == "" ]; then action=安装; fi

. ./scripts/common.sh

if [ "${action}" == "卸载" ]; then
	apt update
else
	apt update
fi
