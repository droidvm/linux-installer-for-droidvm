#!/bin/bash

# 设置控制台窗口的标题栏
PS1=$PS1"\[\e]0;编译安装box\a\]"



function makedeb() {
      # 参考：https://blog.csdn.net/badbayyj/article/details/129353140

      DEB_DIR=./deb_build
      rm -rf   ${DEB_DIR}
      mkdir -p ${DEB_DIR}
      mkdir -p ${DEB_DIR}/DEBIAN

      echo "Package: box"                       > ${DEB_DIR}/DEBIAN/control
      echo "Version: 1.0.0"                     >>${DEB_DIR}/DEBIAN/control
      echo "Architecture: arm64"                >>${DEB_DIR}/DEBIAN/control
      echo "Maintainer: 韦华锋"                 >>${DEB_DIR}/DEBIAN/control
      echo "Description: box86,box64"           >>${DEB_DIR}/DEBIAN/control
      # echo "Depends: libc6:armhf"             >>${DEB_DIR}/DEBIAN/control

      echo '#!/bin/sh'                                      > ${DEB_DIR}/DEBIAN/postinst
      echo 'echo ""'                                        >>${DEB_DIR}/DEBIAN/postinst
      echo 'echo "请注意："'                                >>${DEB_DIR}/DEBIAN/postinst
      echo 'echo "你需要自己运行以下指令, box86才能运行："' >>${DEB_DIR}/DEBIAN/postinst
      echo 'echo "================================"'        >>${DEB_DIR}/DEBIAN/postinst
      echo 'echo "sudo dpkg --add-architecture armhf"'      >>${DEB_DIR}/DEBIAN/postinst
      echo 'echo "sudo apt-get update"'                     >>${DEB_DIR}/DEBIAN/postinst
      echo 'echo "sudo apt install libc6:armhf -y"'         >>${DEB_DIR}/DEBIAN/postinst
      echo 'echo "================================"'        >>${DEB_DIR}/DEBIAN/postinst

      chmod 755 ${DEB_DIR}/DEBIAN/control
      chmod 755 ${DEB_DIR}/DEBIAN/postinst

      mkdir -p ${DEB_DIR}/usr/local/bin
      mkdir -p ${DEB_DIR}/etc/binfmt.d
      mkdir -p ${DEB_DIR}/usr/lib/i386-linux-gnu
      mkdir -p ${DEB_DIR}/usr/lib/x86_64-linux-gnu
      mkdir -p ${DEB_DIR}/etc

      cp -f /usr/local/bin/box64                      ${DEB_DIR}/usr/local/bin/box64
      cp -f /etc/binfmt.d/box64.conf                  ${DEB_DIR}/etc/binfmt.d/box64.conf
      cp -f /usr/lib/x86_64-linux-gnu/libstdc++.so.5  ${DEB_DIR}/usr/lib/x86_64-linux-gnu/libstdc++.so.5
      cp -f /usr/lib/x86_64-linux-gnu/libstdc++.so.6  ${DEB_DIR}/usr/lib/x86_64-linux-gnu/libstdc++.so.6
      cp -f /usr/lib/x86_64-linux-gnu/libgcc_s.so.1   ${DEB_DIR}/usr/lib/x86_64-linux-gnu/libgcc_s.so.1
      cp -f /usr/lib/x86_64-linux-gnu/libpng12.so.0   ${DEB_DIR}/usr/lib/x86_64-linux-gnu/libpng12.so.0
      cp -f /etc/box64.box64rc                        ${DEB_DIR}/etc/box64.box64rc

      cp -f /usr/local/bin/box86                      ${DEB_DIR}/usr/local/bin/box86
      cp -f /etc/binfmt.d/box86.conf                  ${DEB_DIR}/etc/binfmt.d/box86.conf
      cp -f /usr/lib/i386-linux-gnu/libstdc++.so.6    ${DEB_DIR}/usr/lib/i386-linux-gnu/libstdc++.so.6
      cp -f /usr/lib/i386-linux-gnu/libstdc++.so.5    ${DEB_DIR}/usr/lib/i386-linux-gnu/libstdc++.so.5
      cp -f /usr/lib/i386-linux-gnu/libgcc_s.so.1     ${DEB_DIR}/usr/lib/i386-linux-gnu/libgcc_s.so.1
      cp -f /usr/lib/i386-linux-gnu/libpng12.so.0     ${DEB_DIR}/usr/lib/i386-linux-gnu/libpng12.so.0
      cp -f /etc/box86.box86rc                        ${DEB_DIR}/etc/box86.box86rc

      dpkg -b ${DEB_DIR}

      if [ -f deb_build.deb ]; then
            # 解包
            # dpkg-deb -x deb_build.deb undeb
            echo "DEB包生成成功 => ./box.deb"
            cp -f deb_build.deb box.deb
            mv -f deb_build.deb /sdcard/box.deb
            return 0
      fi

      return 1
}



box86Path=`which box86 2>>/dev/null`
box64Path=`which box64 2>>/dev/null`

if [ "${box86Path}" != "" ] && [ "${box64Path}" != "" ]; then
      gxmessage -title "提示" "box86/64已安装，继续编译将会覆盖现在有版本，确定要继续吗？"  -center -buttons "确定:1,取消:0"
      if [ $? -ne 1 ]; then
            exit 0
      fi
fi

curr_arch=`uname -m`
if [ "${curr_arch}" != "aarch64" ]; then
    gxmessage -title "信息" "非arm64架构，不能运行box，无需编译！"  -center
    exit 0
fi


function exit_if_fail() {
    rlt_code=$1
    fail_msg=$2
    if [ $rlt_code -ne 0 ]; then
      echo "\n错误码: ${rlt_code}, ${fail_msg}"
      read -s -n1 -p "按任意键退出"
      exit $rlt_code
    fi
}

echo "正在编译安装box, 需往系统可执行目录写入文件"
echo "请输入密码进行授权"
echo "当前账户的密码默认是:droidvm"
sudo echo "正在编译安装box86和box64"

sudo apt -y install git gcc cmake make python3
exit_if_fail $? "arm64-gcc 安装失败"

sudo apt -y install gcc-arm-linux-gnueabihf
exit_if_fail $? "arm32-gcc 安装失败"

sudo apt -y install g++-arm-linux-gnueabihf
exit_if_fail $? "arm32-g++ 安装失败"

mkdir -p ~/src; cd ~/src;

if [ ! -d box86 ]; then
      echo "正在下载box86源码"
      # git clone https://gitee.com/smlawb/box86.git
      git clone https://gitee.com/mirrors_ptitSeb/box86.git
      exit_if_fail $? "box86 源码下载失败"
fi

if [ ! -d box64 ]; then
      echo "正在下载box64源码"
      git clone https://gitee.com/hedan666/box64.git
      exit_if_fail $? "box64 源码下载失败"
fi





echo "正在编译box86"    # https://ptitseb.github.io/box86/COMPILE.html
cd ~/src/box86
mkdir build; cd build; 
cmake ../ \
      -DBAD_SIGNAL=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo -DARM64=1 \
      -DCMAKE_C_COMPILER=/usr/bin/arm-linux-gnueabihf-gcc \
      -DCMAKE_CXX_COMPILER=/usr/bin/arm-linux-gnueabihf-g++
      exit_if_fail $? "box86 cmake编译失败"
make -j$(nproc)
      exit_if_fail $? "box86 make编译失败"
make install
      exit_if_fail $? "box86 安装失败"

# read -s -n1 -p "调试版本下，只编译box86 按任意键继续 ... "
# exit 0


#密码保活，避免后面又要重新输入一次密码
#sudo --reset-timestamp
sudo --validate

echo "正在编译box64"    # https://github.com/ptitSeb/box64/blob/main/docs/COMPILE.md
cd ~/src/box64
mkdir build; cd build; 
cmake ../ \
      -DBAD_SIGNAL=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo -DARM_DYNAREC=ON \
      -DCMAKE_C_COMPILER=gcc
      # -DCMAKE_CXX_COMPILER=g++ 
      exit_if_fail $? "box64 cmake编译失败"
make -j$(nproc)
      exit_if_fail $? "box64 make编译失败"
make install
      exit_if_fail $? "box64 安装失败"


echo "正在生成为deb包"
makedeb
exit_if_fail $? "deb包生成失败"

echo "正在启用 multi-arch ..."
sudo dpkg --add-architecture armhf && sudo apt-get update

echo "正在安装 arm32版libc6 ..."
sudo apt install libc6:armhf -y

box86 -v
box64 -v


which wine >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo ""                                         > /tmp/msg.txt
    echo "检测到wine已经安装，是否现在启动wine？"   >>/tmp/msg.txt
    echo "提示：第一次启动wine会非常慢"             >>/tmp/msg.txt
    gxmessage -title "提示" -file /tmp/msg.txt -center -buttons "启动:1,取消:0"
    if [ $? -eq 1 ]; then
        WINEARCH=win64 /usr/local/bin/box64 wine64 explorer
        # WINEARCH=win64 /usr/local/bin/box64 wine64 /sdcard/winrar-x64-621scp.exe
    fi
fi


echo "box86/64编译、安装均已完成."
gxmessage -title "提示" "box86/64编译、安装均已完成."  -center
# read -s -n1 -p "按任意键继续 ... "
