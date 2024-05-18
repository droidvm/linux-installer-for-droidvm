#!/bin/bash


# if [ ! -d ~/.wine64 ]; then
#     gxmessage -title "提示" "wine未安装或未初始化，不需要重置"  -center
#     exit 0
# fi


msg_header="重置wine将删除主目录下的.wine文件夹，
其中的文件将一同被删除，且不可恢复，

"
msg_footer="
"

gxmessage -title "请确认" "${msg_header}确定要将wine重置吗？${msg_footer}"  -center -buttons "确定:1,取消:0"
if [ $? -eq 1 ]; then
    rm -rf ~/.wine
    rm -rf ~/.wine32
    rm -rf ~/.wine64

	cd ${tools_dir}/zzswmgr
	pwd


	if [ "${APP_LANGUAGE}_${APP_COUNTRY}" == "zh_CN" ]; then
		echo "正在复制中文字体"

					mkdir -p /home/droidvm/.wine32/drive_c/windows/Fonts
					mkdir -p /home/droidvm/.wine64/drive_c/windows/Fonts
					cp -f /usr/share/fonts/truetype/wqy/wqy-microhei.ttc /home/droidvm/.wine32/drive_c/windows/Fonts/simsun.ttc
					cp -f /usr/share/fonts/truetype/wqy/wqy-microhei.ttc /home/droidvm/.wine64/drive_c/windows/Fonts/simsun.ttc

					# "Droid Sans Fallback" 或者 "Noto Sans Mono CJK SC", 或者 "WenQuanYi Micro Hei" 和 dpi
					cat <<- EOF >  ./tmp/wine_init_config.reg
					REGEDIT4
					[HKEY_CURRENT_USER\Software\Wine\Fonts\Replacements]
					"DFKai-SB"="WenQuanYi Micro Hei"
					"FangSong"="WenQuanYi Micro Hei"
					"KaiTi"="WenQuanYi Micro Hei"
					"Microsoft JhengHei"="WenQuanYi Micro Hei"
					"Microsoft YaHei"="WenQuanYi Micro Hei"
					"MingLiU"="WenQuanYi Micro Hei"
					"SimSun"="WenQuanYi Micro Hei"
					"PMingLiU"="WenQuanYi Micro Hei"
					"SimHei"="WenQuanYi Micro Hei"
					"SimKai"="WenQuanYi Micro Hei"
					"SimSun"="WenQuanYi Micro Hei"


					[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\FontLink\SystemLink]
					"Lucida Sans Unicode"="WenQuanYi Micro Hei"
					"Microsoft Sans Serif"="WenQuanYi Micro Hei"
					"MS Sans Serif"="WenQuanYi Micro Hei"
					"Tahoma"="WenQuanYi Micro Hei"
					"Tahoma Bold"="WenQuanYi Micro Hei"
					"SimSun"="WenQuanYi Micro Hei"
					"Arial"="WenQuanYi Micro Hei"
					"Arial Black"="WenQuanYi Micro Hei"
					

					[HKEY_LOCAL_MACHINE\System\CurrentControlSet\Hardware Profiles\Current\Software\Fonts]
					"LogPixels"=dword:00000096
					EOF

		cp -f  ./tmp/wine_init_config.reg /home/droidvm/.wine32/drive_c/wine_init_config.reg
		cp -f  ./tmp/wine_init_config.reg /home/droidvm/.wine64/drive_c/wine_init_config.reg
		sudo -u droidvm exec32 regedit ./tmp/wine_init_config.reg
		exit_if_fail $? "wine32 中文字体导入失败"

		sudo -u droidvm exec64 regedit ./tmp/wine_init_config.reg
		exit_if_fail $? "wine64 中文字体导入失败"

		rm -rf ./tmp/wine_init_config.reg
	else
		echo "非中文语言"

		# 调整dpi
		cat <<- EOF >  ./tmp/wine_init_config.reg
		REGEDIT4
		[HKEY_LOCAL_MACHINE\System\CurrentControlSet\Hardware Profiles\Current\Software\Fonts]
		"LogPixels"=dword:00000096
		EOF
		cp -f  ./tmp/wine_init_config.reg /home/droidvm/.wine32/drive_c/wine_init_config.reg
		cp -f  ./tmp/wine_init_config.reg /home/droidvm/.wine64/drive_c/wine_init_config.reg
		sudo -u droidvm exec32 regedit ./tmp/wine_init_config.reg
		exit_if_fail $? "wine32 dpi设置失败"

		sudo -u droidvm exec64 regedit ./tmp/wine_init_config.reg
		exit_if_fail $? "wine64 dpi设置失败"

		rm -rf ./tmp/wine_init_config.reg
	fi


    gxmessage -title "提示" "wine已重置"  -center
fi
