#!/usr/bin/env python3
#-*- encoding:utf-8 -*-

"""
软件说明
1. 此脚本为虚拟电脑(droidvm)中使用的 fcitx4/fcitx5 扩展词库导入工具
2. arm64版 fcitx-tools 中的 scel2org 有问题，故而参照网上开源的项目整理了此脚本
3. 主要是调用pygtk实现了图形界面

相关路径
"输入架构：fcitx4系列\n"
"词库格式：.mb\n"
"词库路径： ~/.config/fcitx/table(五笔)\n"
"词库路径：/usr/share/fcitx/table\n"
"词库路径：/usr/share/fcitx/pinyin(拼音)\n"
"词库路径： ~/.config/fcitx/pinyin\n"

"输入架构：fcitx5系列\n"
"词库格式：.dict\n"
"词库路径：/usr/share/libime(其中sc是简体拼音的词库)\n"
"扩展词库：~/.local/share/fcitx5/pinyin/dictionaries(拼音)\n"
"扩展词库：~/.local/share/fcitx5/table(五笔)\n"


相关软件包
libime-bin  # 提供：libime_pinyindict、libime_tabledict、libime_migrate_fcitx4_pinyin、
fcitx-tools # 提供：scel2org、txt2mb、mb2txt


fcitx5系列词库的转换：
cd ~/.local/share/fcitx5/pinyin
libime_pinyindict -d "user.dict"  "user.dict.txt"   #dict 到 txt
libime_pinyindict "词库文件.txt" "词库文件.dict" # txt到dict
libime_pinyindict -d sc.dict  1.txt
libime_tabledict -d wbpy.main.dict  1.txt

mb2txt wbpy.mb.bak >1
txt2mb 1 1.mb
mb2txt 1.mb >2


批量改文件后缀
rename 's/\.dict/\.dictbak/' *


参考资料 
1. https://raw.githubusercontent.com/archerhu/scel2mmseg/master/scel2mmseg.py
2. https://raw.githubusercontent.com/xwzhong/small-program/master/scel-to-txt/scel2txt.py
3. https://github.com/fkxxyz/libscel
4. https://man.archlinux.org/man/createPYMB.1.en

"""

import argparse
import struct
import gi
import os
import sys
import subprocess
import asyncio
import time
import threading
import shutil

gi.require_version("Gtk", "3.0")
from gi.repository import Gtk
from gi.repository import GLib

parser = None
swtitle = '词库导入工具'
swver = '1.0'
win = None
IMname = "fcitx4"


class FormatError(Exception):
    def __init__(self, msg):
        self.msg = msg
    def __str__(self):
        return self.msg

class scel:
    def __init__(self):
        self.title = ''
        self.category = ''
        self.description = ''
        self.samples = []
        self.py_map = {}
        self.word_list = []
        self.del_words = []

    def loads(self, bin_data):
        """
            bin_data 是包含 scel 格式的 bytes 类型二进制数据
            返回值： 返回读取到的数据字典
        """

        def read_str(offset, length = -1):
            if length >= 0:
                str_raw = bin_data[offset:offset+length]
            else:
                str_raw = bin_data[
                    offset:bin_data.find(b'\0\0', offset)
                    ]
            if len(str_raw) % 2 == 1:
                str_raw += b'\0'
            return str_raw.decode('utf-16-le')

        def read_uint16(offset):
            return struct.unpack('H', bin_data[offset:offset+2])[0]

        def read_uint32(offset):
            return struct.unpack('I', bin_data[offset:offset+4])[0]

        # 检验头部
        #   0x0 ~ 0x3
        magic = read_uint32(0)
        if magic != 0x1540:
            raise FormatError('头部校验错误，可能不是搜狗词库文件！')

        # scel格式类型，标志着汉字的偏移量
        #   0x4
        scel_type = bin_data[4]
        if scel_type == 0x44:
            hz_offset = 0x2628
        elif scel_type == 0x45:
            hz_offset = 0x26c4
        else:
            raise FormatError('未知的搜狗词库格式，可能为新版格式！')

        #   0x5 ~ 0x11F 目前未知

        # 读取到词组个数
        record_count = read_uint32(0x120)
        total_words = read_uint32(0x124)

        # 两个未知的值
        int_unknow1 = read_uint32(0x128)
        int_unknow2 = read_uint32(0x12C)

        # 读取到标题、目录、描述、样例
        #   0x130 ~ 0x1540
        self.title = read_str(0x130)
        self.category = read_str(0x338)
        self.description = read_str(0x540)
        str_samples = read_str(0xd40)
        #self.samples = list(map(lambda s:s.split('\u3000'), str_samples.split('\r ')))
        #self.samples[-1][1] = self.samples[-1][1].rstrip(' ')
        self.samples = str_samples

        # 读取到拼音列表
        #   0x1540 ~ 0x1540 + ?
        py_count = read_uint32(0x1540)
        offset = 0x1544
        for j in range(py_count):
            py_idx = read_uint16(offset)
            offset += 2
            py_len = read_uint16(offset)
            offset += 2
            py_str = read_str(offset, py_len)
            offset += py_len

            self.py_map[py_idx] = py_str

        # 读取词语列表
        #   hz_offset ~ ?
        offset = hz_offset
        for j in range(record_count):
            word_count = read_uint16(offset)
            offset += 2
            py_idx_count = int(read_uint16(offset) / 2)
            offset += 2

            py_set = []
            for i in range(py_idx_count):
                py_idx = read_uint16(offset)
                offset += 2
                py_set.append(py_idx)

            for i in range(word_count):
                word_len = read_uint16(offset)
                offset += 2
                word_str = read_str(offset, word_len)
                offset += word_len

                info_len = read_uint16(offset)
                offset += 2
                seq = read_uint16(offset)
                flag_unknow = read_uint16(offset+2)
                info_unknow = []
                for i in range(3):
                    info_unknow.append(read_uint16(offset+4+i*2))
                if info_unknow != [0, 0, 0]:
                    print("发现新的扩展信息，请将该词库上报以便调试。", info_unknow)
                offset += info_len

                self.word_list.append([word_str, py_set, seq])

        # 读取的词语按顺序排序
        self.word_list.sort(key = lambda e:e[2])

        # 读取被删除的词语
        if bin_data[offset:offset+12] == 'DELTBL'.encode('utf-16-le'):
            offset += 12
            del_count = read_uint16(offset)
            offset += 2
            for i in range(del_count):
                word_len = read_uint16(offset) * 2
                offset += 2
                word_str = read_str(offset, word_len)
                offset += word_len
                self.del_words.append(word_str)

    def load(self, file_path):
        data = open(file_path, 'rb').read()
        return self.loads(data)

class WorkerAppend(threading.Thread):
    def __init__(self, window, strMode, srcpath, txtpth1, txtpth2, dstpath):
            threading.Thread.__init__(self)
            self.window = window
            self.strMode = strMode
            self.srcpath = srcpath
            self.txtpth1 = txtpth1
            self.txtpth2 = txtpth2
            self.dstpath = dstpath

    def action_1to4(self):
        if self.srcpath == "":
            return 1,"请选择待合并的文件(文件1)"
        if not os.path.exists(self.srcpath):
            return 2, "文件不存在：" + self.srcpath
        if self.dstpath == "":
            return 1,"请选择目标文件(文件4)"
        # if not os.path.exists(self.dstpath):
        #     return 2, "文件不存在：" + self.dstpath

        GLib.idle_add(self.window.setmesg, "正在转成 文件4")


        if IMname.startswith("fcitx5: 码表五笔输入法"):
            # 1 to 2
            self.action_1to2(True)
            if not os.path.exists(self.txtpth1):
                return 2, "转换失败：" + self.txtpth1

            shellexec("mkdir -p " + os.environ['HOME'] + "/.local/share/fcitx5/table")
            shrlt = shellexec("libime_tabledict " + self.txtpth1 + "  " + self.dstpath)
            if shrlt != 0:
                return 2, "文件2(.txt2) => 文件4(.dict)失败"
        elif IMname.startswith("fcitx5: 码表拼音输入法"):
            # 1 to 2
            self.action_1to2()
            if not os.path.exists(self.txtpth1):
                return 2, "转换失败：" + self.txtpth1

            shellexec("mkdir -p " + os.environ['HOME'] + "/.local/share/fcitx5/pinyin/dictionaries")
            shrlt = shellexec("libime_pinyindict " + self.txtpth1 + "  " + self.dstpath)
            if shrlt != 0:
                return 2, "文件2(.txt2) => 文件4(.dict)失败"
        elif IMname.startswith("fcitx4: 码表五笔输入法"):
            mbfile = os.environ['HOME'] + "/.config/fcitx/table/wbpy.mb"
            if not os.path.exists(mbfile):
                shellexec("mkdir -p " + os.environ['HOME'] + "/.config/fcitx/table")
                shutil.copyfile("/usr/share/fcitx/table/wbpy.mb", mbfile)

            if not os.path.exists(mbfile):
                return 2, "文件4(.mb) => 文件3(.txt1)失败，文件4不存在"

            # 反编译
            txtpth2="/tmp/dec.txt1"
            shrlt = shellexec("mb2txt " + mbfile + " > " + txtpth2)
            if shrlt != 0:
                return 2, "文件4(.mb) => 文件3(.txt1)失败，反编译失败"
            if not os.path.exists(txtpth2):
                return 2, "文件不存在：" + txtpth2

            # 1 to 2
            self.action_1to2()
            if not os.path.exists(self.txtpth1):
                return 2, "转换失败：" + self.txtpth1

            # 合并 3+2
            txttemp="/tmp/merged.txt"
            shrlt = shellexec("cat \"" + txtpth2 + "\" \"" + self.txtpth1 + "\" > " + txttemp)
            if shrlt != 0:
                return 2, "文件3 和 文件2 合并失败"
            
            # txt2mb
            mb_new="/tmp/new.mb"
            shrlt = shellexec("nohup txt2mb " + txttemp + " " + mb_new + " 2>&1 > /tmp/2to4.log")
            if shrlt != 0:
                return 2, ".txt1 转文件4(.mb) 失败"

            # 应用新词库
            shrlt = shellexec("mv -f " + mb_new + " " + mbfile)
            if shrlt != 0:
                return 2, ".txt1 转文件4(.mb) 失败"
        elif IMname.startswith("fcitx4: 码表拼音输入法"):
            mbbase = os.environ['HOME'] + "/.config/fcitx/pinyin/pybase.mb"
            mbfile = os.environ['HOME'] + "/.config/fcitx/pinyin/pyphrase.mb"
            shellexec("mkdir -p " + os.environ['HOME'] + "/.config/fcitx/pinyin")

            # 1 to 2
            self.action_1to2()
            if not os.path.exists(self.txtpth1):
                return 2, "转换失败：" + self.txtpth1

            # # txt2mb
            # mb_new="/tmp/new.mb"
            # shrlt = shellexec("nohup txt2mb " + self.txtpth1 + " " + mb_new + " 2>&1 > /tmp/2to4.log")
            # if shrlt != 0:
            #     return 2, "文件2(.txt2) => 文件4(.dict)失败"

            # # 应用新词库
            # shrlt = shellexec("mv -f " + mb_new + " " + mbfile)
            # if shrlt != 0:
            #     return 2, ".txt1 转文件4(.mb) 失败"


            # 合并 3+2
            txttemp="/tmp/merged.txt"
            shrlt = shellexec("cat ./pinyin-data/pyPhrase.org \"" + self.txtpth1 + "\" > " + txttemp)
            if shrlt != 0:
                return 2, "文件3 和 文件2 合并失败"

            # txt2mb
            shrlt = shellexec("nohup createPYMB ./pinyin-data/gbkpy.org /tmp/merged.txt 2>&1 > /tmp/2to4.log")
            if shrlt != 0:
                return 2, ".txt1 转文件4(.mb) 失败"

            # 应用新词库
            mb_new="./pyphrase.mb"
            shrlt = shellexec("mv -f " + mb_new + " " + mbfile)
            if shrlt != 0:
                return 2, ".txt1 转文件4(.mb) 失败"
            
            mb_new="./pybase.mb"
            shrlt = shellexec("mv -f " + mb_new + " " + mbbase)
            if shrlt != 0:
                return 2, ".txt1 转文件4(.mb) 失败"




            # mbfile = os.environ['HOME'] + "/.config/fcitx/table/wbpy.mb"
            # if not os.path.exists(mbfile):
            #     shellexec("mkdir -p " + os.environ['HOME'] + "/.config/fcitx/table")
            #     shutil.copyfile("/usr/share/fcitx/table/wbpy.mb", mbfile)

            # if not os.path.exists(mbfile):
            #     return 2, "文件4(.mb) => 文件3(.txt1)失败，文件4不存在"

            # # 反编译
            # txtpth2="/tmp/dec.txt1"
            # shrlt = shellexec("mb2txt " + mbfile + " > " + txtpth2)
            # if shrlt != 0:
            #     return 2, "文件4(.mb) => 文件3(.txt1)失败，反编译失败"
            # if not os.path.exists(txtpth2):
            #     return 2, "文件不存在：" + txtpth2

            # # 1 to 2
            # self.action_1to2()
            # if not os.path.exists(self.txtpth1):
            #     return 2, "转换失败：" + self.txtpth1

            # # 合并 3+2
            # txttemp="/tmp/merged.txt"
            # shrlt = shellexec("cat \"" + txtpth2 + "\" \"" + self.txtpth1 + "\" > " + txttemp)
            # if shrlt != 0:
            #     return 2, "文件3 和 文件2 合并失败"
            
            # # txt2mb
            # mb_new="/tmp/new.mb"
            # shrlt = shellexec("nohup txt2mb " + txttemp + " " + mb_new + " 2>&1 > /tmp/2to4.log")
            # if shrlt != 0:
            #     return 2, ".txt1 转文件4(.mb) 失败"

            # # 应用新词库
            # shrlt = shellexec("mv -f " + mb_new + " " + mbfile)
            # if shrlt != 0:
            #     return 2, ".txt1 转文件4(.mb) 失败"


        return 0, "1to4 已完成，请重启输入法"

    def action_23to4(self):
        if self.txtpth1 == "":
            return 1,"请选择目标文件(文件2)"
        if self.txtpth2 == "":
            return 1,"请选择目标文件(文件3)"
        if self.dstpath == "":
            return 1,"请选择目标文件(文件4)"
        if not os.path.exists(self.txtpth1):
            return 2, "文件不存在：" + self.txtpth1
        if not os.path.exists(self.txtpth2):
            return 2, "文件不存在：" + self.txtpth2

        # 反编译 词库 => .txt*
        file_name, file_extension = os.path.splitext(self.dstpath)
        if self.dstpath.endswith(".mb"):
            if not self.txtpth1.endswith(".txt1") and not self.txtpth2.endswith(".txt1"):
                return 2, ".txt1 格式的明文词库才能转为 .mb 格式的词库"
            
            GLib.idle_add(self.window.setmesg, "正在转成.txt1格式")

            # 合并 .txt1
            shrlt = shellexec("cat \"" + self.txtpth2 + "\" \"" + self.txtpth1 + "\" > /tmp/tmp.txt1")
            if shrlt != 0:
                return 2, "文件3 和 文件2 合并失败"
            
            # txt2mb
            shrlt = shellexec("txt2mb /tmp/tmp.txt1 \"" + self.dstpath + "\"")
            if shrlt != 0:
                return 2, ".txt1 转文件4(.mb) 失败"

        elif self.dstpath.endswith(".dict"):
            if not self.txtpth2.endswith(".txt2"):
                return 2, "文件4(.dict)只能转为 .txt2 格式的明文词库"
            
            GLib.idle_add(self.window.setmesg, "正在转成.txt2格式")
        else:
            return 2, "不支持的格式：" + file_extension

        return 0, "1to2 已完成，请重启输入法"

    def action_1to2(self, writeHdr=False):
        if self.srcpath == "":
            return 1,"请选择待合并的文件(文件1)"
        if not os.path.exists(self.srcpath):
            return 2, "文件不存在：" + self.srcpath

        # 转换
        file_name, file_extension = os.path.splitext(self.dstpath)
        s = scel()
        text=''
        if self.txtpth1.endswith(".txt1"):
            GLib.idle_add(self.window.setmesg, "正在转成.txt1格式")
            s.load(self.srcpath)
            text = output_format1(s, writeHdr)
        elif self.txtpth1.endswith(".txt2"):
            GLib.idle_add(self.window.setmesg, "正在转成.txt2格式")
            s.load(self.srcpath)
            text = output_format2(s, writeHdr)
        elif self.txtpth1.endswith(".txt3"):
            GLib.idle_add(self.window.setmesg, "正在转成.txt3格式")
            s.load(self.srcpath)
            text = output_format3(s, writeHdr)
        else:
            return 2, "不支持的格式：" + file_extension

        # 保存为中间类型
        fp = open(self.txtpth1, 'w')
        fp.write(text)
        return 0, "1to2 已完成"

    def action_4to3(self):
        if self.dstpath == "":
            return 1,"请选择目标文件(文件4)"
        if not os.path.exists(self.dstpath):
            return 2, "文件不存在：" + self.dstpath

        # 反编译 词库 => .txt*
        file_name, file_extension = os.path.splitext(self.dstpath)
        if self.dstpath.endswith(".mb"):
            if not self.txtpth2.endswith(".txt1"):
                return 2, "文件4(.mb)只能转为 .txt1 格式的明文词库"
            
            GLib.idle_add(self.window.setmesg, "正在转成.txt1格式")
            shrlt = shellexec("mb2txt \"" + self.dstpath + "\" > \"" + self.txtpth2 + "\"")
            if shrlt != 0:
                return 2, "文件4(.mb) => 文件3(.txt1)失败"
        elif self.dstpath.endswith(".dict"):
            if not self.txtpth2.endswith(".txt2"):
                return 2, "文件4(.dict)只能转为 .txt2 格式的明文词库"
            
            GLib.idle_add(self.window.setmesg, "正在转成.txt2格式")
        else:
            return 2, "不支持的格式：" + file_extension

        return 0, "1to2 已完成"

    def run(self):
            rltcode=0
            rltmesg=""

            print(self.srcpath)
            print(self.txtpth1)
            print(self.txtpth2)
            print(self.dstpath)

            if self.strMode == "1to4":
                rltcode, rltmesg = self.action_1to4()
            elif self.strMode == "23to4":
                rltcode, rltmesg = self.action_23to4()
            elif self.strMode == "1to2":
                rltcode, rltmesg = self.action_1to2()
            elif self.strMode == "4to3":
                rltcode, rltmesg = self.action_4to3()

            GLib.idle_add(self.window.onComplete, rltcode, rltmesg)

            # GLib.idle_add(self.window.setmesg, "请选择待合并的文件(文件1)")

            # if self.dstpath == "":
            #     GLib.idle_add(self.window.setmesg, "请选择目标文件(文件4)")
            #     return

            # if os.path.exists(dstpath):
            #     ;
            # else:
            #     fp = open(dstpath, 'w')
            #     fp.write(text)
            # GLib.idle_add(self.window.onComplete, rltcode, rltmesg)


def getInternetPopularNewWords():
    """
        从搜狗输入法细胞词库官网下载网络流行新词【官方推荐】
        网址是 https://pinyin.sogou.com/dict/detail/index/4
        下载地址为 https://pinyin.sogou.com/d/dict/download_cell.php?id=4&name=%E7%BD%91%E7%BB%9C%E6%B5%81%E8%A1%8C%E6%96%B0%E8%AF%8D%E3%80%90%E5%AE%98%E6%96%B9%E6%8E%A8%E8%8D%90%E3%80%91&f=detail
        返回： scel文件的二进制 bytes
    """
    import requests
    url = "https://pinyin.sogou.com/d/dict/download_cell.php"
    params = {
        "id": 4,
        "name": "网络流行新词【官方推荐】",
        "f": "detal",
    }
    r = requests.get(url, params = params)
    return r.content


def shellexec(strcmd):
    try:
        print("正在运行指令：" + strcmd)
        process = subprocess.Popen(strcmd, shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE) #, cwd=os.environ['ZZSWMGR_WORK_DIR'], env={'ZZSWMGR_WORK_DIR':os.environ['ZZSWMGR_WORK_DIR']})
        # process.stdin.close()
        # process.stdout.close()
        process.wait()
        strout = process.stdout.read().decode("utf8")
        # print(strout)
        return process.returncode
    except Exception as e:
        print("" + e)
        return -1

def open_notepad(filepath):
    shellexec("notepad " + filepath)

def output_format0(s):
    text = ''
    for w in s.word_list:
        text += w[0] + '\t' + ''.join(map(lambda key:s.py_map[key], w[1])) + '\t' + str(1) + '\n'
    return text

def output_format1(s, writeHdr=False):
    text = ''

    if writeHdr:
        text = """;fcitx 版本 0x03 码表文件
键码=abcdefghijklmnopqrstuvwxy
码长=4
规避字符=;iuv
拼音=@
拼音长度=300
[组词规则]
e2=p11+p12+p21+p22
e3=p11+p21+p31+p32
a4=p11+p21+p31+n11
[数据]
"""

    for w in s.word_list:
        # text += '@' + '\''.join(map(lambda key:s.py_map[key], w[1])) + ' ' + w[0] + '\n'
        text += '@' + ''.join(map(lambda key:s.py_map[key], w[1])) + ' ' + w[0] + '\n'
    return text

def output_format2(s, writeHdr=False):
    text = ''

    if writeHdr:
        text = """KeyCode=abcdefghijklmnopqrstuvwxy
Length=4
Pinyin=@
[Rule]
e2=p11+p12+p21+p22
e3=p11+p21+p31+p32
a4=p11+p21+p31+n11
[Data]
"""

    for w in s.word_list:
        text += w[0] + '\t' + '\''.join(map(lambda key:s.py_map[key], w[1])) + '\t' + str(0) + '\n'
    return text

def output_format3(s, writeHdr=False):
    text = ''

    if writeHdr:
        text = """;fcitx 版本 0x03 码表文件
键码=abcdefghijklmnopqrstuvwxy
码长=4
规避字符=;iuv
拼音=@
拼音长度=300
[组词规则]
e2=p11+p12+p21+p22
e3=p11+p21+p31+p32
a4=p11+p21+p31+n11
[数据]
"""

    for w in s.word_list:
        # text += '@' + '\''.join(map(lambda key:s.py_map[key], w[1])) + ' ' + w[0] + '\n'
        text += '' + '\''.join(map(lambda key:s.py_map[key], w[1])) + ' ' + w[0] + '\n'
    return text



class Mainform(Gtk.Window):
    def __init__(self):
            super(Mainform,self).__init__(title=swtitle)
            self.set_default_size(600, 200)
            self.set_icon_from_file("./ic_imphrasetool.png")
            self.set_position(Gtk.WindowPosition.CENTER)

            self.grid = Gtk.Grid()
            self.add(self.grid)

            self.grid.set_border_width(20)
            self.grid.set_column_spacing(5)
            self.grid.set_row_spacing(10)

            txtReadme="" + \
                "软件说明：\n" + \
                "将下载的扩展词库(.scel)导入到fcitx4/fcix5的拼音输入法中\n" + \
                "注：仅支持软件管家中 fcitx-table*、fcitx5 两个系列的拼音输入法\n" + \
                "\n" + \
                "搜狗词库下载地址：<a href=\"https://pinyin.sogou.com/dict/\">https://pinyin.sogou.com/dict/</a>" + \
                "\n"

            rows = 0
            self.lblinfo = Gtk.Label(label="", xalign=0.5, yalign=0.5)
            self.lblinfo.set_markup(txtReadme)
            self.grid.attach(self.lblinfo, 0, rows, 100, 1)
            rows += 1

            wcolumn0 = 30
            wcolumn1 = 60
            wcolumn2 = 10

            # 搜索系统中已安装的fcitx系输入法
            self.lblinstalled = Gtk.Label(label="请选择输入法：", xalign=1.0)
            self.cmbInstalledIM = Gtk.ComboBoxText()
            # lstInstalledIM = Gtk.ListStore(str)
            shrlt = shellexec("which fcitx")
            if shrlt == 0:
                if os.path.exists("/usr/share/fcitx/pinyin/pybase.mb"):
                    self.cmbInstalledIM.append_text("fcitx4: 码表拼音输入法")
                if os.path.exists("/usr/share/fcitx/table/wbpy.mb"):
                    self.cmbInstalledIM.append_text("fcitx4: 码表五笔输入法")
                # files = os.listdir(os.environ['HOME'] + "/.config/fcitx/table")
                # for file in files:
                #     if not file.endswith(".mb"):
                #         continue
                #     self.cmbInstalledIM.append_text("fcitx4: " + file)
                # # self.cmbInstalledIM.append_text("fcitx4")
                # # lstInstalledIM.append(["fcitx4"])

            shrlt = shellexec("which fcitx5")
            if shrlt == 0:
                self.cmbInstalledIM.append_text("fcitx5: 码表拼音输入法")
                # self.cmbInstalledIM.append_text("fcitx5: 码表五笔输入法")
            #     files = os.listdir("/usr/share/libime")
            #     for file in files:
            #         if not file.endswith(".dict"):
            #             continue
            #         self.cmbInstalledIM.append_text("fcitx5: " + file)
            #     # lstInstalledIM.append(["fcitx5"])
            # # self.cmbInstalledIM.append_text("fcitx4: 创建新词库.mb")
            # # self.cmbInstalledIM.append_text("fcitx5: 创建新词库.dict")
            # # self.cmbInstalledIM.set_entry_text_column(0)
            self.grid.attach(self.lblinstalled, 0, rows, wcolumn0, 1)
            self.grid.attach_next_to(self.cmbInstalledIM, self.lblinstalled, Gtk.PositionType.RIGHT, wcolumn1, 1)
            rows += 1


            # self.align1 = Gtk.Alignment.new(1, 0.5, 0, 0)
            self.lblsrcpath = Gtk.Label(label="待导词库(文件1)：", xalign=1.0)
            self.txtsrcpath = Gtk.Entry()
            self.btnsrcpath = Gtk.Button(label="...")
            # self.btn2 = Gtk.Button(label="打开下载网址")
            self.lblsrcpath.set_justify(Gtk.Justification.RIGHT)

            # self.align1.add(self.lblsrcpath)
            self.grid.attach(self.lblsrcpath, 0, rows, wcolumn0, 1)
            self.grid.attach_next_to(self.txtsrcpath, self.lblsrcpath, Gtk.PositionType.RIGHT, wcolumn1, 1)
            self.grid.attach_next_to(self.btnsrcpath, self.txtsrcpath, Gtk.PositionType.RIGHT, wcolumn2, 1)
            # self.grid.attach_next_to(self.btn2,       self.btnsrcpath,       Gtk.PositionType.RIGHT, 12, 1)
            rows += 1

            self.lbltxtpth1 = Gtk.Label(label="明文词库(文件2)：", xalign=1.0)
            self.txttxtpth1 = Gtk.Entry(editable=False)
            self.btntxtpth1 = Gtk.Button(label="编辑")
            self.lbltxtpth1.set_justify(Gtk.Justification.RIGHT)

            self.grid.attach(self.lbltxtpth1, 0, rows, wcolumn0, 1)
            self.grid.attach_next_to(self.txttxtpth1, self.lbltxtpth1, Gtk.PositionType.RIGHT, wcolumn1, 1)
            self.grid.attach_next_to(self.btntxtpth1, self.txttxtpth1, Gtk.PositionType.RIGHT, wcolumn2, 1)
            rows += 1

            # self.lbltxtpth2 = Gtk.Label(label="明文词库(文件3)：", xalign=1.0)
            # self.txttxtpth2 = Gtk.Entry(editable=False)
            # # self.btntxtpth2 = Gtk.Button(label="编辑")
            # self.lbltxtpth2.set_justify(Gtk.Justification.RIGHT)

            # self.grid.attach(self.lbltxtpth2, 0, rows, wcolumn0, 1)
            # self.grid.attach_next_to(self.txttxtpth2, self.lbltxtpth2, Gtk.PositionType.RIGHT, wcolumn1, 1)
            # # self.grid.attach_next_to(self.btntxtpth2, self.txttxtpth2, Gtk.PositionType.RIGHT, wcolumn2, 1)
            # rows += 1

            self.lbldstpath = Gtk.Label(label="目标词库(文件4)：", xalign=1.0)
            self.txtdstpath = Gtk.Entry()
            self.btndstpath = Gtk.Button(label="...")
            self.lbldstpath.set_justify(Gtk.Justification.RIGHT)

            self.grid.attach(self.lbldstpath, 0, rows, wcolumn0, 1)
            self.grid.attach_next_to(self.txtdstpath, self.lbldstpath, Gtk.PositionType.RIGHT, wcolumn1, 1)
            self.grid.attach_next_to(self.btndstpath, self.txtdstpath, Gtk.PositionType.RIGHT, wcolumn2, 1)
            rows += 1

            # self.lblremark = Gtk.Label(label="目标文件存在就合并，不存在将会自动创建", xalign=0)
            # self.grid.attach(self.lblremark, wcolumn0, rows, wcolumn0, 1)
            # rows += 1

            self.btnappend1 = Gtk.Button(label="从文件1导入")
            self.btnappend2 = Gtk.Button(label="从文件2导入")
            self.grid.attach(self.btnappend1, wcolumn0, rows, wcolumn2, 1)
            # self.grid.attach_next_to(self.btnappend2, self.btnappend1, Gtk.PositionType.RIGHT, wcolumn2, 1)
            rows += 1

            # self.btnappend1 = Gtk.Button(label="文件1并入文件4")
            # self.btnappend2 = Gtk.Button(label="(2+3)转为文件4")
            # self.btnappend3 = Gtk.Button(label="文件1转为文件2")
            # self.btnappend4 = Gtk.Button(label="文件4转为文件3")
            # self.grid.attach(self.btnappend1, wcolumn0, rows, wcolumn2, 1)
            # self.grid.attach_next_to(self.btnappend2, self.btnappend1, Gtk.PositionType.RIGHT, wcolumn2, 1)
            # rows += 1
            # self.grid.attach(self.btnappend3, wcolumn0, rows, wcolumn2, 1)
            # self.grid.attach_next_to(self.btnappend4, self.btnappend3, Gtk.PositionType.RIGHT, wcolumn2, 1)
            # rows += 1

            self.lblresult = Gtk.Label(label="", xalign=0)
            self.grid.attach(self.lblresult, wcolumn0, rows, 100-wcolumn0, 1)



            self.cmbInstalledIM.connect('changed', self.on_im_combo_changed)
            self.btnsrcpath.connect("clicked", self.on_file1_clicked)
            self.btntxtpth1.connect("clicked", self.on_file2_clicked)
            self.btndstpath.connect("clicked", self.on_file3_clicked)
            self.btnappend1.connect("clicked", self.phraseAppend1)
            self.btnappend2.connect("clicked", self.phraseAppend2)
            # self.btnappend3.connect("clicked", self.phraseAppend3)
            # self.btnappend4.connect("clicked", self.phraseAppend4)

            self.cmbInstalledIM.set_active(0)

            self.set_focus(self.btnsrcpath)

            self.show_all()

            # shrlt = shellexec("which fcitx5")
            # if shrlt != 0:
            #     self.btnappend1.set_sensitive(False)
            #     self.btnappend2.set_sensitive(False)
            #     self.showmessage("提示", "fcitx5输入法未安装，请先在软件管家中安装fcitx5输入法！")

    def on_im_combo_changed(self, combo):
        global IMname
        IMname = combo.get_active_text()
        if IMname.startswith("fcitx4: 码表拼音输入法"):
            self.txttxtpth1.set_text("/tmp/user.txt3")
            self.txtdstpath.set_text("~/.config/fcitx/pinyin/pyphrase.mb")
            # self.txtdstpath.set_text("~/.config/fcitx/pyusrphrase.mb")
            
            # file = text.replace("fcitx4: ", "", 1);
            # self.txttxtpth1.set_text("/tmp/待合并.txt1")
            # self.txttxtpth2.set_text("/tmp/反编译.txt1")
            # self.txtdstpath.set_text(os.environ['HOME'] + "/.config/fcitx/table/" + file)
        elif IMname.startswith("fcitx4: 码表五笔输入法"):
            self.txttxtpth1.set_text("/tmp/user.txt1")
            self.txtdstpath.set_text("~/.config/fcitx/table/wbpy.mb")
            # file = text.replace("fcitx4: ", "", 1);
            # self.txttxtpth1.set_text("/tmp/待合并.txt1")
            # self.txttxtpth2.set_text("/tmp/反编译.txt1")
            # self.txtdstpath.set_text(os.environ['HOME'] + "/.config/fcitx/table/" + file)
        elif IMname.startswith("fcitx5: 码表拼音输入法"):
            self.txttxtpth1.set_text("/tmp/user.txt2")
            self.txtdstpath.set_text("~/.local/share/fcitx5/pinyin/dictionaries/user.dict")
            # file = text.replace("fcitx5: ", "", 1);
            # self.txttxtpth1.set_text("/tmp/待合并.txt2")
            # self.txttxtpth2.set_text("/tmp/反编译.txt2")
            # self.txtdstpath.set_text("/usr/share/libime/" + file)
        elif IMname.startswith("fcitx5: 码表五笔输入法"):
            self.txttxtpth1.set_text("/tmp/user.txt2")
            self.txtdstpath.set_text("~/.local/share/fcitx5/table/wbpy.user.dict")
        # else:
        #     self.txttxtpth1.set_text("/tmp/待合并.txt2")
        #     self.txttxtpth2.set_text("/tmp/反编译.txt2")
        #     self.txtdstpath.set_text("/tmp/test.dict")

    def phraseAppend1(self, button):
        self.phraseAppend("1to4")

    def phraseAppend2(self, button):
        self.phraseAppend("23to4")

    def phraseAppend3(self, button):
        self.phraseAppend("1to2")

    def phraseAppend4(self, button):
        self.phraseAppend("4to3")

    def phraseAppend(self, strMode):
        self.lblresult.set_text("")
        srcpath = self.txtsrcpath.get_text().strip(' ')
        txtpth1 = self.txttxtpth1.get_text().strip(' ')
        # txtpth2 = self.txttxtpth2.get_text().strip(' ')
        txtpth2 = ''
        dstpath = self.txtdstpath.get_text().strip(' ')
        worker=WorkerAppend(self, strMode, srcpath, txtpth1, txtpth2, dstpath)
        worker.start()

    def setmesg(self, resmesg):
        self.lblresult.set_text(resmesg)

    def onComplete(self, rescode, resmesg):
        if rescode != 0:
            self.lblresult.set_text("错误码：" + str(rescode) + " => " + resmesg)
        else:
            self.lblresult.set_text(resmesg)

    def on_file1_clicked(self, widget):
        dialog = Gtk.FileChooserDialog(
            title="请选择您下载的scel文件", parent=self, action=Gtk.FileChooserAction.OPEN
        )
        dialog.add_buttons(
            Gtk.STOCK_CANCEL,
            Gtk.ResponseType.CANCEL,
            Gtk.STOCK_OPEN,
            Gtk.ResponseType.OK,
        )

        # self.add_filters(dialog)
        filter_text = Gtk.FileFilter()
        filter_text.set_name(".scel搜狗词库")
        # filter_text.add_mime_type("text/plain")
        filter_text.add_pattern("*.scel")
        dialog.add_filter(filter_text)

        # filter_text = Gtk.FileFilter()
        # filter_text.set_name(".txt1明文格式")
        # filter_text.add_pattern("*.txt1")
        # dialog.add_filter(filter_text)

        # filter_text = Gtk.FileFilter()
        # filter_text.set_name(".txt2明文格式")
        # filter_text.add_pattern("*.txt2")
        # dialog.add_filter(filter_text)

        response = dialog.run()
        if response == Gtk.ResponseType.OK:
            self.txtsrcpath.set_text(dialog.get_filename())
            # self.txttxtpth1.set_text("/tmp/user.txt2")
            # self.txtdstpath.set_text("~/.local/share/fcitx5/pinyin/dictionaries/user.dict")
        elif response == Gtk.ResponseType.CANCEL:
            self.txtsrcpath.set_text("")
            self.txttxtpth1.set_text("")
            self.txtdstpath.set_text("")

        dialog.destroy()

    def on_file2_clicked(self, widget):
        txt = self.txttxtpth1.get_text()
        tmpthread = threading.Thread(target=open_notepad, args=(txt,))
        tmpthread.start()

    def on_file3_clicked(self, widget):
        dialog = Gtk.FileChooserDialog(
            title="导出或合并到此文件", parent=self, action=Gtk.FileChooserAction.SAVE, # or Gtk.FILE_CHOOSER_ACTION_CREATE_FOLDER,
            # initialdir='~/.config/fcitx/table'
        )
        dialog.add_buttons(
            Gtk.STOCK_CANCEL,
            Gtk.ResponseType.CANCEL,
            Gtk.STOCK_OPEN,
            Gtk.ResponseType.OK,
        )

        # self.add_filters(dialog)
        filter_text = Gtk.FileFilter()
        filter_text.set_name(".mb")
        # filter_text.add_mime_type("text/plain")
        filter_text.add_pattern("*.mb")
        dialog.add_filter(filter_text)

        filter_text = Gtk.FileFilter()
        filter_text.set_name(".dict")
        # filter_text.add_mime_type("text/plain")
        filter_text.add_pattern("*.dict")
        dialog.add_filter(filter_text)

        filter_text = Gtk.FileFilter()
        filter_text.set_name(".txt1明文格式")
        filter_text.add_pattern("*.txt1")
        dialog.add_filter(filter_text)

        filter_text = Gtk.FileFilter()
        filter_text.set_name(".txt2明文格式")
        filter_text.add_pattern("*.txt2")
        dialog.add_filter(filter_text)

        filter_text = Gtk.FileFilter()
        filter_text.set_name("显示所有类型的文件")
        filter_text.add_pattern("*")
        dialog.add_filter(filter_text)

        response = dialog.run()
        if response == Gtk.ResponseType.OK:
            self.txtdstpath.set_text(dialog.get_filename())
        elif response == Gtk.ResponseType.CANCEL:
            self.txtdstpath.set_text("")

        dialog.destroy()

    def showmessage(self, strtitle, strmessage):
        # Gtk.MessageType.ERROR
        # Gtk.MessageType.INFO  # https://qytz-notes.readthedocs.io/tech/PyGObject-Tutorial/dialogs.html
        dialog = Gtk.MessageDialog(
                transient_for=self,
                # flags=Gtk.DialogFlags.MODAL,
                modal=True,
                message_type=Gtk.MessageType.INFO,
                buttons=Gtk.ButtonsType.CANCEL,
                text=strtitle,
        )
        dialog.format_secondary_text(strmessage)
        btn = dialog.get_widget_for_response(Gtk.ResponseType.CANCEL)
        btn.set_label("好的")
        dialog.run()
        dialog.destroy()

def main(args):
    global parser
    global win
    s = scel()

    if args.file is None:
        # parser.print_help()
        # sys.exit(1)

        # 没有指定file参数，就启动图形界面
        win = Mainform()
        win.connect("destroy",Gtk.main_quit)
        win.show_all()
        return Gtk.main()

    # 读取 scel
    s.load(args.file)

    # 产生指定格式的输出
    text=''
    if args.f0:
        text = output_format0(s)
    if args.f1:
        text = output_format1(s)
    if args.f2:
        text = output_format2(s)
    if args.f3:
        text = output_format3(s)
    else:
        text = output_format0(s)

    # 显示到终端，或者保存到文件
    if args.dest is None:
        fp = sys.stdout
    else:
        fp = open(args.dest, 'w')
    fp.write(text)

if __name__ == '__main__':
    # 获取脚本所在目录的路径
    script_dir = os.path.dirname(os.path.abspath(__file__))
    # 更改工作目录为脚本所在目录
    os.chdir(script_dir)

    parser = argparse.ArgumentParser()
    parser.description = "搜狗细胞词库（.scel）转换工具，支持多种txt输出格式。"
    parser.epilog = '使用示例：%(prog)s 1.scel -f0 -o output.txt'
    parser.add_argument('-f0', dest='f0', help='输出格式为："词条\\t编码\\t优先级"', action='store_true')
    parser.add_argument('-f1', dest='f1', help='输出格式为："编码 词条", 此格式可通过txt2mb工具转成.mb格式', action='store_true')
    parser.add_argument('-f2', dest='f2', help='输出格式为："词条 编码 词频"(编码带\'分隔符), 此格式可通过libime_pinyindict/libime_tabledict工具转成.dict格式', action='store_true')
    parser.add_argument('-f3', dest='f3', help='输出格式为："编码 词条"(编码带\'分隔符)', action='store_true')
    parser.add_argument(dest='file', help = '搜狗细胞词库文件，格式为 .scel', nargs='?')
    parser.add_argument(dest='dest', help = '输出的txt文件名', nargs='?')

    args = parser.parse_args()
    # print('' + str(args.f0))
    # print('' + str(args.f1))
    exit(main(args))
