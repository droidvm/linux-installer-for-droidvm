#!/system/bin/sh

# source vm_config.sh

LINUX_FAKE_PROC_DIR=/data/data/com.termux/files/home/ndkproot/fake_proc

mkdir -p  "${LINUX_FAKE_PROC_DIR}"
chmod 700 "${LINUX_FAKE_PROC_DIR}"

tmpfn=${LINUX_FAKE_PROC_DIR}/.loadavg
if [ ! -f "${tmpfn}" ]; then
	cat <<- EOF > "${tmpfn}"
	0.54 0.41 0.30 1/931 370386
	EOF
fi

# # 无效。。。
# if [ ! -f "${LINUX_FAKE_PROC_DIR}/sys/kernel/overflowuid" ]; then
# 	cat <<- EOF > "${LINUX_FAKE_PROC_DIR}/sys/kernel/overflowuid"
# 	65534
# 	EOF
# fi

# # 无效
# if [ ! -f "${LINUX_FAKE_PROC_DIR}/mounts" ]; then
# 	echo "/dev/sdb on / type ext4 (rw,relatime,discard,errors=remount-ro,data=ordered)"		> "${LINUX_FAKE_PROC_DIR}/mounts"
# fi


if [ ! -f "${LINUX_FAKE_PROC_DIR}/.stat" ]; then
	cat <<- EOF > "${LINUX_FAKE_PROC_DIR}/.stat"
	cpu  1050008 127632 898432 43828767 37203 63 99244 0 0 0
	cpu0 212383 20476 204704 8389202 7253 42 12597 0 0 0
	cpu1 224452 24947 215570 8372502 8135 4 42768 0 0 0
	cpu2 222993 17440 200925 8424262 8069 9 17732 0 0 0
	cpu3 186835 8775 195974 8486330 5746 3 8360 0 0 0
	cpu4 107075 32886 48854 8688521 3995 4 5758 0 0 0
	cpu5 90733 20914 27798 1429573 2984 1 11419 0 0 0
	intr 53261351 0 686 1 0 0 1 12 31 1 20 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7818 0 0 0 0 0 0 0 0 255 33 1912 33 0 0 0 0 0 0 3449534 2315885 2150546 2399277 696281 339300 22642 19371 0 0 0 0 0 0 0 0 0 0 0 2199 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2445 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 162240 14293 2858 0 151709 151592 0 0 0 284534 0 0 0 0 0 0 0 0 0 0 0 0 0 0 185353 0 0 938962 0 0 0 0 736100 0 0 1 1209 27960 0 0 0 0 0 0 0 0 303 115968 452839 2 0 0 0 0 0 0 0 0 0 0 0 0 0 160361 8835 86413 1292 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3592 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 6091 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 35667 0 0 156823 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 138 2667417 0 41 4008 952 16633 533480 0 0 0 0 0 0 262506 0 0 0 0 0 0 126 0 0 1558488 0 4 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 2 8 0 0 6 0 0 0 10 3 4 0 0 0 0 0 3 0 0 0 0 0 0 0 0 0 0 0 20 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 12 1 1 83806 0 1 1 0 1 0 1 1 319686 2 8 0 0 0 0 0 0 0 0 0 244534 0 1 10 9 0 10 112 107 40 221 0 0 0 144
	ctxt 90182396
	btime 1595203295
	processes 270853
	procs_running 2
	procs_blocked 0
	softirq 25293348 2883 7658936 40779 539155 497187 2864 1908702 7229194 279723 7133925
	EOF
fi

if [ ! -f "${LINUX_FAKE_PROC_DIR}/.uptime" ]; then
	cat <<- EOF > "${LINUX_FAKE_PROC_DIR}/.uptime"
	284684.56 513853.46
	EOF
fi

if [ ! -f "${LINUX_FAKE_PROC_DIR}/.version" ]; then
	cat <<- EOF > "${LINUX_FAKE_PROC_DIR}/.version"
	Linux version 5.4.0-faked (termux@androidos) (gcc version 4.9.x (Faked /proc/version by Proot-Distro) ) #1 SMP PREEMPT Fri Jul 10 00:00:00 UTC 2020
	EOF
fi

if [ ! -f "${LINUX_FAKE_PROC_DIR}/.vmstat" ]; then
	cat <<- EOF > "${LINUX_FAKE_PROC_DIR}/.vmstat"
	nr_free_pages 146031
	nr_zone_inactive_anon 196744
	nr_zone_active_anon 301503
	nr_zone_inactive_file 2457066
	nr_zone_active_file 729742
	nr_zone_unevictable 164
	nr_zone_write_pending 8
	nr_mlock 34
	nr_page_table_pages 6925
	nr_kernel_stack 13216
	nr_bounce 0
	nr_zspages 0
	nr_free_cma 0
	numa_hit 672391199
	numa_miss 0
	numa_foreign 0
	numa_interleave 62816
	numa_local 672391199
	numa_other 0
	nr_inactive_anon 196744
	nr_active_anon 301503
	nr_inactive_file 2457066
	nr_active_file 729742
	nr_unevictable 164
	nr_slab_reclaimable 132891
	nr_slab_unreclaimable 38582
	nr_isolated_anon 0
	nr_isolated_file 0
	workingset_nodes 25623
	workingset_refault 46689297
	workingset_activate 4043141
	workingset_restore 413848
	workingset_nodereclaim 35082
	nr_anon_pages 599893
	nr_mapped 136339
	nr_file_pages 3086333
	nr_dirty 8
	nr_writeback 0
	nr_writeback_temp 0
	nr_shmem 13743
	nr_shmem_hugepages 0
	nr_shmem_pmdmapped 0
	nr_file_hugepages 0
	nr_file_pmdmapped 0
	nr_anon_transparent_hugepages 57
	nr_unstable 0
	nr_vmscan_write 57250
	nr_vmscan_immediate_reclaim 2673
	nr_dirtied 79585373
	nr_written 72662315
	nr_kernel_misc_reclaimable 0
	nr_dirty_threshold 657954
	nr_dirty_background_threshold 328575
	pgpgin 372097889
	pgpgout 296950969
	pswpin 14675
	pswpout 59294
	pgalloc_dma 4
	pgalloc_dma32 101793210
	pgalloc_normal 614157703
	pgalloc_movable 0
	allocstall_dma 0
	allocstall_dma32 0
	allocstall_normal 184
	allocstall_movable 239
	pgskip_dma 0
	pgskip_dma32 0
	pgskip_normal 0
	pgskip_movable 0
	pgfree 716918803
	pgactivate 68768195
	pgdeactivate 7278211
	pglazyfree 1398441
	pgfault 491284262
	pgmajfault 86567
	pglazyfreed 1000581
	pgrefill 7551461
	pgsteal_kswapd 130545619
	pgsteal_direct 205772
	pgscan_kswapd 131219641
	pgscan_direct 207173
	pgscan_direct_throttle 0
	zone_reclaim_failed 0
	pginodesteal 8055
	slabs_scanned 9977903
	kswapd_inodesteal 13337022
	kswapd_low_wmark_hit_quickly 33796
	kswapd_high_wmark_hit_quickly 3948
	pageoutrun 43580
	pgrotated 200299
	drop_pagecache 0
	drop_slab 0
	oom_kill 0
	numa_pte_updates 0
	numa_huge_pte_updates 0
	numa_hint_faults 0
	numa_hint_faults_local 0
	numa_pages_migrated 0
	pgmigrate_success 768502
	pgmigrate_fail 1670
	compact_migrate_scanned 1288646
	compact_free_scanned 44388226
	compact_isolated 1575815
	compact_stall 863
	compact_fail 392
	compact_success 471
	compact_daemon_wake 975
	compact_daemon_migrate_scanned 613634
	compact_daemon_free_scanned 26884944
	htlb_buddy_alloc_success 0
	htlb_buddy_alloc_fail 0
	unevictable_pgs_culled 258910
	unevictable_pgs_scanned 3690
	unevictable_pgs_rescued 200643
	unevictable_pgs_mlocked 199204
	unevictable_pgs_munlocked 199164
	unevictable_pgs_cleared 6
	unevictable_pgs_stranded 6
	thp_fault_alloc 10655
	thp_fault_fallback 130
	thp_collapse_alloc 655
	thp_collapse_alloc_failed 50
	thp_file_alloc 0
	thp_file_mapped 0
	thp_split_page 612
	thp_split_page_failed 0
	thp_deferred_split_page 11238
	thp_split_pmd 632
	thp_split_pud 0
	thp_zero_page_alloc 2
	thp_zero_page_alloc_failed 0
	thp_swpout 4
	thp_swpout_fallback 0
	balloon_inflate 0
	balloon_deflate 0
	balloon_migrate 0
	swap_ra 9661
	swap_ra_hit 7872
	EOF
fi



export PROOT_BINARY_DIR=/data/data/com.termux/files/home/ndkproot
export PROOT_LOADER=${PROOT_BINARY_DIR}/loader/loader
export PROOT_LOADER_32=${PROOT_BINARY_DIR}/loader/loader32
export PROOT_TMP_DIR=${PROOT_BINARY_DIR}/tmp
cd ${PROOT_BINARY_DIR}
mkdir tmp
chmod 777 tmp
wget http://192.168.1.5/apps/droidvm/downloads/tmp_ndkproot.zip -O tmp_ndkproot.zip
unzip -o tmp_ndkproot.zip
chmod 777 -R *
export PATH=${PROOT_BINARY_DIR}:$PATH

# proot --bind=/data/data/com.termux/files/usr --bind=/linkerconfig/com.android.art/ld.config.txt --bind=/linkerconfig/ld.config.txt --bind=/vendor --bind=/system_ext --bind=/system --bind=/product --bind=/odm --bind=/apex --bind=/storage/self/primary:/storage/self/primary --bind=/storage/self/primary:/storage/emulated/0 --bind=/storage/self/primary:/sdcard --bind=/data/data/com.termux/files/home --bind=/data/data/com.termux/cache --bind=/data/dalvik-cache --bind=/data/app --bind=/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/ubuntu/tmp:/dev/shm --bind=/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/ubuntu/proc/.sysctl_entry_cap_last_cap:/proc/sys/kernel/cap_last_cap --bind=/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/ubuntu/proc/.vmstat:/proc/vmstat --bind=/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/ubuntu/proc/.version:/proc/version --bind=/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/ubuntu/proc/.uptime:/proc/uptime --bind=/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/ubuntu/proc/.stat:/proc/stat --bind=/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/ubuntu/proc/.loadavg:/proc/loadavg --bind=/sys --bind=/proc/self/fd/2:/dev/stderr --bind=/proc/self/fd/1:/dev/stdout --bind=/proc/self/fd/0:/dev/stdin --bind=/proc/self/fd:/dev/fd --bind=/proc --bind=/dev/urandom:/dev/random --bind=/dev -L --kernel-release=6.2.1-PRoot-Distro --sysvipc --link2symlink --kill-on-exit --cwd=/root --change-id=0:0 --rootfs=/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/ubuntu /usr/bin/env -i PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/games:/usr/games:/data/data/com.termux/files/usr/bin:/system/bin:/system/xbin ANDROID_ART_ROOT=/apex/com.android.art ANDROID_DATA=/data ANDROID_I18N_ROOT=/apex/com.android.i18n ANDROID_ROOT=/system ANDROID_TZDATA_ROOT=/apex/com.android.tzdata BOOTCLASSPATH=/apex/com.android.art/javalib/core-oj.jar:/apex/com.android.art/javalib/core-libart.jar:/apex/com.android.art/javalib/okhttp.jar:/apex/com.android.art/javalib/bouncycastle.jar:/apex/com.android.art/javalib/apache-xml.jar:/system/framework/framework.jar:/system/framework/framework-graphics.jar:/system/framework/ext.jar:/system/framework/telephony-common.jar:/system/framework/voip-common.jar:/system/framework/ims-common.jar:/apex/com.android.i18n/javalib/core-icu4j.jar:/system/framework/mediatek-telephony-base.jar:/system/framework/mediatek-telephony-common.jar:/system/framework/mediatek-common.jar:/system/framework/mediatek-framework.jar:/system/framework/mediatek-ims-common.jar:/system/framework/mediatek-ims-base.jar:/system/framework/mediatek-telecom-common.jar:/system/framework/oplus-framework.jar:/system/framework/oplus-support-wrapper.jar:/system/framework/ifaamanager.jar:/system/framework/com.android.fmradio.jar:/system/framework/oplus-framework-telephony.jar:/apex/com.android.appsearch/javalib/framework-appsearch.jar:/apex/com.android.conscrypt/javalib/conscrypt.jar:/apex/com.android.ipsec/javalib/android.net.ipsec.ike.jar:/apex/com.android.media/javalib/updatable-media.jar:/apex/com.android.mediaprovider/javalib/framework-mediaprovider.jar:/apex/com.android.os.statsd/javalib/framework-statsd.jar:/apex/com.android.permission/javalib/framework-permission.jar:/apex/com.android.permission/javalib/framework-permission-s.jar:/apex/com.android.scheduling/javalib/framework-scheduling.jar:/apex/com.android.sdkext/javalib/framework-sdkextensions.jar:/apex/com.android.tethering/javalib/framework-connectivity.jar:/apex/com.android.tethering/javalib/framework-tethering.jar:/apex/com.android.wifi/javalib/framework-wifi.jar DEX2OATBOOTCLASSPATH=/apex/com.android.art/javalib/core-oj.jar:/apex/com.android.art/javalib/core-libart.jar:/apex/com.android.art/javalib/okhttp.jar:/apex/com.android.art/javalib/bouncycastle.jar:/apex/com.android.art/javalib/apache-xml.jar:/system/framework/framework.jar:/system/framework/framework-graphics.jar:/system/framework/ext.jar:/system/framework/telephony-common.jar:/system/framework/voip-common.jar:/system/framework/ims-common.jar:/apex/com.android.i18n/javalib/core-icu4j.jar:/system/framework/mediatek-telephony-base.jar:/system/framework/mediatek-telephony-common.jar:/system/framework/mediatek-common.jar:/system/framework/mediatek-framework.jar:/system/framework/mediatek-ims-common.jar:/system/framework/mediatek-ims-base.jar:/system/framework/mediatek-telecom-common.jar:/system/framework/oplus-framework.jar:/system/framework/oplus-support-wrapper.jar:/system/framework/ifaamanager.jar:/system/framework/com.android.fmradio.jar:/system/framework/oplus-framework-telephony.jar EXTERNAL_STORAGE=/sdcard PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin ANDROID_ART_ROOT=/apex/com.android.art ANDROID_DATA=/data ANDROID_I18N_ROOT=/apex/com.android.i18n ANDROID_ROOT=/system ANDROID_TZDATA_ROOT=/apex/com.android.tzdata BOOTCLASSPATH=/apex/com.android.art/javalib/core-oj.jar:/apex/com.android.art/javalib/core-libart.jar:/apex/com.android.art/javalib/okhttp.jar:/apex/com.android.art/javalib/bouncycastle.jar:/apex/com.android.art/javalib/apache-xml.jar:/system/framework/framework.jar:/system/framework/framework-graphics.jar:/system/framework/ext.jar:/system/framework/telephony-common.jar:/system/framework/voip-common.jar:/system/framework/ims-common.jar:/apex/com.android.i18n/javalib/core-icu4j.jar:/system/framework/mediatek-telephony-base.jar:/system/framework/mediatek-telephony-common.jar:/system/framework/mediatek-common.jar:/system/framework/mediatek-framework.jar:/system/framework/mediatek-ims-common.jar:/system/framework/mediatek-ims-base.jar:/system/framework/mediatek-telecom-common.jar:/system/framework/oplus-framework.jar:/system/framework/oplus-support-wrapper.jar:/system/framework/ifaamanager.jar:/system/framework/com.android.fmradio.jar:/system/framework/oplus-framework-telephony.jar:/apex/com.android.appsearch/javalib/framework-appsearch.jar:/apex/com.android.conscrypt/javalib/conscrypt.jar:/apex/com.android.ipsec/javalib/android.net.ipsec.ike.jar:/apex/com.android.media/javalib/updatable-media.jar:/apex/com.android.mediaprovider/javalib/framework-mediaprovider.jar:/apex/com.android.os.statsd/javalib/framework-statsd.jar:/apex/com.android.permission/javalib/framework-permission.jar:/apex/com.android.permission/javalib/framework-permission-s.jar:/apex/com.android.scheduling/javalib/framework-scheduling.jar:/apex/com.android.sdkext/javalib/framework-sdkextensions.jar:/apex/com.android.tethering/javalib/framework-connectivity.jar:/apex/com.android.tethering/javalib/framework-tethering.jar:/apex/com.android.wifi/javalib/framework-wifi.jar COLORTERM=truecolor DEX2OATBOOTCLASSPATH=/apex/com.android.art/javalib/core-oj.jar:/apex/com.android.art/javalib/core-libart.jar:/apex/com.android.art/javalib/okhttp.jar:/apex/com.android.art/javalib/bouncycastle.jar:/apex/com.android.art/javalib/apache-xml.jar:/system/framework/framework.jar:/system/framework/framework-graphics.jar:/system/framework/ext.jar:/system/framework/telephony-common.jar:/system/framework/voip-common.jar:/system/framework/ims-common.jar:/apex/com.android.i18n/javalib/core-icu4j.jar:/system/framework/mediatek-telephony-base.jar:/system/framework/mediatek-telephony-common.jar:/system/framework/mediatek-common.jar:/system/framework/mediatek-framework.jar:/system/framework/mediatek-ims-common.jar:/system/framework/mediatek-ims-base.jar:/system/framework/mediatek-telecom-common.jar:/system/framework/oplus-framework.jar:/system/framework/oplus-support-wrapper.jar:/system/framework/ifaamanager.jar:/system/framework/com.android.fmradio.jar:/system/framework/oplus-framework-telephony.jar EXTERNAL_STORAGE=/sdcard LANG=en_US.UTF-8 MOZ_FAKE_NO_SANDBOX=1 PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/games:/usr/games:/data/data/com.termux/files/usr/bin:/system/bin:/system/xbin PULSE_SERVER=127.0.0.1 TERM=xterm-256color TMPDIR=/tmp COLORTERM=truecolor HOME=/root USER=root TERM=xterm-256color /bin/bash -l




LINUX_DIR=/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/ubuntu 

    unset LD_PRELOAD
    command="${PROOT_BINARY_DIR}/proot"
    command+=" --link2symlink"
    command+=" --kill-on-exit"
    command+=" -0"
    # command+=" --change-id=999:999"
    command+=" -r $LINUX_DIR"
            command+=" --sysvipc"
    command+=" -b /apex"
    command+=" -b /linkerconfig"
    command+=" -b /system -b /dev -b /:/host-rootfs"
    command+=" -b /dev/urandom:/dev/random"
    command+=" -b /dev"
    command+=" -b /proc"
    command+=" -b /proc/self/fd:/dev/fd"
    command+=" -b /proc/self/fd/0:/dev/stdin"
    command+=" -b /proc/self/fd/1:/dev/stdout"
    command+=" -b /proc/self/fd/2:/dev/stderr"

	# export LINUX_FAKE_PROC_DIR=/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/ubuntu/proc
    command+=" -b ${LINUX_FAKE_PROC_DIR}/.loadavg:/proc/loadavg"
    command+=" -b ${LINUX_FAKE_PROC_DIR}/.stat:/proc/stat"
    command+=" -b ${LINUX_FAKE_PROC_DIR}/.uptime:/proc/uptime"
    command+=" -b ${LINUX_FAKE_PROC_DIR}/.version:/proc/version"
    command+=" -b ${LINUX_FAKE_PROC_DIR}/.vmstat:/proc/vmstat"
    # command+=" -b ${LINUX_FAKE_PROC_DIR}/mounts:/proc/self/mounts"
    command+=" -b /sys"
    command+=" -b $PROOT_TMP_DIR:/dev/shm"
    # command+=" -b $app_home:/exbin"
    # command+=" -b /system/fonts:/usr/share/fonts/truetype/droid"




    # command+=" --bind=/data/data/com.termux/files/usr "
    command+=" -b $PROOT_TMP_DIR:/data/data/com.termux/files/usr "

    # command+=" --bind=/linkerconfig/com.android.art/ld.config.txt "
    # command+=" --bind=/linkerconfig/ld.config.txt "

    # command+=" --bind=/vendor "
    # command+=" --bind=/system_ext "
    # command+=" --bind=/system "
    # command+=" --bind=/product "
    # command+=" --bind=/odm "
    # command+=" --bind=/apex "

    # command+=" --bind=/storage/self/primary:/storage/self/primary "
    # command+=" --bind=/storage/self/primary:/storage/emulated/0 "
    # command+=" --bind=/storage/self/primary:/sdcard "
    # command+=" --bind=/data/data/com.termux/files/home "
    # command+=" --bind=/data/data/com.termux/cache "
    # command+=" --bind=/data/dalvik-cache "
    # command+=" --bind=/data/app "
    # command+=" --bind=/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/ubuntu/tmp:/dev/shm "




    command+=" -b /sdcard"
    command+=" -w /root"
    command+=" /usr/bin/env -i"
    command+=" HOME=/root"
    command+=" TMPDIR=/tmp"
    command+=" PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games:/exbin"
    command+=" TERM=vt100"	#不同的终端类型支持不同的功能，比如：终端文字着色，光标随意定位。。。，不设置的话不能在终端中运行 reset 指令
    command+=" LANG=C.UTF-8"
    command+=" bash"
    $command 2>&1


: '

这是注释

wget http://192.168.1.5/apps/droidvm/downloads/setup_for_termux.sh -q -O setup_for_termux.sh
chmod 755 setup_for_termux.sh
./setup_for_termux.sh

export DOTNET_ROOT=$PATH:/opt/apps/dotnet
export PATH=$PATH:/opt/apps/dotnet
cd ~/cstest && dotnet run

dotnet --version  #测试能否运行


#测试创建一个C#项目:
cd ~
mkdir cstest
cd cstest
dotnet new console

# 运行此C#项目:
cd ~/cstest
dotnet run

'

