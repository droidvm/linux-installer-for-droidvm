#!/bin/bash

insdeb=$1

. ./scripts/common.sh


pkgname=`get_debfile_pkgname "${insdeb}"`
if [ "wps-office" == "${pkgname}" ]; then
	gxmessage -title "提示" $'\n此安装包中的wps不能直接安装\n请使用桌面上的 软件管家 安装wps\n\n' -center
	exit 5
fi

mkdir -p ${HOME}/.zzswmgr  2>/dev/null
pkgarch=`get_debfile_cpu_arch "${insdeb}"`
filepy=${HOME}/.zzswmgr/localdeb.py
filesw=${HOME}/.zzswmgr/localdeb.txt
fileod=${HOME}/.zzswmgr/localdeb.txt.old
filesh=./scripts/user-${pkgname}.sh

BOOL_ADD2PY_SCRIPT=0
if [ ! -f ${filesh} ]; then
	BOOL_ADD2PY_SCRIPT=1
fi

# 为这个安装包创建能被软件管家调用的安装脚本
cat << EOF > ${filesh}
#!/bin/bash

action=\$1
if [ "\$action" == "" ]; then action=安装; fi

. ./scripts/common.sh

if [ "\${action}" == "卸载" ]; then
	dpkg --remove --force-remove-reinstreq	${pkgname}	# 适用于无法完整安装的软件包
	apt-get autoremove --purge -y			${pkgname}	# 适用于已完整安装了的软件包
else
	install_deb "${insdeb}"
	exit_if_fail $? "安装失败，软件包：${insdeb}"

	gxmessage -title "提示" "安装已完成"  -center &

	exit 0
fi
EOF
chmod 755 ${filesh}

# 添加到软件管家的软件列表中，且总是后面添加的放在最前面
if [ ${BOOL_ADD2PY_SCRIPT} -ne 0 ]; then
	cat <<- EOF >  ${filesw}
		SoftWareList.append(
			SW( [SWGROUP.localdeb], [SWPROPS.sysdir],  [],
				"${pkgname}", "", "",
				"您下载的安装包\\n"
				"软件架构：${pkgarch}\\n"
				"软件路径：${insdeb}\\n"
				"\\n"
				"",
				"${filesh}",
				SWSOURCE.localdeb,
		))

	EOF
	if [ -f ${fileod} ]; then
		cat ${fileod} >> ${filesw}
	fi
	cp -f ${filesw} ${fileod}
fi

# 重新生成 localdeb. py脚本
strHeader="
from swgroups import SWGROUP
from swgroups import SWPROPS
from swgroups import SWSOURCE
from swgroups import SWARCH
from swgroups import SWOP
from softwares import SW
from softwares import SoftWareList

"
echo "${strHeader}"	>  ${filepy}
cat ${filesw}		>> ${filepy}







