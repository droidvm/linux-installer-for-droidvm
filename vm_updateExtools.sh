#!/bin/bash

rm -rf ${tools_dir}/ndkpulseaudio
rlt=$?

if [ $rlt -eq 0 ]; then
	cat <<- EOF > /tmp/msg.txt

	已标记重新下载ex_ndk_tools.zip
	下次打开app时生效。

	EOF

    cat ${APP_FILENAME_URLTOOLS} >> /tmp/msg.txt
else
	cat <<- EOF > /tmp/msg.txt

	设置失败

	EOF
fi

gxmessage -title "启动脚本" -file /tmp/msg.txt -center
