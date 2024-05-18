#!/bin/bash
sharetype=$1
what2share=$2
target_pkgname="com.tencent.mm"
target_activitypath="com.tencent.mm.ui.tools.ShareImgUI"
gui_title="分享到其它应用"

# 去掉路径头尾的单引号
what2share=${what2share:1:-1}

# echo "分享类型：${sharetype}"   > /tmp/msg.txt
# echo "分享内容：${what2share}"  >>/tmp/msg.txt
# gxmessage -title "${gui_title}" -file /tmp/msg.txt -center

if [ "${sharetype}" != "text" ] && [ "${sharetype}" != "file" ]; then
    echo "仅支持两种分享类型: text, file"
    gxmessage -title "${gui_title}" $'仅支持两种分享类型: \ntext(信息)\nfile(文件)\n' -center
fi

if [ "${sharetype}" == "file" ]; then
    if [ ! -f "${what2share}" ]; then
        tmpmsg="文件不存在 ${what2share}"
        echo "${tmpmsg}"
        gxmessage -title "${gui_title}" "${tmpmsg}" -center
        exit 1
    fi

    echo "正在转成android路径"
    what2share="${APP_INTERNAL_DIR}/vm/${CURRENT_OS_NAME}${what2share}"
    echo "${what2share}"

    echo "正在把路径中的空格全部替换成 '|'"
    # what2share="test test1 test2 test3"
    what2share=${what2share// /|}
    echo "${what2share}"
fi

echo "#vmshare ${sharetype} ${what2share} ${target_pkgname} ${target_activitypath}" > "${NOTIFY_PIPE}"
