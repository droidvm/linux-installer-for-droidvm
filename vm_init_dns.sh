#!/bin/bash

# 对proot不起作用，只能在启动时加 -k 参数来指定hostname!
# echo "droidvm" >     /etc/hostname
# export HOSTNAME=`cat /etc/hostname`
# hostname $HOSTNAME

function mkscripts() {
	cat <<- EOF > /exbin/vm_gen_dns_cache.sh
		#!/system/bin/sh

		currdir=\`pwd\`
		export PATH=\$PATH:\${currdir}/tools

        hostname2cache=""
        if [ \$# -ge 1 ]; then
			hostname2cache+=" \$@"
        else
 			echo ""         > ${APP_INTERNAL_DIR}/vm/${CURRENT_OS_NAME}${USER_DNS_CACHE}
			echo "# 生成的" >>${APP_INTERNAL_DIR}/vm/${CURRENT_OS_NAME}${USER_DNS_CACHE}

			hostname2cache+=" mirror.ghproxy.com"
			hostname2cache+=" playwright.azureedge.net"
			hostname2cache+=" home-store-packages.uniontech.com"
			hostname2cache+=" droidvmres-1316343437.cos.ap-shanghai.myqcloud.com"
			hostname2cache+=" gitee.com"
			hostname2cache+=" foruda.gitee.com"
			hostname2cache+=" mirrors.bfsu.edu.cn"
			hostname2cache+=" mirrors.ustc.edu.cn"
			hostname2cache+=" mirrors.tuna.tsinghua.edu.cn"
			hostname2cache+=" mirror.tuna.tsinghua.edu.cn"
			hostname2cache+=" security.debian.org"
			hostname2cache+=" deb.debian.org"
			hostname2cache+=" pypi.tuna.tsinghua.edu.cn"
			hostname2cache+=" mirrors.aliyun.com"
			hostname2cache+=" mirrors.cloud.tencent.com"
			hostname2cache+=" pypi.tuna.tsinghua.edu.cn"
			hostname2cache+=" archive.ubuntu.com"
			hostname2cache+=" ports.ubuntu.com"
			hostname2cache+=" security.ubuntu.com"
        fi
        # echo \$hostname2cache

        DNS_SERVER_LIST=\`cat ${APP_INTERNAL_DIR}/vm/${CURRENT_OS_NAME}/etc/resolv.conf |grep nameserver|cut -c 12-\`
        # echo \$DNS_SERVER_LIST

        function zz_gethostbyname() {
			DOMAIN_NAME=\$1
            OK2GET=0

            for DOMAIN_SERVER in \$DNS_SERVER_LIST
            do
                # echo \$DOMAIN_SERVER
                tmpres=\`busybox nslookup \${DOMAIN_NAME} \$DOMAIN_SERVER\`
                OK2GET=\$?
                if [ \$OK2GET -eq 0 ]; then
                    break
                fi
            done

            if [ \$OK2GET -ne 0 ]; then
                return \$OK2GET
            fi
            echo "\$tmpres"|tail -n +4|grep Address| \\
            awk -v FS=": " -v OFS="" -v header="" -v tail=" \${DOMAIN_NAME}" '{print header,\$2,tail}' \\
            >>${APP_INTERNAL_DIR}/vm/${CURRENT_OS_NAME}${USER_DNS_CACHE}
        }

        for hostname in \$hostname2cache
        do
            echo "正在解析：\$hostname"
            zz_gethostbyname \$hostname
            if [ \$? -ne 0 ]; then
                echo "解析失败：\$hostname"
                # rm -rf ${APP_INTERNAL_DIR}/vm/${CURRENT_OS_NAME}${USER_DNS_CACHE}
                # exit 1
            fi
        done
	    chmod 666 ${APP_INTERNAL_DIR}/vm/${CURRENT_OS_NAME}${USER_DNS_CACHE}

	EOF
	chmod a+x /exbin/vm_gen_dns_cache.sh

	cat <<- EOF > /exbin/vm_getHostByName.sh
		#!/system/bin/sh

		currdir=\`pwd\`
		export PATH=\$PATH:\${currdir}/tools

        hostname2cache=""
        if [ \$# -ge 1 ]; then
			hostname2cache+=" \$@"
        else
            exit 1
        fi
        # echo \$hostname2cache

        DNS_SERVER_LIST=\`cat ${APP_INTERNAL_DIR}/vm/${CURRENT_OS_NAME}/etc/resolv.conf |grep nameserver|cut -c 12-\`
        # echo \$DNS_SERVER_LIST

        function zz_gethostbyname() {
			DOMAIN_NAME=\$1
            OK2GET=0

            for DOMAIN_SERVER in \$DNS_SERVER_LIST
            do
                # echo \$DOMAIN_SERVER
                tmpres=\`busybox nslookup \${DOMAIN_NAME} \$DOMAIN_SERVER\`
                OK2GET=\$?
                if [ \$OK2GET -eq 0 ]; then
                    break
                fi
            done

            if [ \$OK2GET -ne 0 ]; then
                return \$OK2GET
            fi
            echo "\$tmpres"|tail -n +4|grep Address| \\
            awk -v FS=": " -v OFS="" -v header="" -v tail=" \${DOMAIN_NAME}" '{print header,\$2,tail}'
        }

        for hostname in \$hostname2cache
        do
            # echo "正在解析：\$hostname"
            zz_gethostbyname \$hostname
            if [ \$? -ne 0 ]; then
                exit 1
            fi
        done
        exit
	EOF
	chmod a+x /exbin/vm_getHostByName.sh
}

echo '正在配置虚拟系统中的 DNS 服务器列表 ...'
mkdir -p /run/systemd/resolve 2>/dev/null
mkdir -p /etc/systemd 2>/dev/null

touch /run/systemd/resolve/stub-resolv.conf
touch /etc/resolv.conf
chmod 644 /etc/resolv.conf

echo "" >/etc/resolv.conf
echo "# dns.google.com" >>/etc/resolv.conf
echo "nameserver 8.8.8.8" >>/etc/resolv.conf

# 获取安卓端dns，填到虚拟系统中
echo "" >>/etc/resolv.conf
echo "# copy form android side" >>/etc/resolv.conf
ip route list table 0|grep default|grep via|awk '{print "nameserver "$3}' >>/etc/resolv.conf
cat <<- EOF >> /etc/resolv.conf

	# others
	nameserver 223.5.5.5
	nameserver 223.6.6.6
	nameserver 2400:3200::1
	nameserver 2400:3200:baba::1
	nameserver 114.114.114.114
	nameserver 114.114.115.115
	nameserver 240c::6666
	nameserver 240c::6644

	options single-request-reopen
	options timeout:2
	options attempts:3
	options rotate
	options use-vc      # 走TCP
EOF

# 静态解析
cat <<- EOF > /etc/hosts
	# IPv4.
	127.0.0.1   localhost.localdomain localhost droidvm

	# IPv6.
	::1         localhost.localdomain localhost ip6-localhost ip6-loopback
	fe00::0     ip6-localnet
	ff00::0     ip6-mcastprefix
	ff02::1     ip6-allnodes
	ff02::2     ip6-allrouters
	ff02::3     ip6-allhosts
EOF


USER_DNS_CACHE=/etc/hosts.user
mkscripts

# rm -rf ${USER_DNS_CACHE}
if [ ! -f ${USER_DNS_CACHE} ]; then

    echo "正在安卓端生成dns缓存"
    cd /exbin && droidexec ./vm_gen_dns_cache.sh

	# cat <<- EOF >> /etc/hosts
	# 	# IPv4. add by droidvm

	# 	13.107.246.73   playwright.azureedge.net
	# 	112.74.190.222  home-store-packages.uniontech.com
	# 	112.86.231.46	droidvmres-1316343437.cos.ap-shanghai.myqcloud.com
	# 	180.76.198.77	gitee.com
	# 	180.76.198.77	foruda.gitee.com
	# 	39.155.141.16	mirrors.bfsu.edu.cn
	# 	218.104.71.170	mirrors.ustc.edu.cn
	# 	101.6.15.130	mirrors.tuna.tsinghua.edu.cn
	# 	185.125.190.36	ports.ubuntu.com
	# 	185.125.190.39	ports.ubuntu.com
	# 	91.189.91.82	security.ubuntu.com
	# 	91.189.91.81	security.ubuntu.com
	# 	185.125.190.36	security.ubuntu.com
	# 	185.125.190.39	security.ubuntu.com
	# 	91.189.91.83	security.ubuntu.com
	# 	151.101.2.132   security.debian.org
	# 	151.101.2.132        deb.debian.org
	# 	101.6.15.130    pypi.tuna.tsinghua.edu.cn
	# 	112.194.67.229  mirrors.aliyun.com
	# 	211.97.84.91    mirrors.cloud.tencent.com

	# 	# IPv6. add by droidvm
	# 	2402:f000:1:400::2				pypi.tuna.tsinghua.edu.cn
	# 	2402:f000:1:400::2				mirror.tuna.tsinghua.edu.cn
	# 	2620:2d:4000:1::16              archive.ubuntu.com
	# 	2408:8748:b500:214:3::3e5		mirrors.aliyun.com
	# 	# 2409:8700:2482:710::fe55:2840 mirrors.bfsu.edu.cn
	# 	# 2001:da8:d800:95::110         mirrors.ustc.edu.cn
	# 	# 2402:f000:1:400::2            mirrors.tuna.tsinghua.edu.cn
	# 	# 2620:2d:4000:1::16            ports.ubuntu.com
	# 	# 2620:2d:4000:1::19            security.ubuntu.com
	# EOF
fi # endof /etc/hosts.user

if [ -f ${USER_DNS_CACHE} ]; then
	cat ${USER_DNS_CACHE} >> /etc/hosts
fi


# 手动解析测试
# ==========================================
# dig droidvm.com
# nslookup droidvm.com
# nslookup droidvm.com 192.168.1.1 # 连接指定的DNS服务器: 192.168.1.1
# nslookup - 192.168.1.1           # 连接指定的DNS服务器: 192.168.1.1，交互模式
# strace -c ping -c 2 -n droidvm.com
# strace ping -c1 droidvm.com
# busybox nslookup bing.com 192.168.1.1     # 这个可能最实用
# busybox nslookup mirrors.tuna.tsinghua.edu.cn 192.168.1.1|tail -n -2
# ip route list table 0|grep default|grep via|awk '{print "nameserver "$3}'
# resolvconf

