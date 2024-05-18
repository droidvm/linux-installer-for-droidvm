#!/bin/bash

# source ${app_home}/droidvm_vars_setup.sh
# source ${app_home}/tools/vm_config.sh
source ${tools_dir}/vm_config.sh

function exit_if_fail() {
    rlt_code=$1
    fail_msg=$2
    if [ $rlt_code -ne 0 ]; then
      echo -e "错误码: ${rlt_code}\n${fail_msg}"
	  whoami
	  exec /bin/bash
      exit $rlt_code
    fi
}


echo '===================================='
echo2apk '正在复制自动运行的脚本 ...'
echo '===================================='
cp -Rf /exbin/autoruns /etc/
mkdir -p /etc/autoruns/autoruns_before_gui 2>/dev/null
mkdir -p /etc/autoruns/autoruns_after_gui 2>/dev/null
mkdir -p /etc/autoruns/services_before_gui 2>/dev/null
mkdir -p /etc/autoruns/services_after_gui 2>/dev/null
chmod -R 755 /exbin/autoruns

echo '===================================='
echo2apk '正在删除rootfs内建的系统登录账户 ...'
echo '===================================='
deluser ubuntu


adduser --system \
        --quiet \
        --home /nonexistent \
        --no-create-home \
        --disabled-password \
        --group messagebus

addgroup --system --gid 3003  inet
addgroup --system --gid 9997  sdcard_rw
addgroup --system --gid $((20000+$APP_ANDROID_UID)) cache
addgroup --system --gid $((50000+$APP_ANDROID_UID)) all_a$APP_ANDROID_UID

echo '===================================='
echo2apk '正在添加droidvm用户'
echo '===================================='
echo 'root:droidvm'    | chpasswd
cat /etc/group
useradd -m -r -s /bin/bash droidvm
echo 'droidvm:droidvm' | chpasswd
mkdir -p /home/droidvm/Desktop/


echo 'source /etc/profile'>  /home/droidvm/.bashrc
chgrp -R root                /home/droidvm
chown -R droidvm             /home/droidvm
chmod -R 0750                /home/droidvm
chmod -R 0750                /home/droidvm/.bashrc
chmod -R 0750                /home/droidvm/.profile

if [ 0 -eq 1 ]; then
	echo2apk '正在更新 $LINUX_DIR 中的 DNS ...'
	mkdir -p /run/systemd/resolve
	mkdir -p /etc/systemd

	touch /run/systemd/resolve/stub-resolv.conf



	# cat <<- EOF > /etc/resolv.conf
	# nameserver 114.114.114.114
	# nameserver 8.8.4.4
	# EOF

	#cat <<- EOF > /etc/systemd/resolved.conf
	#[Resolve]
	#DNS=8.8.8.8
	#EOF

	cat <<- EOF > /etc/resolv.conf
	nameserver 223.5.5.5
	nameserver 223.6.6.6
	nameserver 2400:3200::1
	nameserver 2400:3200:baba::1
	nameserver 114.114.114.114
	nameserver 114.114.115.115
	nameserver 240c::6666
	nameserver 240c::6644
	EOF
	chmod 644 /etc/resolv.conf

	cat <<- EOF > /etc/hosts
	# IPv4.
	127.0.0.1   localhost.localdomain localhost

	# IPv6.
	::1         localhost.localdomain localhost ip6-localhost ip6-loopback
	fe00::0     ip6-localnet
	ff00::0     ip6-mcastprefix
	ff02::1     ip6-allnodes
	ff02::2     ip6-allrouters
	ff02::3     ip6-allhosts
	EOF

	# proot有时候无法解析dns，所以这里添加一下apt仓库域名的静态解析，以便能顺利使用apt安装软件
	cp -f /etc/hosts.bak
	cat <<- EOF >> /etc/hosts

	# IPv4. add by droidvm

	112.86.231.46	droidvmres-1316343437.cos.ap-shanghai.myqcloud.com
	180.76.198.77	gitee.com
	180.76.198.77	foruda.gitee.com
	39.155.141.16	mirrors.bfsu.edu.cn
	218.104.71.170	mirrors.ustc.edu.cn
	101.6.15.130	mirrors.tuna.tsinghua.edu.cn
	185.125.190.36	ports.ubuntu.com
	185.125.190.39	ports.ubuntu.com
	91.189.91.82	security.ubuntu.com
	91.189.91.81	security.ubuntu.com
	185.125.190.36	security.ubuntu.com
	185.125.190.39	security.ubuntu.com
	91.189.91.83	security.ubuntu.com

	# IPv6. add by droidvm
	2402:f000:1:400::2				pypi.tuna.tsinghua.edu.cn
	2402:f000:1:400::2				mirror.tuna.tsinghua.edu.cn
	2620:2d:4000:1::16              archive.ubuntu.com
	2408:8748:b500:214:3::3e5		mirrors.aliyun.com
	# 2409:8700:2482:710::fe55:2840 mirrors.bfsu.edu.cn
	# 2001:da8:d800:95::110         mirrors.ustc.edu.cn
	# 2402:f000:1:400::2            mirrors.tuna.tsinghua.edu.cn
	# 2620:2d:4000:1::16            ports.ubuntu.com
	# 2620:2d:4000:1::19            security.ubuntu.com
	EOF
fi

echo2apk '正在获取软件仓库中的软件列表 ...'
apt update

echo '===================================='
echo2apk '正在给droidvm用户组授以sudo的权限'
echo '===================================='
which sudo >/dev/null 2>&1
if [ $? -ne 0 ]; then
  apt-get install sudo -y
fi

# 修复部分rootfs中droidvm用户不能运行sudo su的问题
chown root:root /usr/bin/sudo
chmod 4755 /usr/bin/sudo
chown root:root /etc/sudo.conf
chown root:root /etc/sudoers.d
chmod 4755 /etc/sudoers.d
chown root:root /run/sudo/ts
chmod 4755 /run/sudo/ts


# 居然会影响sudo时的环境变量！
chmod 4660									     /etc/sudoers.d/droidvm
  echo '%droidvm   ALL=(ALL:ALL)           ALL' >/etc/sudoers.d/droidvm
# echo '%droidvm   ALL=(ALL:ALL) NOPASSWD: ALL' >/etc/sudoers.d/droidvm
chmod 4440									     /etc/sudoers.d/droidvm

: '
   A       B     = {C}                        {D}                  E
username  hosts  = target_username/groupt     pwd_required         enabled_commands
第一部分A代表授权使用sudo的用户或者组
第二部分B代表允许授权用户在哪些主机上使用这些权利
第三部分C代表允许被授权用户提权到什么用户什么组级别的权限，如果省略就代表允许提权到任意用户级别。
第四部分D代表当被授权用户是否需要输入自身密码来使用特权，若省略这代表需要输入密码
第五部分E代表允许执行的命令，如果是all就代表允许执行所有命令
'


echo '===================================='
echo2apk '正在生成droidvm用户的桌面文件 ...'
echo '===================================='
ln -s -f ${app_home}/doc/教程		/home/droidvm/Desktop/
ln -s -f /sdcard					/home/droidvm/Desktop/SD卡
ln -s -f /home/droidvm              /home/droidvm/Desktop/文件
ln -s -f /usr/share/applications    /home/droidvm/Desktop/软件
cp -f ${tools_dir}/misc/def_desktop/${CURRENT_VM_ARCH}/*.desktop  					/home/droidvm/Desktop/
mkdir -p /home/droidvm/.local/share/Trash 2>/dev/null
chown -R droidvm /home/droidvm/Desktop/*.desktop
chown -R droidvm /home/droidvm/
# chmod 755 ${tools_dir}/zzswmgr/zzswmgr.js
# chmod 755 ${tools_dir}/zzswmgr/zzswmgr.py

# pcmanfm 书签收藏
echo "file:/// 根目录"> /home/droidvm/.gtk-bookmarks
ln -s -f /home/droidvm/.local/share/Trash		/home/droidvm/Desktop/回收站


# echo -e "请在软件管家中安装box和wine，\n再在wine中运行exe程序、exe软件、exe游戏">	/home/droidvm/Desktop/运行exe.txt
# echo -e "\n\n请注意，wine对exe的兼容度并不是很好，不能运行所有的exe程序"		>>	/home/droidvm/Desktop/运行exe.txt
# echo -e "\n开始使用->APP控制->申请权限以读写 /sdcard"							>	/home/droidvm/Desktop/U盘打不开.txt
# echo -e "\n请使用手机流量网络，或者在手机上的无线网络管理界面，"				>	/home/droidvm/Desktop/无法联网.txt
# echo -e "\n选择忘记连接过的wifi，然后输入密码重连。"							>>	/home/droidvm/Desktop/无法联网.txt
# echo -e "\n在桌面上的软件管家中，安装klipper、moonraker、fluidd"				>	/home/droidvm/Desktop/3D打印.txt
# echo -e "\n安装完成双击桌面上的klipper图标启动，然后看启动信息"					>>	/home/droidvm/Desktop/3D打印.txt
# echo -e "\n虚拟电脑中的klipper使用网络地址连接串口，不需要自己找串口设备路径!"	>>	/home/droidvm/Desktop/3D打印.txt
# echo -e "\n"																	>>	/home/droidvm/Desktop/3D打印.txt
# echo -e "\nfluidd和mainsail都是klipper的网页控制端，装一个即可"					>>	/home/droidvm/Desktop/3D打印.txt
# echo -e "\n如果moonraker安装失败，请将手机切换到移动数据网络后再安装"			>>	/home/droidvm/Desktop/3D打印.txt

# echo -e "\n音量减为鼠标左键"													>	/home/droidvm/Desktop/鼠标说明.txt
# echo -e "\n音量加为鼠标右键"													>>	/home/droidvm/Desktop/鼠标说明.txt

# chmod 755 ${tools_dir}/zzswmgr/scapp


echo '===================================='
echo2apk '正在备份启动脚本 ...'
echo '===================================='
mkdir -p /etc/droidvm/bootup_scripts/
mkdir -p /etc/droidvm/bootup_scripts/tools/
cp -f ${app_home}/droidvm_vars_setup.sh	/etc/droidvm/bootup_scripts/
cp -f ${app_home}/controllee			/etc/droidvm/bootup_scripts/
cp -f ${app_home}/nmftpsrv				/etc/droidvm/bootup_scripts/
cp -f ${tools_dir}/startvm.sh			/etc/droidvm/bootup_scripts/tools/
cp -f /etc/lsb-release    				/etc/lsb-release.ori
cp -f /usr/lib/os-release 				/usr/lib/os-release.ori


echo '===================================='
echo2apk '正在卸载systemd-resolved ...'
echo '===================================='
echo "proot环境中的systemd-resolved会偶发性的导致dns解析失败"
cp -f /etc/resolv.conf  /etc/resolv.conf.bak1	# 这个卸载操作，会改变 /etc/resolv.conf 的内容
apt-get autopurge -y systemd-resolved
rm -rf /etc/resolv.conf
cp -f /etc/resolv.conf.bak1 /etc/resolv.conf


# source ${app_home}/droidvm_vars_setup.sh

if [ "${vmGraphicsx}" == "1" ]; then

	. ${tools_dir}/setup-gui.sh

else
	echo "#通过运行 . ./t 可以启动telnetd"                             > /root/t
	echo "sudo -u droidvm ${app_home}/busybox telnetd -p 5556 -l bash" >>/root/t
	echo ""                                                            >>/root/t
	echo "#启动安卓控制台"                                             >>/root/t
	echo "echo \"#droidconsole\" > \${NOTIFY_PIPE}"                    >>/root/t

	chmod 755 /root/t
fi


# 都安装的软件
# end of 都安装的软件

rm -rf /usr/sbin/reboot /usr/sbin/shutdown /usr/sbin/halt
chmod 700 /exbin/reboot /exbin/shutdown /exbin/halt

dbus-uuidgen > /var/lib/dbus/machine-id



# cp ${tools_dir}/run_once.sh ${tools_dir}/run_once.sh.bak
rm -rf ${tools_dir}/run_once.sh
echo '===================================='
echo '正在清apt缓存'
apt-get clean
echo '===================================='
echo '===================================='


