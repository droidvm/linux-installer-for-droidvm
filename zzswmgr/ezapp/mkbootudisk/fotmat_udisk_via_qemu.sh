#!/bin/bash

. /mnt/shared/hostvars.rc

function exit_if_fail() {
    rlt_code=$1
    fail_msg=$2
    if [ $rlt_code -ne 0 ]; then
      echo -e "错误码: ${rlt_code}\n${fail_msg}"
      # read -s -n1 -p "按任意键退出"
      exit $rlt_code
    fi
}

echo ""
echo "欢迎使用虚拟电脑app来制作 WINPE 启动U盘"
echo "脚本整理：韦华锋 2024.01.04"
echo ""


if [ "$HOSTIP" == "" ]; then
	echo "HOSTIP 为空，将不可通过usbip访问安卓端设备"
	echo "正在退出"
	exit 2
fi

function scanusbdevice() {
	for num in {1..120}  
	do  
		echo "正在通过usbip连接安卓端的U盘"
		exported_usb_devcnt=`usbip list -r $HOSTIP 2>/dev/null|grep vendor|cut -d ":" -f 1|wc -l`
		if [ $exported_usb_devcnt -lt 1 ]; then
			echo -e "[[[ \e[96m请确认USB设备是否已经连到安卓设备\e[0m ]]]"
			sleep 3
			continue
			# exit 3
		fi

		if [ $exported_usb_devcnt -gt 1 ]; then
			echo "\e[96m安卓端对外共享的USB设备多于一个，请移除非目标U盘以外的USB设备\e[0m"
			# exit 4
			sleep 3
			continue
		fi

		break;
	done

	exported_usb_device=`usbip list -r $HOSTIP 2>/dev/null|grep vendor|cut -d ":" -f 1`
	echo -e $exported_usb_device

	usbip attach -r $HOSTIP -b $exported_usb_device
	usb_attach_rlt=$?
	exit_if_fail $usb_attach_rlt "无法通过usbip连接安卓端的U盘"
	sleep 5

	if [ ! -b /dev/sda ]; then

		usbip detach -p 00

		usbip attach -r $HOSTIP -b $exported_usb_device
		usb_attach_rlt=$?
		exit_if_fail $usb_attach_rlt "无法通过usbip连接安卓端的U盘"
		sleep 10

	fi

	if [ ! -b /dev/sda ]; then
		echo "无法将安卓端U盘映射至虚拟系统!"
		exit 5
	fi

}

function setupsw() {
	need2install=0

	command -v mkfs.vfat >/dev/null
	if [ $? -ne 0 ]; then need2install=1; fi

	command -v fdisk >/dev/null
	if [ $? -ne 0 ]; then need2install=1; fi

	command -v unzip >/dev/null
	if [ $? -ne 0 ]; then need2install=1; fi

	which grub-install >/dev/null
	if [ $? -ne 0 ]; then need2install=1; fi

	if [ $need2install -ne 0 ]; then
		# grep "mirrors.tuna.tsinghua.edu.cn" /etc/apt/sources.list
		# if [ $? -ne 0 ]; then
		# 	echo "正在将软件仓库切换为国内服务器"
		# 	/zz_change_repo
		# 	exit_if_fail $? "U盘制作工具安装失败，无法切换到国内软件仓库"
		# else
		# 	echo "正在拉取最新的软件清单"
		# 	apt update
		# 	exit_if_fail $? "apt update 失败"
		# fi

		# echo "正在安装dosfstools"
		# apt-get install -y unzip dosfstools fdisk grub2 # mbr
		# exit_if_fail $? "dosfstools 和 fdisk 安装失败"

		echo "正在安装启动盘制作工具"
		dpkg -i /mnt/shared/pre_download_debs/*.deb
		exit_if_fail $? "dosfstools 和 fdisk 安装失败"
	fi
}

scanusbdevice

setupsw

echo "正在清除U盘签名"
wipefs -a /dev/sda
exit_if_fail $? "U盘签名无法清除"

echo "正在清除U盘分区表"
dd if=/dev/zero of=/dev/sda bs=1M count=8
exit_if_fail $? "U盘分区表无法清除"

sync
exit_if_fail $? "U盘分区失败"


echo "正在对U盘重新分区"
echo -e "o\nn\np\n1\n2048\n+400M\nY\nw\n"|fdisk /dev/sda
exit_if_fail $? "无法创建第一个分区"

echo -e "n\np\n2\n\n\nw\n"|fdisk /dev/sda
exit_if_fail $? "无法创建第二个分区"

echo -e "t\n1\n0b\nw\n"|fdisk /dev/sda
exit_if_fail $? "无法将第一个分区标识为 FAT32 文件系统"

# echo -e "t\n2\n07\nw\n"|fdisk /dev/sda
# exit_if_fail $? "无法将第二个分区标识为 NTFS  文件系统"
echo -e "t\n2\n0b\nw\n"|fdisk /dev/sda
exit_if_fail $? "无法将第二个分区标识为 FAT32 文件系统"

echo "U盘分区已完成，信息如下："
fdisk -l /dev/sda


echo "正在格式化第一个分区，请注意，格式化完成后FAT32分区可能会凭空多出几个目录"
echo "这些目录是安卓创建的！"
mkfs.vfat -F 32 /dev/sda1 -n WINPE
exit_if_fail $? "U盘第一个分区格式化失败"

echo "正在格式化第二个分区"
# # mkfs.ntfs /dev/sda2 # 在qemu中格式化ntfs实在太慢
# echo "正在清除第二个分区"
# dd if=/dev/zero of=/dev/sda2 bs=1M count=8
mkfs.vfat -F 32 /dev/sda2 -n UPan
exit_if_fail $? "U盘第二个分区格式化失败"

# 支持BIOS启动
if [ 1 -eq 1 ]; then

	# 本想兼容老破旧电脑的，但windows的pbr在linux下暂时没法创建，又不想用grub做跳板，也不想用iso直写的方式实现，放着先了。。。 // todo

	echo -e "a\n1\nw\n"|fdisk /dev/sda
	exit_if_fail $? "无法将第一个分区标记为可启动分区"

	# install-mbr -e 1 /dev/sda
	# exit_if_fail $? "无法向U盘第一扇区写入盘首引导代码(MBR, 老古板们通常把它翻译为主引导记录，MBR用于兼容老旧电脑)"

	# echo "MBR已写入，相关信息如下："
	# install-mbr -l   /dev/sda
	
	echo "正在写入MBR及安装grub2"
	mkdir -p /udiskpart1
	mount /dev/sda1 /udiskpart1
	exit_if_fail $? "无法挂载U盘第一个分区"

	mkdir -p /udiskpart1/EFI/boot 2>/dev/null
	mkdir -p /udiskpart1/EFI/grub 2>/dev/null

	# grub-install --directory=/udiskpart1 /dev/sda
	grub-install /dev/sda --boot-directory=/udiskpart1/EFI
	exit_if_fail $? "grub2安装失败"


	cat <<- EOF > /udiskpart1/EFI/grub/grub.cfg
		# grub2的配置文件(v1.97及更早的版本叫gnu grub, v1.98及之后的版本叫gnu grub2，另外还有专门的grub4dos)
		# https://www.gnu.org/software/grub/index.html    gnu grub官方网站
		# https://www.cnblogs.com/mao0504/p/5589742.html 《grub2与grub区别》
		# ###############################################################################

		set timeout=10
		set default=0

		menuentry "winpe" {
			# find  --set-root /bootmgr
			# chainloader /bootmgr
			# search --set -f /bootmgr
			# search -f /bootmgr --set root
			# chainloader +1
			# chainloader /bootmgr
			# chainloader +1

			insmod fat
			insmod chain
			ntldr /bootmgr
			boot
		}

		menuentry "FreeDOS" {
			# chainloader /boot/freedos/bin/kernel.sys
			insmod fat
			insmod chain
			search -f /boot/freedos/bin/kernel.sys --set root --no-floppy
			freedos /boot/freedos/bin/kernel.sys
			boot
		}

		menuentry "ubuntu.iso" {
			loopback loop /ubuntu.iso
			linux (loop)/casper/vmlinuz boot=casper iso-scan/filename=/ubuntu.iso splash --
			initrd (loop)/casper/initrd
		}

		menuentry "reboot" {
			reboot
		}

	EOF
	sync
	exit_if_fail $? "MBR写入失败"


	echo ""
	echo "正在复制 winpe 启动文件到U盘. . ."
	cp -Rf /mnt/shared/winpe/*  /udiskpart1/
	exit_if_fail $? "winpe文件复制失败"

	rm -rf /mnt/shared/winpe

	# unzip -oq /mnt/shared/winpe.zip -d /udiskpart1/
	# exit_if_fail $? "winpe文件解压失败"
	# rm -rf ${DIR_SHARED}/winpe.zip

	sync
	exit_if_fail $? "winpe启动文件写入失败"


	umount /udiskpart1

	rm -rf /udiskpart1


fi



sync
exit_if_fail $? "U盘分区失败"

usbip detach -p 00

echo "已完成对U盘分区和格式化"
# echo -e "\e[96m请关闭此窗口\e[0m"



echo ""							> /mnt/shared/autorun.rlt
echo "export FORMAT_RLT=OK"		>>/mnt/shared/autorun.rlt
echo "export AUTO_POWEROFF=YES"	>>/mnt/shared/autorun.rlt

