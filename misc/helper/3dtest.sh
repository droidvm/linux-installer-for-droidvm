#!/bin/bash


function exit_if_fail() {
    rlt_code=$1
    fail_msg=$2
    if [ $rlt_code -ne 0 ]; then
      echo "\n错误码: ${rlt_code}, ${fail_msg}"
      read -s -n1 -p "按任意键退出"
      exit $rlt_code
    fi
}

which glmark2 >/dev/null 2>&1
if [ $? -ne 0 ]; then

    gxmessage -title "请确认" "glmark2未安装，是否现在安装？"  -center -buttons "安装:1,取消:0"
    if [ $? -ne 1 ]; then
        exit 0
    fi

    echo "正在安装glmark2, 需往系统可执行目录写入文件"
    echo "请输入密码进行授权"
    echo "当前账户的密码默认是:droidvm"
    sudo apt-get install glmark2 -y
    exit_if_fail $? "glmark2安装失败"
fi


gxmessage -title "请选择" "请选择GL驱动类型"  -center -buttons "virpipe:2,llvmpipe:1,取消:0"
case "$?" in
    "2")
        ps -ax | grep svc_virgl | grep -v grep
        if [ $? -ne 0 ]; then
            echo "安卓端VIRGL服务进程未启动"
            gxmessage -title "错误" $'\n安卓端VIRGL服务进程未启动！\n请在 开始使用->APP控制->安卓端自启动进程 中将其设置为自动启动\n\nVIRGL目前仅支持arm64!\n\n'  -center
            exit 0
        fi

        export GALLIUM_DRIVER=virpipe
        export MESA_GL_VERSION_OVERRIDE=4.0
        ;;
    "1")
        export GALLIUM_DRIVER=llvmpipe
        export MESA_GL_VERSION_OVERRIDE=4.0
        ;;
    *)
        exit 0
        ;;
esac

echo "已指定的GL驱动类型：${GALLIUM_DRIVER}"
echo "已指定的GL驱动版本：${MESA_GL_VERSION_OVERRIDE}"

glmark2
# glmark2 --fullscreen

read -s -n1 -p "按任意键继续 ... " && echo ""



# 齿轮测试：
# sudo apt-get install -y mesa-utils
# GALLIUM_DRIVER=virpipe MESA_GL_VERSION_OVERRIDE=4.0 glxgears


