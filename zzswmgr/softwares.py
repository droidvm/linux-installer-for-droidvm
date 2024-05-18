
from swgroups import SWGROUP
from swgroups import SWPROPS
from swgroups import SWSOURCE
from swgroups import SWARCH
from swgroups import SWOP

class SW(object):
    def __init__(self, groups, props, archs, name, version, timecost, info, script, dlsource):
        self.swop = SWOP.none
        self.straction = ""

        self.groups = groups
        self.props = props
        self.archs = archs
        self.name = name
        self.version = version
        self.timecost = timecost
        self.info = info
        self.script = script
        self.dlsource = dlsource

        self.deprecated = False
        self.recommend  = False

SoftWareList = []

# SoftWareList.append(
#     SW( [SWGROUP.input], [SWPROPS.sysdir], [SWARCH.arm64, SWARCH.amd64],
#         "安装本地deb包", 
#         "",
#         "",
#         "安装本地的deb安装包", 
#         "./scripts/debinstall.sh",
#         SWSOURCE.thirdpary,
# ))

SoftWareList.append(
    SW( [SWGROUP.dev], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "adb", 
        "",
        "",
        "adb是个命令行工具，但有很高的权限，不会用将非常危险！\n"
        "(可读取短信、联系人、电话拨打记录，安装应用。。。请！慎！用！)\n"
        "\n"
        "在虚拟电脑中主要用于\n"
        "1. 解除安卓对单个应用最多可启动进程数量的限制\n"
        "2. 通过usb数据线或者wifi网络控制、调试安卓设备\n"
        "3. 通过图形界面的方式控制安卓设备(scrcpy)\n"
        "\n"
        "安装完成后，adb指令可用，桌面有 解除进程数限制 的启动图标(ADBme)\n"
        "adb指令使用示例:\n"
        "adb pair    192.168.1.13\n"
        "adb connect 192.168.1.13:5555\n"
        "adb shell\n"
        "adb shell ls -al "
        "",
        "./scripts/adb.sh",
        SWSOURCE.aptrepo,
))

SoftWareList.append(
    SW( [SWGROUP.dev], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "scrcpy", 
        "",
        "",
        "scrcpy是常用的安卓远控软件\n"
        "",
        "./scripts/scrcpy.sh",
        SWSOURCE.aptrepo,
))



SoftWareList.append(
    SW( [SWGROUP.input, SWGROUP.none], [SWPROPS.sysdir], [SWARCH.arm64, SWARCH.amd64],
        "fcitx-table-wbpy", 
        "",
        "",
        "码表 简体中文输入法，包括五笔、拼音\n"
        "输入架构：fcitx4系列\n"
        "词库格式：.mb\n"
        "词库路径： ~/.config/fcitx/table(五笔)\n"
        "词库路径：/usr/share/fcitx/table\n"
        "词库路径：/usr/share/fcitx/pinyin(拼音)\n"
        "词库路径： ~/.config/fcitx/pinyin\n"
        "\n"
        "带拼音词库导入工具，支持无痛添加搜狗.scel拼音词库\n"
        "\n"
        "安装完成后，需要自己调整一下快捷键，步骤为：\n"
        "右下角输入法图标，右击(音量加键)，点配置", 
        "./scripts/fcitx.sh",
        SWSOURCE.aptrepo,
))
SoftWareList[-1].recommend = True

SoftWareList.append(
    SW( [SWGROUP.input], [SWPROPS.sysdir], [SWARCH.arm64, SWARCH.amd64],
        "fcitx5", 
        "",
        "",
        "linux标配简体中文输入法，包括五笔、拼音、仓颉。。。\n"
        "输入架构：fcitx5系列\n"
        "词库格式：.dict\n"
        "词库路径：/usr/share/libime(其中sc是简体拼音的词库)\n"
        "扩展词库：~/.local/share/fcitx5/pinyin/dictionaries(拼音)\n"
        "扩展词库：~/.local/share/fcitx5/table(五笔)\n"
        "\n"
        "带拼音词库导入工具，支持无痛添加搜狗.scel拼音词库\n"
        "\n"
        "此版输入法目前不支持在chrome中输入中文!\n"
        "\n"
        "安装完成后，需要自己调整一下快捷键，步骤为：\n"
        "右下角输入法图标，右击(音量加键)，点配置", 
        "./scripts/fcitx5.sh",
        SWSOURCE.aptrepo,
))
# SoftWareList[-1].deprecated = True



SoftWareList.append(
    SW( [SWGROUP.input], [SWPROPS.sysdir], [SWARCH.arm64, SWARCH.amd64],
        "紫光华宇拼音输入法", 
        "",
        "",
        "紫光华宇 简体中文拼音输入法, 官方linux信创版\n"
        "输入架构：fcitx4系列\n"
        "词库格式：.uwl\n"
        "词库路径：~/.config/fcitx-huayupy/wordlib\n"
        "\n"
        "此输入法在linux中添加扩展词库的步骤非常繁琐！\n"
        "此输入法在linux中添加扩展词库的步骤非常繁琐！\n"
        "此输入法在linux中添加扩展词库的步骤非常繁琐！\n"
        "此输入法在linux中添加扩展词库的步骤非常繁琐！\n"
        "此输入法在linux中添加扩展词库的步骤非常繁琐！\n"
        "\n"
        "安装完成后，需要自己调整一下快捷键，步骤为：\n"
        "右下角输入法图标，右击(音量加键)，点配置", 
        "./scripts/fcitx-huayuPY.sh",
        SWSOURCE.officialwebsite,
))

# SoftWareList.append(
#     SW( [SWGROUP.input], [], [SWARCH.arm64, SWARCH.amd64],
#         "搜狗拼音输入法", 
#         "",
#         "",
#         "搜狗拼音输入法, 官方linux原版，实测安装成功也无法在proot环境使用", 
#         "输入架构：fcitx4系列\n"
#         "./scripts/fcitx-sougou.sh",
#         SWSOURCE.officialwebsite,
# ))
## 已废弃
# SoftWareList[-1].deprecated = True

SoftWareList.append(
    SW( [SWGROUP.desktop], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "xfce4", 
        "",
        "",
        "xfce4 是一个常用的linux桌面环境,由多个软件组成", 
        "./scripts/xfce4.sh",
        SWSOURCE.aptrepo,
))

SoftWareList.append(
    SW( [SWGROUP.desktop], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "compton", 
        "",
        "",
        "compton 是个x11显示系统的混合层\n"
        "安装后可以实现窗体、菜单透明效果", 
        "./scripts/compton.sh",
        SWSOURCE.aptrepo,
))

SoftWareList.append(
    SW( [SWGROUP.desktop], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "windows10图标样式", 
        "",
        "",
        "windows10 图标样式\n"
        "软件官网：https://github.com/yeyushengfan258/We10X-icon-theme\n"
        "\n\n"
        "安装完成后，请依次点击：\n"
        " 开始使用->显示设置->显示风格->修改图标样式\n"
        "进行启用\n"
        "",
        "./scripts/windows10icon.sh",
        SWSOURCE.github,
))


SoftWareList.append(
    SW( [SWGROUP.desktop], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "breeze-cursor-theme", 
        "",
        "",
        "漂亮的鼠标指针样式\n"
        "",
        "./scripts/breeze-cursor-theme.sh",
        SWSOURCE.aptrepo,
))



SoftWareList.append(
    SW( [SWGROUP.internet, SWGROUP.none], [SWPROPS.sysdir],  [SWARCH.arm64],
        "chrome", 
        "112.0.5615.49",
        "约2分钟",
        "常用的网页浏览器，这版可以播放网页视频", 
        # "./scripts/chrome_for_1.25-le.sh",
        "./scripts/chrome.sh",
        SWSOURCE.aptrepo,
))

SoftWareList.append(
    SW( [SWGROUP.internet], [SWPROPS.sysdir],  [SWARCH.arm64],
        "chrome-爬虫版", 
        "",
        "约3分钟",
        "常用的网页浏览器，会同时安装 python、pip、playwright(爬虫)\n"
        "这版不能播放网页视频\n"
        "",
        "./scripts/chrome-pr.sh",
        SWSOURCE.pip,
))

SoftWareList.append(
    SW( [SWGROUP.internet], [SWPROPS.sysdir],  [SWARCH.arm64],
        "firefox-爬虫版", 
        "",
        "约3分钟",
        "常用的网页浏览器，会同时安装 python、pip、playwright(爬虫)\n"
        "这版不能使用输入法输入中文", 
        "./scripts/firefox-pr.sh",
        SWSOURCE.pip,
))

SoftWareList.append(
    SW( [SWGROUP.internet], [SWPROPS.sysdir],  [SWARCH.arm64],
        "basilisk", 
        "",
        "约1分钟",
        "网页浏览器，英文，部分机型用不了chrome的情况，可以安装此浏览器代替\n"
        "软件官网：https://www.basilisk-browser.org/",
        "./scripts/basilisk.sh",
        SWSOURCE.officialwebsite,
))

SoftWareList.append(
    SW( [SWGROUP.internet, SWGROUP.none], [SWPROPS.sysdir],  [SWARCH.arm64],
        "linuxQQ", 
        "3.2.5",
        "",
        "QQ是国内最流行的聊天工具之一\n"
        "软件官网：https://im.qq.com/linuxqq/index.shtml\n"
        "", 

        "./scripts/linuxQQ.sh",
        SWSOURCE.officialwebsite,
))

SoftWareList.append(
    SW( [SWGROUP.internet, SWGROUP.none], [SWPROPS.sysdir],  [SWARCH.arm64],
        "微信", 
        "2.1.9",
        "约4分钟",
        "微信是国内最流行的聊天工具之一\n"
        "软件官网：https://weixin.qq.com/\n"
        "因微信没公开发布linux版客户端，所以这里安装的是UOS版的", 

        "./scripts/linux-wechat-uos.sh",
        SWSOURCE.thirdpary,
))

# SoftWareList.append(
#     SW( [SWGROUP.internet], [SWPROPS.sysdir],  [SWARCH.arm64],
#         "钉钉", 
#         "7.1.0",
#         "约4分钟",
#         "钉钉linux版\n"
#         "软件官网：https://www.dingtalk.com/\n"
#         "", 

#         "./scripts/linuxDingTalk.sh",
#         SWSOURCE.thirdpary,
# ))

SoftWareList.append(
    SW( [SWGROUP.internet], [SWPROPS.sysdir],  [SWARCH.arm64],
        "electron", 
        # "28.1.3",
        "18.2.3",
        "",
        "electron是个基础运行库，有很多近年开发的跨平台软件都是基于electron开发的\n"
        "软件官网：https://www.electronjs.org/zh/\n"
        "镜像站点：https://registry.npmmirror.com/binary.html?path=electron/v28.1.3/\n"
        "", 

        "./scripts/electron.sh",
        SWSOURCE.officialwebsite,
))

SoftWareList.append(
    SW( [SWGROUP.internet], [SWPROPS.sysdir],  [SWARCH.arm64],
        "bilibili", 
        "1.1.0-12",
        "",
        "B站客户端，从开源的 tmoe 项目中扣出来的，不是B站官方原版软件!\n"
        "所以如果需要登录，请使用小号登录!\n"
        "github上还有两三个类似的开源项目，都是基于 electron 的修改版客户端"
        "", 

        "./scripts/bilibili.sh",
        SWSOURCE.thirdpary,
))


SoftWareList.append(
    SW( [SWGROUP.office, SWGROUP.none], [SWPROPS.sysdir],  [SWARCH.arm64],
        "腾讯文档", 
        "",
        "约2分钟",
        "腾讯公司出品的办公软件集合\n"
        "软件官网：https://docs.qq.com/home/download\n"
        "\n"
        "需要扫码登录\n"
        "所以仅适合在平板上使用，手机上不方便扫码。\n"
        "\n"
        "安装完成后，桌面有启动图标", 
        "./scripts/TencentDocs.sh",
        SWSOURCE.officialwebsite,
))


SoftWareList.append(
    SW( [SWGROUP.office, SWGROUP.none], [SWPROPS.sysdir],  [SWARCH.arm64],
        "wps", 
        "",
        "约10分钟",
        "国内金山公司出品的办公软件集合\n"
        "软件官网：https://linux.wps.cn/\n"
        "软件官网：https://www.wps.cn/product/wpslinux\n"
        "\n"
        "因为字体版权因素，官方网站下载的arm64版安装包没完整的包入第三方依赖库\n"
        "所以官网下载的安装包，装完不能直接启动，必须在软件管家中安装\n"
        "这里装的是免费版，空间占用约1.2GB\n"
        "由于官网的下载限制，免费版的下载过程比较繁琐!\n"
        "\n"
        "默认为英文界面，需要自己切换语言\n"
        "切换语言步骤：\n"
        "　　打开一个word文件，菜单栏最右边几个按钮中带\"A\"字样的按钮，点击即可\n"
        "注：在proot环境下，wps备份相关的设置无法更改", 
        "./scripts/wps_officialwebsite.sh",
        SWSOURCE.officialwebsite,
))

SoftWareList.append(
    SW( [SWGROUP.office, SWGROUP.none], [SWPROPS.sysdir],  [SWARCH.arm64],
        "wps修复包", 
        "",
        "约1分钟",
        "wps修复\n"
        "包括字体安装，以及处理免费版中字体加粗显示异常的问题", 
        "./scripts/wps-patch.sh",
        SWSOURCE.officialwebsite,
))

SoftWareList.append(
    SW( [SWGROUP.office, SWGROUP.none], [SWPROPS.sysdir],  [SWARCH.arm64],
        "wps-pro", 
        "",
        "约10分钟",
        "国内金山公司出品的办公软件集合，这里装的是专业版\n"
        "比免费版快，功能无阉割，可免费试用180天，英文界面", 
        "./scripts/wps-pro.sh",
        SWSOURCE.officialwebsite,
))


SoftWareList.append(
    SW( [SWGROUP.office], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "libreoffice", 
        "",
        "约8分钟",
        "办公软件集合，支持中文界面，但是对msoffice的格式支持得不太好", 
        "./scripts/libreoffice.sh",
        SWSOURCE.aptrepo,
))

SoftWareList.append(
    SW( [SWGROUP.media], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "mpg123", 
        "",
        "",
        "命令行下的mp3播放器\n"
        "\n"
        "安装完成后，桌面上有 声音测试 的启动图标", 
        "./scripts/mpg123.sh",
        SWSOURCE.aptrepo,
))

SoftWareList.append(
    SW( [SWGROUP.media], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "vlc播放器", 
        "",
        "",
        "音乐、视频播放器\n"
        "\n"
        "安装完成后，桌面上有启动图标", 
        "./scripts/vlc.sh",
        SWSOURCE.aptrepo,
))

SoftWareList.append(
    SW( [SWGROUP.compress], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "zip_unzip", 
        "",
        "",
        "命令行下的zip压缩、解压缩工具\n"
        "\n"
        "安装完成会在右键菜单中有压缩选项",
        "./scripts/zip_unzip.sh",
        SWSOURCE.aptrepo,
))

SoftWareList.append(
    SW( [SWGROUP.compress], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "EGzip", 
        "",
        "",
        "压缩工具，支持非常多的压缩格式，强烈推荐！！\n"
        "安装的是 EnGrampa 归档管理器\n"
        "安装完成后，桌面有启动图标，并且自动集成到右键菜单", 
        "./scripts/EGzip.sh",
        SWSOURCE.aptrepo,
))

# SoftWareList.append(
#     SW( [SWGROUP.compress], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
#         "LXzip", 
#         "",
#         "",
#         "压缩工具，支持非常多的压缩格式\n"
#         "安装的是 lxqt-archiver", 
#         "./scripts/LXzip.sh",
#         SWSOURCE.aptrepo,
# ))


SoftWareList.append(
    SW( [SWGROUP.compress], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "PeaZip", 
        "",
        "",
        "压缩工具，支持非常多的压缩格式", 
        "./scripts/peazip.sh",
        SWSOURCE.aptrepo,
))


SoftWareList.append(
    SW( [SWGROUP.compress], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "ark", 
        "",
        "",
        "压缩工具，支持非常多的压缩格式""\n"
        "23.10以上的rootfs，请使用这个工具解压", 
        "./scripts/ark.sh",
        SWSOURCE.aptrepo,
))


SoftWareList.append(
    SW( [SWGROUP.compress], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "xarchiver", 
        "",
        "",
        "压缩工具，支持非常多的压缩格式", 
        "./scripts/xarchiver.sh",
        SWSOURCE.aptrepo,
))

SoftWareList.append(
    SW( [SWGROUP.download], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "motrix", 
        "",
        "",
        "下载工具，界面漂亮", 
        "./scripts/motrix.sh",
        SWSOURCE.aptrepo,
))

SoftWareList.append(
    SW( [SWGROUP.download], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "uget", 
        "",
        "",
        "下载工具，界面比较老旧", 
        "./scripts/uget.sh",
        SWSOURCE.aptrepo,
))

SoftWareList.append(
    SW( [SWGROUP.vir, SWGROUP.game], [SWPROPS.sysdir],  [SWARCH.arm64],
        "box", 
        "",
        "",
        "在arm架构的linux上运行 x86/x64架构的linux软件\n"
        "\n\n"
        "安装成功后，box86、box64 指令可用", 
        "./scripts/box.sh",
        SWSOURCE.thirdpary,
))

SoftWareList.append(
    SW( [SWGROUP.vir, SWGROUP.game], [SWPROPS.sysdir],  [SWARCH.arm64],
        "compile-box", 
        "",
        "约20分钟",
        "在arm架构的linux上运行 x86/x64架构的linux软件\n以编译源码的方式安装", 
        "./scripts/compile-box.sh",
        SWSOURCE.thirdpary,
))

SoftWareList.append(
    SW( [SWGROUP.vir, SWGROUP.game], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "wine-x32-x64", 
        "8.9",
        "约6分钟",
        "在linux中运行windows软件的环境"
        "\n\n"
        "安装成功后 wine32、wine64、winexe 指令可用\n"
        "桌面也会有wine的启动图标\n",
        "./scripts/wine-8.9.sh",
        SWSOURCE.thirdpary,
))

# SoftWareList.append(
#     SW( [SWGROUP.vir], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
#         "wine-x32-x64", 
#         "9.1",
#         "约6分钟",
#         "在linux中运行windows软件的环境", 
#         "./scripts/wine-9.1.sh",
#         SWSOURCE.thirdpary,
# ))

# SoftWareList.append(
#     SW( [SWGROUP.vir], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
#         "playonlinux", 
#         "",
#         "约6分钟",
#         "在linux中运行windows软件的环境, playonlinux 是对wine的二次开发，带有图形管理界面", 
#         "./scripts/playonlinux.sh",
#         SWSOURCE.thirdpary,
# ))

SoftWareList.append(
    SW( [SWGROUP.game], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "glmark2", 
        "",
        "",
         "3d测分工具\n运行结束时会给出分数，得分越高表示当前系统的3D性能越好，\n"
        +"由于虚拟电脑目前使用的opengl是mesa通过virgl把绘图请求转发到安卓环境执行的，\n"
        +"故性能相当相当低，只能发挥出原生环境约1/10的性能，且延迟变大", 
        "./scripts/glmark2.sh",
        SWSOURCE.aptrepo,
))

# SoftWareList.append(
#     SW( [SWGROUP.game], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
#         "steam-linux", 
#         "",
#         "",
#          "steam游戏商店\n  安装快结束时，会报错说找不到libc.so.6，\n"
#          "这是因为steam启动脚本不会自动以box86运行导致的，\n"
#          "但我们的安装脚本会处理这个问题，故此错误无需理会,\n"
#          "\n"
#          "请先安装box，以及开启proot-sysvipc功能\n"
#          "步骤：开始->控制台->proot-sysvipc功能\n"
#          "\n\n"
#          "此安装器安装的是linux-x86版的steam, 目前暂时无法运行\n"
#          "建议安装PlayOnLinux，并在PlayOnlinux中安装steam",
#         "./scripts/steam.sh",
#         SWSOURCE.thirdpary,
# ))

# SoftWareList.append(
#     SW( [SWGROUP.game], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
#         "steam-win32", 
#         "",
#         "",
#          "steam游戏商店\n  这是windows版steam，用wine运行的，所以必须先安装box和wine!\n"
#          "请注意：\n"
#          "通过wine运行windows版steam相当吃运存，启动非常慢",
#         "./scripts/steam-win32.sh",
#         SWSOURCE.thirdpary,
# ))

# SoftWareList.append(
#     SW( [SWGROUP.game], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
#         "steam-win64", 
#         "",
#         "",
#          "steam游戏商店\n  这是windows版steam，用wine运行的，所以必须先安装box和wine!\n"
#          "请注意：\n"
#          "通过wine运行windows版steam相当吃运存，启动非常慢",
#         "./scripts/steam-win64.sh",
#         SWSOURCE.thirdpary,
# ))

SoftWareList.append(
    SW( [SWGROUP.game], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "jdk21", 
        "",
        "约8分钟",
        "jdk 包括java运行时和java sdk，用于开发、运行 java 程序\n"
        "\n"
        "请注意：如果同时还安装了openjdk，则环境变量中java优先指向openjdk", 
        "./scripts/jdk21.sh",
        SWSOURCE.officialwebsite,
))

SoftWareList.append(
    SW( [SWGROUP.game], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "HMCL", 
        "",
        "",
         "我的世界安装启动器\n"
        "\n\n"
        "安装成功后桌面上有两个启动图标\n"
        "一个带virgl-3D加速(不一定能顺利启动)\n"
        "一个不带3D加速\n"
        "\n",
        "./scripts/HMCL.sh",
        SWSOURCE.thirdpary,
))



SoftWareList.append(
    SW( [SWGROUP.game], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "aisleriot", 
        "",
        "",
         "LINUX 下的纸牌游戏，无中文界面。\n"
        "体积\n"
        "安装成功后，桌面上的软件目录有启动图标\n"
        "",
        "./scripts/aisleriot.sh",
        SWSOURCE.thirdpary,
))

SoftWareList.append(
    SW( [SWGROUP.game], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "pysolfc", 
        "",
        "",
         "LINUX 下的纸牌游戏，内带上千种纸牌玩法，无中文界面。\n"
        "从源码编译安装\n"
        "安装成功后，桌面上有启动图标\n"
        "",
        "./scripts/pysolfc.sh",
        SWSOURCE.thirdpary,
))




SoftWareList.append(
    SW( [SWGROUP.dev], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "gcc", 
        "",
        "",
        "gcc gdb make 三件套，不包含g++！\n"
        "建议安装vscode做为代码编辑器\n"
        "如何使用vscode调试C  项目，可以参考 ./scripts/res/vscode-demo-c-1\n"
        "如何使用vscode调试C++项目，可以参考 ./scripts/res/vscode-demo-cpp-1\n",
        "./scripts/gcc.sh",
        SWSOURCE.aptrepo,
))

SoftWareList.append(
    SW( [SWGROUP.dev], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "vscode", 
        "",
        "",
        "非常有名的代码编辑器\n检测到中文环境会询问是否安装软件的中文包\n"
        "如何使用vscode调试C  项目，可以参考 ./scripts/res/vscode-demo-c-1\n"
        "如何使用vscode调试C++项目，可以参考 ./scripts/res/vscode-demo-cpp-1\n"
        "\n"
        " vscode使用源码目录中的.vscode文件夹来描述项目\n"
        " 打开其所在的目录即打开了 工程/项目\n"
        " 也可以在终端下进到源码目录，然后敲：code .\n"
        "\n"
        "安装完成后，桌面有启动图标", 
        "./scripts/vscode.sh",
        SWSOURCE.thirdpary,
))

SoftWareList.append(
    SW( [SWGROUP.dev], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "code-server", 
        "",
        "",
        "vscode的网页版，可以在其它设备上通过浏览器使用\n"
        "默认端口：5560"
        "\n"
        "安装完成后，桌面有启动图标", 
        "./scripts/code-server.sh",
        SWSOURCE.thirdpary,
))

SoftWareList.append(
    SW( [SWGROUP.dev], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "IntelliJ-IDEA", 
        "",
        "",
        "idea是个非常有名的java代码编辑器\n"
        "这里安装的是免费的社区版(arm64架构)\n"
        "\n"
        "安装到能成功编译安卓项目，则存储空间占用约：7GB\n"
        "\n"
        "可以在其插件页面安装 \"Android\" 插件，以支持安卓app的开发\n"
        "可以在其插件页面安装 \"Chinese Simple\" 插件，以汉化界面\n"
        "\n"
        "第一次创建android项目时，idea的安卓插件可能要花10分钟来初始化项目\n"
        "包括创建索引，下载安装android-sdk、gradle、以及一堆的依赖库。。。\n"
        "当然，经过第一次的痛以后，就顺了\n"
        "\n"
        "如果项目编译报错说类重复，请在 build.gradle、或  build.gradle.kts 中添加：\n"
        "   implementation(platform(\"org.jetbrains.kotlin:kotlin-bom:1.8.0\"))\n"
        "\n"
        "如果需要使用adb来安装编译好的包，\n"
        "请在软件管家中安装adb并连接上设备\n，并执行：\n"
        " cp  -f  /usr/bin/adb  ./Android/Sdk/platform-tools/adb\n"
        "\n"
        "说明：\n"
        "在虚拟电脑中跑这种大型ide，极易被杀后台。\n"
        "最好在电脑上玩，或者有两台安卓设备的情况下使用"
        "", 
        "./scripts/idea.sh",
        SWSOURCE.thirdpary,
))

SoftWareList.append(
    SW( [SWGROUP.dev], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "zig", 
        "0.11",
        "",
        "zig语言编译工具集，zig是基于llvm开发的跨平台编程语言，\n相对其它跨平台的编译工具来说，zig体积非常小\n目标是替代C, https://ziglang.org/learn/getting-started/", 
        "./scripts/zig.sh",
        SWSOURCE.officialwebsite,
))

SoftWareList.append(
    SW( [SWGROUP.dev], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "dotnet", 
        "6.0",
        "",
        "对，微软开发的用于linux平台的 C#/.NET !\n"
        "2023年了，dotnet很好用了的\n\n"
        "示例：\n"
        "mkdir ~/mycode\n"
        "cd ~/mycode\n"
        "dotnet new console # 创建一个最简单的项目源码\n"
        "dotnet run         # 编译并运行\n"
        "\n"
        "发布应用：\n"
        "cd ~/mycode\n"
        "dotnet publish -c release\n"
        "或参考：https://learn.microsoft.com/zh-cn/dotnet/core/deploying/deploy-with-cli\n",
        "./scripts/dotnet.sh",
        SWSOURCE.officialwebsite,
))

SoftWareList.append(
    SW( [SWGROUP.dev], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "android-ndk", 
        "r26b",
        "约10分钟",
        "android ndk 用于开发安卓原生动态库/安卓原生控制台程序\n"
        "但官方只发布了amd64架构的版本\n"
        "这里安装的是github上的aarch64版本\n"
        "\n"
        "仓库地址：https://github.com/lzhiyong/termux-ndk"
        "\n"
        "查看可用指令：ls -al /usr/bin/ndk*\n"
        "如何使用请参考示例： ./scripts/res/ndk-demo1\n",
        "./scripts/android-ndk.sh",
        SWSOURCE.thirdpary,
))

# SoftWareList.append(
#     SW( [SWGROUP.dev], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
#         "android-ndk", 
#         "r25c",
#         "约10分钟",
#         "android ndk 用于开发安卓原生动态库/安卓原生控制台程序, \n"
#         +"但官方只发布了amd64架构的版本,\n"
#         +"在 proot arm64 linux 环境中，可以通过box来启动编译器(效率还能接受)\n"
#         +"如何使用请参考示例： ./scripts/res/ndk-demo1\n"
#         +"\n"
#         +"必须启用：\n"
#         +"开始菜单->控制台->proot管理->proot-userland(支持ndk)\n"
#         +"才能在droidvm中通过box64调用ndk-clang", 
#         "./scripts/android-ndk.sh",
#         SWSOURCE.thirdpary,
# ))

SoftWareList.append(
    SW( [SWGROUP.dev], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "jdk21", 
        "",
        "约8分钟",
        "jdk 包括java运行时和java sdk，用于开发、运行 java 程序\n"
        "\n"
        "请注意：如果同时还安装了openjdk，则环境变量中java优先指向openjdk", 
        "./scripts/jdk21.sh",
        SWSOURCE.officialwebsite,
))

SoftWareList.append(
    SW( [SWGROUP.dev], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "openjdk", 
        "",
        "约3分钟",
        "openjdk 包括java运行时和java sdk，用于开发、运行 java 程序", 
        "./scripts/openjdk.sh",
        SWSOURCE.aptrepo,
))


SoftWareList.append(
    SW( [SWGROUP.dev], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "godot", 
        "4.2.1",
        "约1分钟",
        "godot\n"
        "\n"
        "仓库地址：https://github.com/godotengine/godot", 
        "./scripts/godot.sh",
        SWSOURCE.github,
))

SoftWareList.append(
    SW( [SWGROUP.dev], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "pycharm", 
        "",
        "",
        "pycharm 是个流行的 python 代码编写工具，集成编辑器、打包器等于一体\n"
        "官方网站：https://www.jetbrains.com/pycharm/\n"
        "这里安装的是社区版，下载流量消耗约800M左右"
        "\n"
        "安装完成后，桌面有启动图标", 
        "./scripts/pycharm.sh",
        SWSOURCE.officialwebsite,
))



SoftWareList.append(
    SW( [SWGROUP.sys], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "systemctl", 
        "",
        "",
        "fake-systemd\n"
        "\n\n"
        "安装成功后 systemctl 指令可用\n"
        "使用示例：\n"
        "sudo systemctl start nginx\n"
        "sudo systemctl stop  nginx"
        "",
        "./scripts/systemctl.sh",
        SWSOURCE.thirdpary,
))

SoftWareList.append(
    SW( [SWGROUP.sys], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "udocker", 
        "",
        "",
        "用Python写的userspace docker，仅能运行部分docker镜像\n"
        "软件官网：https://github.com/indigo-dc/udocker\n"
        "\n\n"
        "安装成功后 udocker 指令可用\n"
        "使用示例：\n"
        "udocker --help\n"
        "udocker install\n"
        "udocker run busybox\n"
        "",
        "./scripts/udocker.sh",
        SWSOURCE.github,
))


SoftWareList.append(
    SW( [SWGROUP.sys, SWGROUP.rdp], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "xpra", 
        "",
        "",
        "通过网页控制虚拟电脑\n"
        "\n"
        "安装成功后，依次点击 开始菜单->远程控制->通过WbnXpra 启动"
        "",
        "./scripts/xpra.sh",
        SWSOURCE.aptrepo,
))


SoftWareList.append(
    SW( [SWGROUP.sys, SWGROUP.rdp], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "webvnc", 
        "",
        "",
        "图形界面远程控制工具\n"
        "安装并启动webvnc后\n"
        "可以在电脑端通过网页浏览器、或者VNC客户端远程控制虚拟电脑\n"
        "\n"
        "这个软件包包含tigerVNC 和 noVNC，默认端口分别是5906和6080\n"
        "在lx终端中运行 vncpasswd 指令可以修改访问密码\n"
        "\n\n"
        "安装成功后在桌面上有启动图标，双击可以启动(音量减键)\n"
        "用记事本打开这个启动图标，可以调整分辨率"
        "",
        "./scripts/webvnc.sh",
        SWSOURCE.aptrepo,
))


SoftWareList.append(
    SW( [SWGROUP.sys, SWGROUP.rdp], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "remmina", 
        "",
        "",
        "图形界面远程控制工具\n"
        "支持的远程连接协议包括：vnc, rdp, ssh\n"
        "可以在虚拟电脑中连接到其它的windows桌面\n"
        "\n"
        "要连接windows\n"
        "windows上要安装vnc协议的 TightVNC\n"
        "下载地址：https://www.tightvnc.com/download.php\n"
        "\n\n"
        "安装成功后，桌面上的软件目录中有启动图标，双击可以启动(音量减键)"
        "",
        "./scripts/remmina.sh",
        SWSOURCE.aptrepo,
))


SoftWareList.append(
    SW( [SWGROUP.sys, SWGROUP.rdp], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "rustdesk", 
        "",
        "",
        "图形界面远程控制工具\n"
        "可以在虚拟电脑中连接到其它的windows桌面\n"
        "\n"
        "要连接windows\n"
        "windows上要安装rustdesk\n"
        "下载地址：https://github.com/rustdesk/rustdesk\n"
        "\n\n"
        "安装成功后，桌面上的软件目录中有启动图标，双击可以启动(音量减键)"
        "",
        "./scripts/rustdesk.sh",
        SWSOURCE.thirdpary,
))


SoftWareList.append(
    SW( [SWGROUP.sys, SWGROUP.vir, SWGROUP.game], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "termux", 
        "",
        "",
        "以proot加载termux-rootfs的方式运行termux\n"
        "虚拟电脑中引入的termux不是完整版本，主要是供开发人员和游戏玩家使用!\n"
        "\n"
        "对于游戏玩家来说，可以在termux里面安装mobox:\n"
        "  ~/mobox-installer/setup.sh\n"
        "\n"
        "对于开发人员来说，运行于termux中的软件:\n"
        "  可以调用 termux 移植的三方库(可在termux中使用pkg指令从镜像仓库下载)\n"
        "  可以调用安卓原生的系统库(在安卓系统的库目录中)\n\n"
        "  pkg install clang 安装gcc后，可用于开发需要直接调用宿主GPU的带界面软件\n"
        "\n"
        "安装完成后，termux指令可用，桌面也有启动图标", 
        "./scripts/termux.sh",
        SWSOURCE.thirdpary,
))

SoftWareList.append(
    SW( [SWGROUP.sys], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "星火应用商店", 
        "",
        "约2分钟",
        "里面的软件不一定都能在虚拟电脑中运行！\n"
        "软件官网：https://gitee.com/spark-store-project/spark-store\n"
        "\n"
        "\n"
        "安装完成后，桌面有启动图标", 
        "./scripts/spark-store.sh",
        SWSOURCE.officialwebsite,
))

SoftWareList.append(
    SW( [SWGROUP.sys], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "tmoe", 
        "",
        "",
        "软件管理工具，运行于控制台，使用TAB键、方向键、回车键进行操作\n收录了很多软件", 
        "./scripts/tmoe.sh",
        SWSOURCE.thirdpary,
))

SoftWareList.append(
    SW( [SWGROUP.sys], [],  [SWARCH.arm64, SWARCH.amd64],
        "build_mylinux", 
        "",
        "",
        " 《半小时，无痛体验一次自己编译并运行linux-6.6主线内核》\n"
        " ---- x86_64 架构 qemu-virt机型\n"
        "\n"
        " 因内核设计为启动完成后必须降权跳到用户空间运行第一个进程\n"
        " 所以除了编译内核源码的脚本外，还包含了创建rootfs的脚本\n"
        " 以便实现内核的全流程启动\n"
        " (不包括内核打补丁[kernel-patch]，也不包括启动文件出处的查验[secure-boot])"
        "\n\n"
        "安装完成后，在桌面上会有启动图标", 
        "./scripts/build_mylinux.sh",
        SWSOURCE.thirdpary,
))

SoftWareList.append(
    SW( [SWGROUP.sys, SWGROUP.bootdisk], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "qemu-linux-amd64", 
        "",
        "",
        "可用qemu启动的超小型、不带图形界面的linux系统\n"
        "结合安卓端的虚拟电脑app，可以在此系统中通过 usbip 操作安卓端的USB设备!\n"
        "\n"
        "此镜像的目标机型为 amd64(x86_64) 架构的 qemu-virt 机型\n"
        "内核使用自行编译的 linux-6.6 主线源码\n"
        "核心文件组基于amd64版的ubuntu-base-rootfs创建，可以方便的使用apt指令安装软件\n"
        "\n\n"
        "安装完成后，在桌面上会有启动图标", 
        "./scripts/qemu-linux-amd64.sh",
        SWSOURCE.thirdpary,
))

SoftWareList.append(
    SW( [SWGROUP.sys, SWGROUP.bootdisk], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "mkbootudisk", 
        "",
        "",
        " 制作winpe启动U盘的小工具\n"
        " winpe版本为win10pe，相关文件来自 https://gitee.com/duanwujie88/WinPE \n"
        " 支持BIOS(老)/UEFI(新)两种启动模式！\n"
        "\n"
        "制作成功后\n"
        "U盘会被划分成两个分区：\n"
        " 一个小容量分区(存放pe系统启动文件)\n"
        " 一个大容量分区(镜像存放分区)\n"
        "\n"
        " 如需要使用自定义的PE镜像，请替换 /opt/apps/mkbootudisk/winpe.zip(只支持zip格式) "
        " 如用于启动BIOS模式的电脑，替换镜像时请注意保留 grub 相关文件"
        "\n\n"
        "此软件不包含 windows 安装程序、windows恢复镜像，请自行下载"
        "\n\n"
        "安装完成后，在桌面上会有启动图标", 
        "./scripts/mkbootudisk.sh",
        SWSOURCE.thirdpary,
))




SoftWareList.append(
    SW( [SWGROUP.server], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "nginx", 
        "",
        "",
        "网页服务器，包括：\n"
        "nginx php-fpm redis php-redis"
        "\n\n"
        "安装成功后可以在桌面上的软件目录里打开\n",
        "./scripts/nginx.sh",
        SWSOURCE.aptrepo,
))

SoftWareList.append(
    SW( [SWGROUP.repair], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "apt仓库刷新", 
        "",
        "",
        "执行指令：sudo apt update。若显示已安装，请重装",
        "./scripts/rp0.sh",
        SWSOURCE.aptrepo,
))

SoftWareList.append(
    SW( [SWGROUP.repair], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "修复1", 
        "",
        "",
        "执行指令：sudo dpkg --configure -a。若显示已安装，请重装\n"
        "通常对应于apt的错误码100",
        "./scripts/rp1.sh",
        SWSOURCE.aptrepo,
))

SoftWareList.append(
    SW( [SWGROUP.repair], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "修复2", 
        "",
        "",
        "执行指令：sudo apt --fix-broken install -y。若显示已安装，请重装"
        "通常对应于apt的错误码100",
        "./scripts/rp2.sh",
        SWSOURCE.aptrepo,
))

SoftWareList.append(
    SW( [SWGROUP.repair], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "修复3", 
        "",
        "",
        "执行指令：sudo apt-get install --fix-missing -y。若显示已安装，请重装",
        "./scripts/rp3.sh",
        SWSOURCE.aptrepo,
))

SoftWareList.append(
    SW( [SWGROUP.repair, SWGROUP.desktop], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "大鼠标指针", 
        "",
        "小于1分钟",
        "觉得鼠标指针过小的，可以安装这个软件包\n"
        "",
        "./scripts/bigpointer.sh",
        SWSOURCE.thirdpary,
))

SoftWareList.append(
    SW( [SWGROUP.repair, SWGROUP.desktop], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "Xfce终端", 
        "",
        "",
        "支持拖入文件夹获取路径",
        "./scripts/xfce-terminal.sh",
        SWSOURCE.thirdpary,
))

SoftWareList.append(
    SW( [SWGROUP.printe3d], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "klipper", 
        "",
        "",
        "klipper 用于控制3D打印机。项目开源免费，在国内很流行，它包括两个部分：\n"
        "一部分是上位机软件，用python开发，通常运行于性能不弱的linux系统上\n"
        "一部分是固件源码，可编译烧录到3D打印机控制板中，固件也叫 firmware\n"
        "\n"
        "从固件源码看，目前支持的mcu主要的: ar、at、avr、hc、lpc、pru、rp、stm32各系列\n"
        "对特定的控制板、mcu，需要下载源码、配置源码(即选择要编译哪些功能、编译哪颗芯片的代码)\n"
        "源码配置好以后，编译生成的 .bin/.hex 文件，就可以将其传送到控制上的芯片内，即烧写、下载、刷新固件\n"
        "\n"
        "固件的烧写，不同的芯片支持不同的数据传送通道，大概这几类：\n"
        "用usb数据线，用串口线(或usb转串口线),用SD卡\n"
        "不同的芯片，烧写固件所用的工具不相同，固件代码的打包格式、传送协议也不同\n"
        "\n\n"
        "安装成功后桌面会有klipper图标，双击即可启动\n"
        "也可以在终端用 klipper 指令启动。klipper 通常要结合 moonraker + mainsail 两个软件才能使用！",
        "./scripts/klipper.sh",
        SWSOURCE.thirdpary,
))

SoftWareList.append(
    SW( [SWGROUP.printe3d], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "moonraker", 
        "",
        "",
        "moonraker是一个pythone程序，它通过一个 \"Unix Domain Socket\" 文件连接到运行中的 klipper上位机软件\n"
        "并将 klipper 对其它程序开放的TCP控制接口转换成 websocket 协议控制的接口\n"
        "以便 Mainsail/Fluidd/KlipperScreen/mooncord 一类的软件能对用户提供更友好的klipper控制界面\n"
        "\n\n"
        "安装成功后可以执行 moonraker 指令启动moonraker\n"
        "启动后可以访问 http://设备IP:7125/ 这个网址查看运行状态\n"
        "这是json版本的 http://设备IP:7125/server/info\n",
        "./scripts/moonraker.sh",
        SWSOURCE.thirdpary,
))

SoftWareList.append(
    SW( [SWGROUP.printe3d], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "mainsail", 
        "",
        "",
        "mainsail 是klipper网页端的控制界面，安装此软件会自动安装nginx\n"
        "\n\n"
        "安装成功后可以执行 mainsail 指令启动mainsail\n"
        "启动后可以访问 http://设备IP:8888/ 这个网址查看控制界面",
        "./scripts/mainsail.sh",
        SWSOURCE.thirdpary,
))

SoftWareList.append(
    SW( [SWGROUP.printe3d], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "fluidd", 
        "",
        "",
        "fluidd 也是klipper网页端的控制界面，安装此软件会自动安装nginx，和mainsail二选一即可！\n"
        "\n\n"
        "安装成功后可以执行 fluidd 指令启动fluidd\n"
        "启动后可以访问 http://设备IP:9999/ 这个网址查看控制界面",
        "./scripts/fluidd.sh",
        SWSOURCE.thirdpary,
))

SoftWareList.append(
    SW( [SWGROUP.printe3d], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "klipperscreen", 
        "",
        "",
        "klipperscreen 是用pythone + gtk库写的本地klipper控制端"
        "\n\n"
        "安装成功后可以在桌面上双击klipperscreen图标打开\n"
        "\n",
        "./scripts/klipperscreen.sh",
        SWSOURCE.thirdpary,
))

SoftWareList.append(
    SW( [SWGROUP.printe3d], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "cura", 
        "",
        "",
        "cura 是流行的3D打印切片软件\n"
        "默认为英文，可以在菜单栏->preference中设置成中文"
        "\n\n"
        "安装成功后可以在桌面上的软件目录里打开\n"
        "\n",
        "./scripts/cura.sh",
        SWSOURCE.aptrepo,
))

SoftWareList.append(
    SW( [SWGROUP.printe3d], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "prusaslicer", 
        "",
        "",
        "prusaslicer 是流行的3D打印切片软件\n"
        "提示：\n"
        "　此软件的窗口，宽高比是锁死的\n"
        "　在非4:3、非16:9的屏幕上显示效果可能不太好\n"
        "\n\n"
        "安装成功后可以在桌面上的软件目录里打开\n"
        "\n",
        "./scripts/prusaslicer.sh",
        SWSOURCE.aptrepo,
))

SoftWareList.append(
    SW( [SWGROUP.printe3d], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "freecad", 
        "",
        "",
        "linux中常用的cad软件\n"
        "默认为英文，可以在菜单栏->edit->preference中设置成中文"
        "\n\n"
        "安装成功后可以在桌面上的软件目录里打开\n"
        "\n",
        "./scripts/freecad.sh",
        SWSOURCE.aptrepo,
))


SoftWareList.append(
    SW( [SWGROUP.art], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "gimp", 
        "",
        "",
        "linux系统中的图片处理工具，GNU Image Manipulation Program，", 
        "./scripts/gimp.sh",
        SWSOURCE.aptrepo,
))

SoftWareList.append(
    SW( [SWGROUP.art], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "imagemagick", 
        "",
        "",
        "命令行下的图片格式转换工具", 
        "./scripts/imagemagick.sh",
        SWSOURCE.aptrepo,
))

SoftWareList.append(
    SW( [SWGROUP.art], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "shotcut", 
        "",
        "",
        "linux系统中的视频剪辑软件", 
        "./scripts/shotcut.sh",
        SWSOURCE.aptrepo,
))

SoftWareList.append(
    SW( [SWGROUP.art], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "Kdenlive", 
        "",
        "",
        "linux系统中的视频剪辑软件\n"
        "软件官网：https://launchpad.net/~kdenlive\n"
        "\n"
        "安装完成后，请到桌面上的软件目录打开"
        "",
        "./scripts/kdenlive.sh",
        SWSOURCE.officialwebsite,
))


SoftWareList.append(
    SW( [SWGROUP.art], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "blender", 
        "",
        "",
        "跨平台的3D设计神器\n"
        "目前虚拟系统只能发挥物理显卡约1/3的效率，所以在手机上跑比较吃力\n"
        "默认为英文，可以加载窗中调为中文\n"
        "\n"
        "安装成功后软件目录中会有两个启动图标\n"
        "一个带加速(不一定能顺利启动)\n"
        "一个不带加速(都能启动)\n"
        "",
        "./scripts/blender.sh",
        SWSOURCE.aptrepo,
))

SoftWareList.append(
    SW( [SWGROUP.art], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "starUML", 
        "",
        "",
        "开源的UML设计工具\n"
        "\n"
        "安装成功后桌面上有启动图标\n"
        "一个带加速(不一定能顺利启动)\n"
        "一个不带加速(都能启动)\n"
        "",
        "./scripts/starUML.sh",
        SWSOURCE.aptrepo,
))


SoftWareList.append(
    SW( [SWGROUP.nas], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "PyWebDAV3", 
        "",
        "",
        "PyWebDAV3运行后，可以在windows电脑上访问、编辑虚拟电脑中的文件\n"
        "默认端口: 5562\n"
        "\n"
        "安装完成后，在开始菜单->文件共享菜单中启动"
        "",
        "./scripts/PyWebDAV3.sh",
        SWSOURCE.thirdpary,
))




SoftWareList.append(
    SW( [SWGROUP.nas], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "filebrowser", 
        "",
        "",
        "filebrowser运行后，可以通过网页浏览器访问、编辑文件\n"
        "默认用户: droidvm\n"
        "默认密码: droidvm\n"
        "默认端口: 5561\n"
        "\n"
        "安装完成后，桌面上有启动图标"
        "",
        "./scripts/filebrowser.sh",
        SWSOURCE.thirdpary,
))


SoftWareList.append(
    SW( [SWGROUP.nas], [SWPROPS.sysdir],  [SWARCH.arm64, SWARCH.amd64],
        "alist", 
        "",
        "",
        "alist可以将当前设备当成本地网盘、家庭网络存储\n"
        "也可以挂载商业网盘\n"
        "暂不支持离线下载功能，请使用虚拟系统自带的下载工具下载\n"
        "\n"
        "默认用户：admin\n"
        "默认密码：droidvm\n"
        "\n"
        "首次通过网页登录，需要手动添加存储路径，步骤为：\n"
        "点底部的 管理 按钮\n"
        "管理面板左侧，点击 存储\n"
        "存储管理面板，点击 添加\n"
        "驱动选 本机存储\n"
        "挂载路径填 /\n"
        "文件路径填 /home/droidvm/Desktop\n"
        "提交后，点左侧面板的 主页"
        "",
        "./scripts/alist.sh",
        SWSOURCE.thirdpary,
))
