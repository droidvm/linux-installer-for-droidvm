#!/bin/bash

VM_COLORSCH=`cat ${PATH_VmColorscheme} 2>/dev/null`

if [ "${VM_COLORSCH}" == "" ]; then
	VM_COLORSCH="light"
fi

if [ "${VM_COLORSCH}" == "light" ]; then
	cat /etc/droidvm/def_xconf/common/jwm.theme/light.jwmrc
else
	cat /etc/droidvm/def_xconf/common/jwm.theme/dark.jwmrc
fi
