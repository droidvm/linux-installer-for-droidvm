#!/bin/bash

: '
    # ls -al /usr/share/icons/default/index.theme
    # ls -al /etc/alternatives/x-cursor-theme
    # ls -al /etc/X11/cursors/breeze_cursors.theme
    # ls -al /usr/share/icons/breeze_cursors/index.theme

    # 发现文件指向关系：
    # /usr/share/icons/default/index.theme -> /etc/alternatives/x-cursor-theme -> /etc/X11/cursors/breeze_cursors.theme

	# update-alternatives --display x-cursor-theme
    # 发现优先级关系：
    #     x-cursor-theme - 自动模式
    #     最佳链接版本为 /etc/X11/cursors/breeze_cursors.theme
    #     链接目前指向 /etc/X11/cursors/breeze_cursors.theme
    #     链接 x-cursor-theme 指向 /usr/share/icons/default/index.theme
    #     /etc/X11/cursors/Breeze_Snow.theme - 优先级 41
    #     /etc/X11/cursors/breeze_cursors.theme - 优先级 102
    #     /usr/share/icons/Adwaita/cursor.theme - 优先级 90

    sudo apt install breeze-cursor-theme

    # sudo apt install breeze-icon-theme breeze # breeze kde-style-breeze kwin-style-breeze
    # sudo apt install breeze-icon-theme breeze kde-style-breeze kwin-style-breeze 
    # ln -sf /usr/share/icons/breeze/index.theme /etc/alternatives/x-cursor-theme
    # ls -al /etc/alternatives/x-cursor-theme

	# update-alternatives --display x-cursor-theme
    # # sudo update-alternatives --install /usr/share/icons/default/index.theme x-cursor-theme /usr/share/icons/breeze/index.theme
    # # sudo update-alternatives --install /usr/share/icons/default/index.theme x-cursor-theme /usr/share/icons/breeze_cursors/index.theme 102
    # sudo update-alternatives --install /usr/share/icons/default/index.theme x-cursor-theme /etc/X11/cursors/breeze_cursors.theme 102
    # sudo update-alternatives --install /usr/share/icons/default/index.theme x-cursor-theme /etc/X11/cursors/Breeze_Snow.theme 41
    # sudo update-alternatives --set x-cursor-theme /usr/share/icons/breeze_cursors/index.theme
	# update-alternatives --display x-cursor-theme
	# update-alternatives --config x-cursor-theme
	# sudo update-alternatives --set x-cursor-theme /usr/bin/${SWNAME}
	# sudo update-alternatives --remove x-cursor-theme /usr/bin/chromium-browser
    # sudo update-alternatives --remove x-cursor-theme /etc/X11/cursors/breeze_cursors.theme
    # sudo update-alternatives --remove-all x-cursor-theme

    # ls -al /usr/share/icons/default/index.theme

'

newsize=$1

if [ "${newsize}" == "" ]; then
    newsize=16
fi

case "${newsize}" in
    "16")
        mv -f /usr/share/icons/Adwaita/cursors /usr/share/icons/Adwaita/cursors.bak 2>/dev/null
        ;;
    *)
        bigpointer_installed=0
        if [ -d /usr/share/icons/Adwaita/cursors ]; then
            bigpointer_installed=1
        fi
        if [ -d /usr/share/icons/Adwaita/cursors.bak ]; then
            bigpointer_installed=1
        fi

        if [ ${bigpointer_installed} -eq 0 ]; then

			cat <<- EOF > /tmp/msg.txt
				请在桌面上的软件管家中安装
				打开软件管家后，点击 “修复类”
				安装 “大鼠标指针” 软件包
			EOF

            gxmessage -title "提示" -file /tmp/msg.txt -center

            exit 0
        else
            mv -f /usr/share/icons/Adwaita/cursors.bak /usr/share/icons/Adwaita/cursors 2>/dev/null
        fi
        
        ;;
esac

echo "鼠标指针已变更,正在重启图形界面"
# export force_copy_xconf_files=1
${tools_dir}/vm_startx.sh xserver
