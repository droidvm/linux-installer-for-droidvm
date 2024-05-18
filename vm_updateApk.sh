#!/bin/bash
: '
APP_URL_DLSERVER=https://droidvmres-1316343437.cos.ap-shanghai.myqcloud.com
APP_URL_DLSERVER=http://192.168.1.5/apps/droidvm/downloads
APP_RELEASE_VERSION=1.31
APP_FILENAME_URLTOOLS=./tools_url.rc
echo "export url_tools=${APP_URL_DLSERVER}/linux-installer-for-droidvm-${APP_RELEASE_VERSION}.zip" > ${APP_FILENAME_URLTOOLS}
'

ver_current=${APP_RELEASE_VERSION}
ver_lastest=`curl http://124.221.123.125/cn/download.htm|grep "\[最新版\]"|cut -d - -f 2|cut -c 1-4`
if [ "$ver_lastest" != "" ]; then
    vl_l=`echo $ver_lastest|cut -b 1`
    vl_r=`echo $ver_lastest|cut -c 3-4`

    hasnew=0

    vc_l=${APP_RELEASE_VERSION_LEFT}
    vc_r=${APP_RELEASE_VERSION_RIGHT}

    if [ $vl_l -ge $vc_l ] && [ $vl_r -gt $vc_r ] ; then
        hasnew=1
    fi
    if [ $vl_l -gt $vc_l ]; then
        hasnew=1
    fi
    if [ $hasnew -ne 1 ]; then
        echo -e "\n您当前使用的虚拟电脑版本($ver_current)已是最新版\n\n" > /tmp/msg.txt
        gxmessage -title "提示" -file /tmp/msg.txt -center -buttons "重新安装:0,取消操作:1"
        case "$?" in
            "0")
                :
                ;;
            *) 
                echo "您已取消安装"
                exit 0
                ;;
        esac
    fi

fi


# nowtime=$(date +"%Y-%m-%d_%H-%M-%S")
# echo $nowtime

if [ -f "${APP_FILENAME_URLDLSERVER}" ]; then
  . ${APP_FILENAME_URLDLSERVER}
fi


filesaveto="/exbin/tmp/droidvm-${ver_lastest}.apk"
# if [ ! -f ${filesaveto} ]; then
    url_newapk="${APP_URL_DLSERVER}/droidvm-${ver_lastest}.apk"
    wget ${url_newapk} -O ${filesaveto}
    rlt_code=$?
    if [ $rlt_code -ne 0 ]; then
        rm -rf "${filesaveto}" 2>/dev/null
        echo -e "\n新版apk安装包下载失败\n${url_newapk}\n\n" > /tmp/msg.txt
        gxmessage -title "错误" -file /tmp/msg.txt -center
        exit 1
    fi
# fi


echo "正在安装"
cp -f ${filesaveto}  /exbin/tmp/droidvm.apk
echo "#vmUpdateApk" > "${NOTIFY_PIPE}"
