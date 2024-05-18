
tmpfile=${ZZSWMGR_RMSH_DIR}/"卸载-"${pkgname}.sh
cat <<- EOF > ${tmpfile}
	#!/bin/bash
	# exec /usr/bin/code_ori ${ZZVM_ARGS} \$@
	sudo apt autoremove --purge -y              ${pkgname}
	sudo dpkg --remove --force-remove-reinstreq ${pkgname}
EOF
chmod 755 ${tmpfile}


新增软件参考:
alist.sh
motrix.sh
EGzip.sh
peazip.sh
