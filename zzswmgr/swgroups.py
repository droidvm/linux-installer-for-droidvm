
from enum import Enum

SWGROUPNAMES =      ["常用软件", "本地安装包", "输入法(外接键盘)", "桌面环境", "上网工具", "办公软件", "影音娱乐", "压缩工具", "下载工具", "虚拟类", "游戏", "软件开发", "系统", "服务器类", "修复类",  "3D打印",    "图影动漫", "远程桌面", "NAS网盘", "启动U盘"]
# SWGROUP = .freeze({ none        localdeb          input            desktop    internet      office      media     compress     download      vir    game       dev      sys      server     repair    printe3d         art         rdp       nas       bootdisk        })


class SWGROUP(Enum):
    none = 0
    localdeb = 1
    input = 2
    desktop = 3
    internet = 4
    office = 5
    media = 6
    compress = 7
    download = 8
    vir = 9
    game = 10
    dev = 11
    sys = 12
    server = 13
    repair = 14
    printe3d = 15
    art = 16
    rdp = 17
    nas = 18
    bootdisk = 19

SoftWareProps = ["", "需安装到系统目录"]
class SWPROPS(Enum):
    none = 0
    sysdir = 1

SoftWareSource = ["本地deb安装包", "apt仓库", "第三方", "软件官网", "pip仓库", "github仓库"]
class SWSOURCE(Enum):
    localdeb = 0
    aptrepo = 1
    thirdpary = 2
    officialwebsite = 3
    pip = 4
    github = 5

SoftWareArch = ["arm64", "amd64"]
class SWARCH(Enum):
    arm64 = 0
    amd64 = 1

SoftWareOP = ["none", "installing", "reinstalling", "removing", "fail"]
class SWOP(Enum):
    none = 0
    installing = 1
    reinstalling = 2
    removing = 3
    fail = 4
