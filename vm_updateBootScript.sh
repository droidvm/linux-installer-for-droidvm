#!/bin/bash
: '
APP_RELEASE_VERSION=1.34
APP_URL_DLSERVER=https://droidvmres-1316343437.cos.ap-shanghai.myqcloud.com
APP_URL_DLSERVER=http://192.168.1.5/apps/droidvm/downloads
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
    if [ $hasnew -eq 1 ]; then
        echo -e "\n您当前使用虚拟电脑版本($ver_current)不是最新版\n如果更新软件管家不能解决您碰到的问题，请安装最新版安装包($ver_lastest)\n" > /tmp/msg.txt
        gxmessage -title "更新软件管家" -file /tmp/msg.txt -center
    else
        echo "安装包已是最新版，不需要更新安装包"
        echo "ver_current: $ver_current"
        echo "ver_lastest: $ver_lastest"
        echo $vl_l
        echo $vl_r
    fi

fi




source ${APP_FILENAME_URLDLSERVER}
echo "export url_tools=${APP_URL_DLSERVER}/linux-installer-for-droidvm-${APP_RELEASE_VERSION}.zip"	> ${APP_FILENAME_URLTOOLS}


cat <<- EOF > /tmp/msg.txt

请重启。

刚刚的操作需要重新打开一次虚拟电脑才能生效。

EOF

cat ${APP_FILENAME_URLTOOLS} >> /tmp/msg.txt

gxmessage -title "更新软件管家" -file /tmp/msg.txt -center -buttons "立即重启:1,稍后重启:0"
if [ $? -eq 1 ]; then
    exec /exbin/tools/vm_OSReboot.sh
fi
