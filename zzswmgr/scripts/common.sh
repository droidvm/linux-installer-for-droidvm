#!/bin/bash

export ZZSWMGR_MAIN_DIR=`pwd`
export ZZSWMGR_TEMP_DIR=${ZZSWMGR_MAIN_DIR}/tmp
# export ZZSWMGR_RMSH_DIR="${ZZSWMGR_MAIN_DIR}/rm-scripts"
export ZZSWMGR_APPI_DIR=/opt/apps
export ZZ_ENV=WSL


. /etc/profile
cd ${ZZSWMGR_MAIN_DIR}

tmp_username=`cat ./tmp/whoami.txt`
if [ "${tmp_username}" == "" ]; then
  tmp_username=droidvm
fi
export ZZ_USER_NAME=${tmp_username}
export ZZ_USER_HOME=/home/${tmp_username}

# echo "APP_FILENAME_URLDLSERVER: ${APP_FILENAME_URLDLSERVER}"
if [ -f "${APP_FILENAME_URLDLSERVER}" ]; then
  . ${APP_FILENAME_URLDLSERVER}
fi

# if [ -f "./scripts/display.sh" ]; then
#   . ./scripts/display.sh
# fi
# echo "DISPLAY  环境变量为: |$DISPLAY|"


if [ -f "${app_home}/droidvm_vars.sh" ]; then
source ${app_home}/droidvm_vars.sh
fi
if [ -f "${tools_dir}/vm_config.sh" ]; then
source ${tools_dir}/vm_config.sh
fi

function exit_if_fail() {
    rlt_code=$1
    fail_msg=$2
    if [ $rlt_code -ne 0 ]; then
      echo -e "安装出错: 详细的错误信息请参考上面几行日志"
      echo -e "怎么处理: 升级软件管家后重试，若仍失败请将此部分日志截图并发到QQ交流群(群号：740164688)"
      echo -e "快捷加群: 开始->使用说明->加群"
      echo -e "错误代码: ${rlt_code}"
      echo -e "错误信息: ${fail_msg}"
      echo -e "容器版本: $APP_RELEASE_VERSION"
      # read -s -n1 -p "按任意键退出"
      exit $rlt_code
    fi
}

function exit_unsupport() {
  echo "不支持的CPU架构: ${CURRENT_VM_ARCH}"
  exit 2
}

function mkzzdir() {
  [ -d ${ZZSWMGR_APPI_DIR} ] || mkdir -p ${ZZSWMGR_APPI_DIR}

  # [ -d ${ZZSWMGR_RMSH_DIR} ] || mkdir -p ${ZZSWMGR_RMSH_DIR}

  [ -d ${ZZSWMGR_TEMP_DIR} ] || mkdir -p ${ZZSWMGR_TEMP_DIR}
  chmod 777 ${ZZSWMGR_TEMP_DIR}
}

# aria2c 不稳定，经常有下载失败的情况发生，准备换成 axel， sudo apt install axel

function download_file_axel() {
  filesaveto=$1
  url=$2
  echo "正在下载：${url}"
  tmp_wdir=`pwd`
  echo "工作目录：${tmp_wdir}"
  echo "保存路径：${filesaveto}"
  if [ -f ${filesaveto}.downloading ]; then echo "上次未完整下载，正在删除临时文件后重新下载"; rm -rf ${filesaveto}; else touch ${filesaveto}.downloading ;fi
  [ -f ${filesaveto} ] || axel -n 10 -o "${filesaveto}" "${url}"
  rlt_code=$?
  if [ $rlt_code -ne 0 ]; then
    rm -rf "${filesaveto}"
  fi
  rm -rf ${filesaveto}.downloading

  return ${rlt_code}
}

function download_file_aria2c() {
  filesaveto=$1
  url=$2
  echo "正在下载：${url}"
  tmp_wdir=`pwd`
  echo "工作目录：${tmp_wdir}"
  echo "保存路径：${filesaveto}"
  if [ -f ${filesaveto}.downloading ]; then echo "上次未完整下载，正在删除临时文件后重新下载"; rm -rf ${filesaveto}; else touch ${filesaveto}.downloading ;fi
  [ -f ${filesaveto} ] || aria2c --console-log-level=warn --no-conf --allow-overwrite=true -s 5 -x 5 -k 1M -o "${filesaveto}" "${url}"
  rlt_code=$?
  if [ $rlt_code -ne 0 ]; then
    rm -rf "${filesaveto}" 2>/dev/null
  fi
  rm -rf ${filesaveto}.downloading

  return ${rlt_code}
}

function download_file1() {
  filesaveto=$1
  url=$2
  echo "正在下载：${url}"
  tmp_wdir=`pwd`
  echo "工作目录：${tmp_wdir}"
  echo "保存路径：${filesaveto}"
  if [ -f ${filesaveto}.downloading ]; then echo "上次未完整下载，正在删除临时文件后重新下载"; rm -rf ${filesaveto}; else touch ${filesaveto}.downloading ;fi
	[ -f ${filesaveto} ] || /usr/lib/apt/apt-helper download-file ${url} ${filesaveto}
  rlt_code=$?
  if [ $rlt_code -ne 0 ]; then
    rm -rf "${filesaveto}" 2>/dev/null
  fi
  rm -rf ${filesaveto}.downloading

  return ${rlt_code}
}

function download_file2() {
  filesaveto=$1
  url=$2
  echo "正在下载：${url}"
  tmp_wdir=`pwd`
  echo "工作目录：${tmp_wdir}"
  echo "保存路径：${filesaveto}"
  if [ -f ${filesaveto}.downloading ]; then echo "上次未完整下载，正在删除临时文件后重新下载"; rm -rf ${filesaveto}; else touch ${filesaveto}.downloading ;fi
	[ -f ${filesaveto} ] || wget ${url} -O ${filesaveto}
  rlt_code=$?
  if [ $rlt_code -ne 0 ]; then
    rm -rf "${filesaveto}" 2>/dev/null
  fi
  rm -rf ${filesaveto}.downloading

  return ${rlt_code}
}

function download_file3() {
  filesaveto=$1
  url=$2
  echo "正在克隆：${url}"
  tmp_wdir=`pwd`
  echo "工作目录：${tmp_wdir}"
  echo "保存路径：${filesaveto}"
  if [ -f ${filesaveto}.downloading ]; then echo "上次未完整下载，正在删除临时文件后重新下载"; rm -rf ${filesaveto}; else touch ${filesaveto}.downloading ;fi
  [ -d ${filesaveto} ] || git clone ${swUrl} ${filesaveto}
  rlt_code=$?
  if [ $rlt_code -ne 0 ]; then
    rm -rf "${filesaveto}" 2>/dev/null
  fi
  rm -rf ${filesaveto}.downloading

  return ${rlt_code}
}

function getfullpath ()
{
	local dir=$(dirname $1)
	local base=$(basename $1)
	if test -d ${dir}; then
		pushd ${dir} >/dev/null 2>&1
		echo ${PWD}/${base}
		popd >/dev/null 2>&1
		return 0
	fi
	return 1
}

function get_debfile_pkgname() {
  fullpath=$1
  checkpkgname=1
  which dpkg-deb >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    checkpkgname=0
  fi
  which gxmessage >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    checkpkgname=0
  fi
  if [ $checkpkgname -eq 1 ]; then
      pkgname=`dpkg-deb -f ${fullpath} Package`
      echo $pkgname
  else
      echo "unknown"
  fi

  return 0
}

function deprecated_generate_uninstall_scriptfile() {
  pkgname=$1
  if [ "${pkgname}" == "" ]; then
    return 1
  fi

  tmpfile=${ZZSWMGR_RMSH_DIR}/"卸载-"${pkgname}.sh
	cat <<- EOF > ${tmpfile}
		#!/bin/bash
		# exec /usr/bin/code_ori ${ZZVM_ARGS} \$@
    sudo apt autoremove --purge -y              ${pkgname}
    sudo dpkg --remove --force-remove-reinstreq ${pkgname}
	EOF
	chmod 755 ${tmpfile}
}

function get_debfile_cpu_arch() {
  fullpath=$1
  debarch="unknown"
  which dpkg-deb >/dev/null 2>&1
  if [ $? -eq 0 ]; then
      debarch=`dpkg-deb --info ${fullpath}|grep Architecture|cut -c 16-`
  fi
  echo $debarch
}

function issame_cpu_arch() {
  fullpath=$1
  checkdebarch=1
  which dpkg-deb >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    checkdebarch=0
  fi
  which gxmessage >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    checkdebarch=0
  fi
  if [ $checkdebarch -eq 1 ]; then
      debarch=`dpkg-deb --info ${fullpath}|grep Architecture|cut -c 16-`
      if [ "${debarch}" == "all" ]; then
        return 0
      fi
      if [ "${debarch}" != "${CURRENT_VM_ARCH}" ]; then
        return 1
      fi
  fi

  return 0
}

function install_deb() {
  # 也可以使用gdebi
  # DEBs=$@
  DEBs=""
  for arg in $*                                          
  do
    fullpath=`getfullpath $arg`
    issame_cpu_arch "${fullpath}"
    if [ $? -ne 0 ]; then
        mkdir -p ./tmp 2>/dev/null
				cat <<- EOF > ./tmp/msg.txt
					==========================================================
					此安装包适用的CPU架构为：${debarch}
					但是虚拟系统的CPU架构为：${CURRENT_VM_ARCH}

					安装包的CPU架构不匹配，安装完可能也启动不了，是否继续安装？
					==========================================================
				EOF

          gxmessage -title "警告" -file ./tmp/msg.txt -center -buttons "继续安装:0,取消安装:1"
          case "$?" in
            "1")
              return -1
              ;;
            *)
              echo
              ;;
          esac
    fi

    DEBs+=" $fullpath"
  done

  echo "install_deb ${DEBs}"
  # sudo apt-get install -y --allow-downgrades ${DEBs} || sudo dpkg -i ${DEBs}
  sudo dpkg -i ${DEBs} || sudo apt-get install -y --allow-downgrades ${DEBs}
  rlt_code=$?
  if [ $rlt_code -ne 0 ]; then
    sudo apt-get --fix-broken install -y
    exit_if_fail $? "安装失败, fail to apt-get --fix-broken install -y"
    sudo dpkg -i ${DEBs} || sudo apt-get install -y ${DEBs}
    rlt_code=$?
    return ${rlt_code}
  fi
  return ${rlt_code}
}

function cp2desktop() {
  src_fil=$1

  for file in `ls /home`
  do
    dst_dir=/home/${file}/Desktop/
    if [ -d "${dst_dir}" ]; then
      cp -f ${src_fil} ${dst_dir}
    fi
  done
}

function rm2desktop() {
  src_fil=$1

  # # basename 对星号的支持度有限，只会匹配第一个文件名 "*"!
  # src_fil=`basename $1`

  # 不能加双引号
  for file in `ls /home`
  do
    # echo "rm -rf /home/${file}/Desktop/${src_fil}"
    rm -rf /home/${file}/Desktop/${src_fil}
  done

  # echo "rm -rf /usr/share/applications/${src_fil}"
  rm -rf /usr/share/applications/${src_fil}
}

function detect_env() {
  uname -a|grep WSL
  if [ $? -eq 0 ]; then
    export ZZ_ENV=WSL
    return
  fi

  if [ -f /exbin/droidvm_main.sh ]; then
    export ZZ_ENV=DROIDVM
    return
  fi

  export ZZ_ENV=LINUX
}

function get_box64_fullpath() {
  ZZ_BOX64_FULLPATH=`which box64`
  echo "${ZZ_BOX64_FULLPATH} "
}

function zz_enable_src_apt() {

  if [ "${LINUX_DISTRIBUTION}" == "ubuntu" ]; then
		if [ "${CURRENT_VM_ARCH}" == "arm64" ]; then
			sudo cat <<- EOF > /etc/apt/sources.list.d/sourcecode.list
			# 默认注释了源码仓库，如有需要可自行取消注释 【 注意：这是arm64架构的apt仓库!! 】
			deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${LINUXVersionName} main restricted universe multiverse
			deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${LINUXVersionName}-updates main restricted universe multiverse
			deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${LINUXVersionName}-backports main restricted universe multiverse

			# deb https://mirrors.ustc.edu.cn/ubuntu-ports/ ${LINUXVersionName} main restricted universe multiverse
			# deb-src https://mirrors.ustc.edu.cn/ubuntu-ports/ ${LINUXVersionName} main main restricted universe multiverse
			# deb https://mirrors.ustc.edu.cn/ubuntu-ports/ ${LINUXVersionName}-updates main restricted universe multiverse
			# deb-src https://mirrors.ustc.edu.cn/ubuntu-ports/ ${LINUXVersionName}-updates main restricted universe multiverse
			# deb https://mirrors.ustc.edu.cn/ubuntu-ports/ ${LINUXVersionName}-backports main restricted universe multiverse
			# deb-src https://mirrors.ustc.edu.cn/ubuntu-ports/ ${LINUXVersionName}-backports main restricted universe multiverse
			# deb https://mirrors.ustc.edu.cn/ubuntu-ports/ ${LINUXVersionName}-security main restricted universe multiverse
			# deb-src https://mirrors.ustc.edu.cn/ubuntu-ports/ ${LINUXVersionName}-security main restricted universe multiverse
			# # 预发布软件源，不建议启用
			# # deb https://mirrors.ustc.edu.cn/ubuntu-ports/ ${LINUXVersionName}-proposed main restricted universe multiverse
			# deb-src https://mirrors.ustc.edu.cn/ubuntu-ports/ ${LINUXVersionName}-proposed main restricted universe multiverse
			EOF
		else
			# jammy 版本收录的tigervnc版本跟 kinetic 收录的版本是相同的
			sudo cat <<- EOF > /etc/apt/sources.list.d/sourcecode.list
			deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${LINUXVersionName} main restricted universe multiverse
			deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${LINUXVersionName} main restricted universe multiverse
			deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${LINUXVersionName}-updates main restricted universe multiverse
			deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${LINUXVersionName}-updates main restricted universe multiverse
			deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${LINUXVersionName}-backports main restricted universe multiverse
			deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${LINUXVersionName}-backports main restricted universe multiverse
			deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${LINUXVersionName}-security main restricted universe multiverse
			deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${LINUXVersionName}-security main restricted universe multiverse

			# 预发布软件源，不建议启用
			# deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${LINUXVersionName}-proposed main restricted universe multiverse
			# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${LINUXVersionName}-proposed main restricted universe multiverse
			EOF
		fi
  elif [ "${LINUX_DISTRIBUTION}" == "debian" ]; then
			sudo cat <<- EOF > /etc/apt/sources.list.d/sourcecode.list
			deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ ${LINUXVersionName} main contrib non-free non-free-firmware
			deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ ${LINUXVersionName}-updates main contrib non-free non-free-firmware
			deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ ${LINUXVersionName}-backports main contrib non-free non-free-firmware
			deb-src https://security.debian.org/debian-security ${LINUXVersionName}-security main contrib non-free non-free-firmware
			EOF
  fi

	sudo apt-get update
}

function zz_remove_src_apt() {
  rm -rf /etc/apt/sources.list.d/sourcecode.list
}

function get_rootfs_codename() {
	# echo "LINUX_ROOTFS_VER: $LINUX_ROOTFS_VER"
  RLT=`lsb_release -c 2>/dev/null|grep name| cut -b 11-`
  echo ${RLT}
}

function zzsnap() {
  # https://github.com/dstettler/snap-to-deb
  pkgname=p7zip-desktop
  
  echo "正在从snap仓库下载 ${pkgname}"
  snap download --target-directory ./downloads/ $pkgname

  echo "正在解压 ${pkgname}"
	pkgpath="./downloads/"`ls -a ./downloads/|grep snap\$|grep ${pkgname}|tail -n 1`
  echo $pkgpath
  unz_dir="./tmp/unz_$pkgname"
  mkdir -p "$unz_dir" 2>/dev/null
  unsquashfs -f -d "$unz_dir" "${pkgpath}"

  echo "正在打包为 ${pkgname}.deb"
  pkg_dir="./tmp/deb_${pkgname}"
	mkdir -p "${pkg_dir}/usr/bin"
	mkdir -p "${pkg_dir}/usr/share/applications"
	mkdir -p "${pkg_dir}/usr/share/pixmaps"
	mkdir -p "${pkg_dir}/opt/${pkgname}"

  cp -rf "${$unz_dir}/*"            "${pkg_dir}/opt/${pkgname}/"
  # cp "${_iconloc}"                "${pkg_dir}/usr/share/pixmaps/authy.png"
	# cp "pkgs/${pkgname}/${desktop}" "${pkgname}/usr/share/applications"
	cp -rf "pkgs/${pkgname}/DEBIAN" "./${pkgname}"
	chmod 755 "${pkgname}/DEBIAN/postinst"
	chmod 755 "${pkgname}/DEBIAN/postrm"

  # 每个包都要自己整理 postinst、postrm ，这就麻烦了。。。


}

function zzget() {
	tmpUrl=$1
	wget -nc $tmpUrl
	exit_if_fail $? "下载失败，网址：${tmpUrl}"
}

mkzzdir
detect_env
export ROOTFS_CODENAME=`get_rootfs_codename`
cd ${ZZSWMGR_MAIN_DIR}


# if [ "$action" != "卸载" ]; then
#   apt-get update
# fi
