#!/system/bin/sh


source vm_config.sh


rm -rf ./backupvm.sh

mkdir -p imgbak

LINUX_TAR=imgbak/bak_${CURRENT_OS_NAME}.tar
LINUX_ZIP=imgbak/bak_${CURRENT_OS_NAME}.tar.gz
ZIP_ARG=-cf

rm -rf ${LINUX_TAR}
rm -rf ${LINUX_ZIP}

date

# 创建一个临时的 vm 来打包 rootfs
echo "正在打包"
# echo "proot --link2symlink --kill-on-exit -0 -r $LINUX_DIR -w / -b ${tools_dir}:/exbin /exbin/tar $ZIP_ARG /exbin/$LINUX_TAR / --exclude='/proc' --exclude='dev' --exclude='/exbin' --exclude='proot' --exclude='/system/' --exclude='/apex' --exclude='/sdcard' --exclude='/tmp' 2>&1"
#       proot --link2symlink --kill-on-exit -0 -r $LINUX_DIR -w / -b ${tools_dir}:/exbin /exbin/tar $ZIP_ARG /exbin/$LINUX_TAR / --exclude='/proc' --exclude='dev' --exclude='/exbin' --exclude='proot' --exclude='/system/' --exclude='/apex' --exclude='/sdcard' --exclude='/tmp' 2>&1

# echo "proot --link2symlink --kill-on-exit -0 -r $LINUX_DIR -w / -b ${tools_dir}:/exbin /exbin/tar $ZIP_ARG /exbin/$LINUX_TAR / --exclude='/proc' --exclude='dev' --exclude='/exbin' --exclude='proot' 2>&1"
#       proot --link2symlink --kill-on-exit -0 -r $LINUX_DIR -w / -b ${tools_dir}:/exbin /exbin/tar $ZIP_ARG /exbin/$LINUX_TAR / --exclude='/proc' --exclude='dev' --exclude='/exbin' --exclude='proot' 2>&1

cat <<- EOF >  ./tmp_backup_script
export PATH=/exbin
tar -czf /exbin/$LINUX_ZIP / \
--exclude=/proc \
--exclude=/dev \
--exclude=/exbin \
--exclude=proot \
--exclude=/host-rootfs \
--exclude=/system \
--exclude=/sdcard

echo "备份完成"
echo ""

EOF
chmod 777 ./tmp_backup_script

command="${PROOT_BINARY_DIR}/proot --link2symlink --kill-on-exit -0 -r $LINUX_DIR -w /"
command+=" -b ${tools_dir}:/exbin"
command+=" /exbin/busybox sh /exbin/tmp_backup_script"
echo $command
$command 2>&1

# ZIP_ARG=czvf
# command="${PROOT_BINARY_DIR}/proot --link2symlink --kill-on-exit -0 -r $LINUX_DIR -w /"
# command+=" -b ${tools_dir}:/exbin"
# command+=" /exbin/tar $ZIP_ARG /exbin/$LINUX_TAR /"
# command+=" --exclude='/proc' --exclude='dev' --exclude='/exbin' --exclude='proot'"
# echo "\n\n"
# echo $command
# $command 2>&1

# ~/busybox tar -czvf ../bak.tar.gz ./vm/linux-arm64 \
# --exclude ./vm/linux-arm64/host-rootfs \
# --exclude ./vm/linux-arm64/system \
# --exclude ./vm/linux-arm64/exbin \
# --exclude ./vm/linux-arm64/sdcard \


# busybox cp -Rf linux-arm64 linux-arm64.bak



tar_rlt=$?
echo tar_rlt:$tar_rlt

if [ $tar_rlt -ne 0 ]; then
    echo2apk "打包失败"
    # exit_with_msg 5 "打包失败"
    # exit 5
else
    # echo "正在压缩到 ${LINUX_ZIP}"
    # gzip $LINUX_TAR
    # ls -al|grep $LINUX_TAR

    ls -al|grep $LINUX_ZIP
    rm -rf backupvm.sh
    date
    echo2apk "打包完成"

    echo "系统备份已完成.保存路径：\${tools_dir}/${LINUX_ZIP}" > $LINUX_DIR/tmp/osbackupmsg.txt

fi


# busybox telnetd -p 5555 -l /system/bin/sh
