#!/bin/bash

export DIR_SCRIPT=$(dirname $(realpath $0))

if [ "$1" != "" ]; then
	export DIR_SHARED=$1
else
	export DIR_SHARED=${DIR_SCRIPT}/shared
fi

# mkdir -p   ${DIR_SCRIPT}/shared 2>/dev/null
# HOSTIP=`ip a|grep 'inet '|grep -v 127|cut -d '/' -f 1|cut -d ' ' -f 6|grep 192`
# echo "export HOSTIP=$HOSTIP"				>>${DIR_SHARED}/hostvars.rc


echo "#!/bin/bash"							> ${DIR_SHARED}/hostvars.rc
busybox ifconfig 2>/dev/null|grep "inet addr:"|grep -v "127.0.0.1"| \
awk '{print $2}'|awk -v FS=":" -v OFS="" -v header="export HOSTIP=" -v tail="" '{print header,$2,tail}' \
											>>${DIR_SHARED}/hostvars.rc
. ${DIR_SHARED}/hostvars.rc
echo "export DISPLAY=${HOSTIP}${DISPLAY}"	>>${DIR_SHARED}/hostvars.rc

chmod 777  ${DIR_SHARED}/*.sh  2>/dev/null

if [ -f ${DIR_SCRIPT}/virhd-amd64.img.qcow2 ]; then
	exec qemu-system-x86_64 \
		--no-reboot \
		-nographic \
		-smp 1 \
		-m 1G \
		-kernel ${DIR_SCRIPT}/kernel/linux-amd64 \
		-drive if=virtio,file=${DIR_SCRIPT}/virhd-amd64.img.qcow2,format=qcow2,cache=none \
		-netdev user,id=usernet,hostfwd=tcp::8080-:80 \
		-device e1000,netdev=usernet \
		-append "panic=-1 ip=dhcp root=/dev/vda rw loglevel=8 init=/zzinit console=ttyS0" \
		-virtfs local,path=${DIR_SHARED},mount_tag=hostdir,security_model=mapped,fmode='0777',dmode='0777',id=hostdir \
		-device qemu-xhci -usb -device usb-kbd -device usb-tablet

		# -netdev user,id=mynet0,net=192.168.76.0/24,dhcpstart=192.168.76.9 -device rtl8139,netdev=mynet0
elif [ -f ${DIR_SCRIPT}/virhd-amd64.img ]; then
	exec qemu-system-x86_64 \
		--no-reboot \
		-nographic \
		-smp 1 \
		-m 1G \
		-kernel ${DIR_SCRIPT}/kernel/linux-amd64 \
		-drive if=virtio,file=${DIR_SCRIPT}/virhd-amd64.img,format=raw,cache=none \
		-netdev user,id=usernet,hostfwd=tcp::8080-:80 \
		-device e1000,netdev=usernet \
		-append "panic=-1 ip=dhcp root=/dev/vda rw loglevel=8 init=/zzinit console=ttyS0" \
		-virtfs local,path=${DIR_SHARED},mount_tag=hostdir,security_model=mapped,fmode='0777',dmode='0777',id=hostdir \
		-device qemu-xhci -usb -device usb-kbd -device usb-tablet

		# -netdev user,id=mynet0,net=192.168.76.0/24,dhcpstart=192.168.76.9 -device rtl8139,netdev=mynet0
else
	####################################################
	#
	# 这种方式得以真实的root权限运行，否则不能挂载目录
	#
	####################################################

	rootfs_dir=${DIR_SCRIPT}/rootfs
	user_app_0=/zzinit
	exec qemu-system-x86_64 \
		-m 1G \
		-machine pc \
		-smp 1 \
		-netdev user,id=usernet,hostfwd=tcp::8080-:80 \
		-device e1000,netdev=usernet \
		-device qemu-xhci -usb -device usb-kbd -device usb-tablet \
		-kernel ${DIR_SCRIPT}/kernel/linux-amd64 -nographic \
		-virtfs local,path=${rootfs_dir},mount_tag=/dev/root,security_model=passthrough,fmode='0777',dmode='0777',id=root \
		-virtfs local,path=${DIR_SHARED},mount_tag=hostdir,security_model=mapped,fmode='0777',dmode='0777',id=hostdir \
		-append "rw rootfstype=9p rootflags=trans=virtio console=ttyS0 init=${user_app_0} ip=dhcp"    # loglevel=8" #  panic=-1 
fi