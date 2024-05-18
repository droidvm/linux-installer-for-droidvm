#!/bin/bash

gxmessage -title "询问" "想安装哪个版本的wine？"  -center -buttons "8.9:2,7.0.1:1,取消:0"
confirm=$?

case "${confirm}" in
    "2")
		${tools_dir}/misc/helper/setup_wine_8.9.0_from_Kron4ek.sh
        ;;
    "1")
		${tools_dir}/misc/helper/setup_wine_7.0.1_from_winehq_____deprecated.sh
        ;;
    *)
		exit 0
        ;;
esac
