#!/usr/bin/python3

# 参考：https://python-gtk-3-tutorial.readthedocs.io/en/latest/
#       https://athenajc.gitbooks.io/python-gtk-3-api/content/
#       https://pygobject.readthedocs.io/en/latest/guide/threading.html
#       https://pygobject.readthedocs.io/en/latest/guide/threading.html
#
# pack_start(self.paned_box, expand=True, fill=True, padding=0)
# ln -s python3 python
#

import gi
import os
import sys
import subprocess
import threading
import logging
import utils
from utils import DialogSUDO
from utils import WorkerExec
from swgroups import SWGROUPNAMES
from swgroups import SWGROUP
from swgroups import SWPROPS
from swgroups import SoftWareProps
from swgroups import SWSOURCE
from swgroups import SoftWareSource
from swgroups import SWARCH
from swgroups import SWOP
from softwares import SW
from softwares import SoftWareList


gi.require_version("Gtk", "3.0")
from gi.repository import Gtk
from gi.repository import GLib

swtitle = '正卓软件管家linux版'
swver = '1.0'
win = None
utils.init_logger()
logger = utils.get_logger()
str_supwd=""
fn_installed = './installed.txt'
fn_local_deb = './tmp/localdeb_to_installed.txt'
sw_installed = utils.file_get_content_as_array(fn_installed)
swinstalling = False
def_visible_groupid = 0
tmp_deb_path = None
auto_click_switem = None

# 获取脚本所在目录的路径
script_dir = os.path.dirname(os.path.abspath(__file__))
# 更改工作目录为脚本所在目录
os.chdir(script_dir)
os.environ['ZZSWMGR_WORK_DIR'] = script_dir



class WorkerInstall(threading.Thread):

    def __init__(self, switem, strcmd_install):
            threading.Thread.__init__(self)
            self.switem = switem
            self.strcmd_install = strcmd_install
            self.strpwd = ""
    def run(self):
            global win
            global logger

            logger.info("正在启动安装脚本...")
            curr_display=os.getenv('DISPLAY')
            with open('./scripts/display.sh', 'w') as f:
                  f.write('export DISPLAY='+curr_display)
            if self.switem.needsu:
                  rescode = utils.sudo(self.strcmd_install, self.strpwd)
                  # rescode = utils.exec(self.strcmd_install)
                  logger.info("rescode: " + str(rescode))
                  GLib.idle_add(self.switem.onInstallComplete, rescode, "")
            else:
                  rescode = utils.exec(self.strcmd_install)
                  logger.info("rescode: " + str(rescode))
                  GLib.idle_add(self.switem.onInstallComplete, rescode, "")


def do_install(switem):
      global win
      global logger
      global script_dir
      global str_supwd

      swname = switem.sw.name
      fnlog = switem.get_log_filename()
      rescode = utils.exec("echo '正在" + switem.straction + " " + swname + "'>\"" + fnlog + "\"")
      logger.info("rescode: " + str(rescode))
      rescode = utils.exec("chmod 755 " + switem.sw.script + ">>\""+fnlog+"\" 2>>\""+ fnlog + "\"")
      logger.info("rescode: " + str(rescode))

      strcmd_install = switem.sw.script + " " + switem.straction + ">>\""+fnlog+"\" 2>>\""+ fnlog + "\""
      worker=WorkerInstall(switem, strcmd_install)

      if switem.needsu:
            logger.info("提升运行权限")

            rescode = utils.exec("sudo -n echo")

            if rescode == 0 or str_supwd != "":
                  worker.strpwd = str_supwd
                  worker.start()
            else:
                  dialog = DialogSUDO(win, strcmd_install)
                  rescode = dialog.start()
                  logger.info("rescode: " + str(rescode))
                  if rescode != 0:
                        logger.info("权限提升失败")
                        str_supwd=""
                        GLib.idle_add(switem.onInstallComplete, rescode, "")
                  else:
                        os.chdir(script_dir)
                        str_supwd=dialog.strpwd
                        worker.strpwd = str_supwd
                        worker.start()
                  dialog.destroy()
      else:
            worker.start()



class SWItem(Gtk.FlowBox):
      def __init__(self, swbox, sw):
            global sw_installed
            global tmp_deb_path
            global auto_click_switem

            super(SWItem,self).__init__()
            self.orientation=Gtk.Orientation.VERTICAL
            # self.set_valign(Gtk.Align.START)
            self.set_max_children_per_line(1)
            self.set_selection_mode(Gtk.SelectionMode.NONE)
            self.border_width = 100

            self.swbox = swbox
            self.sw = sw
            self.installed = False
            self.updateui()

            if tmp_deb_path != None and tmp_deb_path in self.sw.info:
                  # if auto_click_switem != None:
                        auto_click_switem = self


      def clearui(self):
            childs = self.get_children()
            for child in childs:
                  self.remove(child)

      def getsw_label_string(self):
            rlt = self.sw.name
            if self.sw.deprecated:
                  rlt = rlt + "(已废弃)"
            elif self.sw.recommend:
                  rlt = rlt + "(推荐)"
            return rlt

      def updateui(self):
            # print(self.sw.name)
            if self.sw.name + "\n" in sw_installed:
                  self.installed = True

            self.headerbar = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
            # self.headerbar.set_valign(Gtk.Align.START)
            # self.headerbar.set_max_children_per_line(20)
            # self.headerbar.set_selection_mode(Gtk.SelectionMode.NONE)

            # self.str_properties = ""
            # self.lbprop = Gtk.Label(label=self.str_properties)
            # self.lbprop.set_justify (Gtk.Justification.LEFT)

            # self.lbName = Gtk.Label(label=self.sw.name + ("(已废弃)" if self.sw.deprecated else "") )
            self.lbName = Gtk.Label(label=self.getsw_label_string() )
            self.lbName.set_justify (Gtk.Justification.LEFT)

            self.btnShowlog = Gtk.Button.new_with_label("日志")
            self.btnShowlog.connect("clicked", self.showlog)

            self.lbStatus = Gtk.Label(label="")
            self.lbStatus.set_justify (Gtk.Justification.LEFT)

            tmpstr = "软件来源：" + SoftWareSource[self.sw.dlsource.value]
            if self.sw.version != "":
                  tmpstr += "\n　版本号：" + self.sw.version
            if self.sw.timecost != "":
                  tmpstr += "\n安装耗时：" + self.sw.timecost
            if SWPROPS.sysdir in self.sw.props and not self.installed:
                  tmpstr += "\n其它信息：" + SoftWareProps[1]

            self.tvInfo = Gtk.TextView()
            self.tvInfo.set_editable(False)
            self.textbuffer = self.tvInfo.get_buffer()
            self.textbuffer.set_text(tmpstr + "\n软件介绍：" + self.sw.info + "\n")

            self.headerbar.pack_start(self.lbName, False, False, 5)
            if self.installed:
                  self.btnRemove = Gtk.Button.new_with_label("卸载")
                  self.btnRemove.connect("clicked", self.onButtonInstallClicked)
                  self.btnRemove.straction="卸载"
                  self.btnInstall = Gtk.Button.new_with_label("重装")
                  self.btnInstall.connect("clicked", self.onButtonInstallClicked)
                  self.btnInstall.straction="重装"
                  self.headerbar.pack_start(self.btnRemove, False, False, 5)
                  self.headerbar.pack_start(self.btnInstall, False, False, 5)
                  self.headerbar.pack_start(self.btnShowlog, False, False, 5)
                  # self.headerbar.pack_start(self.lbprop, False, False, 5)
            else:
                  self.btnInstall = Gtk.Button.new_with_label("安装")
                  self.btnInstall.connect("clicked", self.onButtonInstallClicked)
                  self.btnInstall.straction="安装"
                  self.btnShowlog.set_sensitive(False)
                  self.headerbar.pack_start(self.btnInstall, False, False, 5)
                  self.headerbar.pack_start(self.btnShowlog, False, False, 5)
                  # self.headerbar.pack_start(self.lbprop, False, False, 5)


            self.setStatusMsg(self.sw.straction)
            if self.sw.swop == SWOP.installing:
                  self.btnInstall.set_sensitive(False)
            
            if self.sw.swop == SWOP.reinstalling:
                  self.btnInstall.set_sensitive(False)
                  self.btnRemove.set_sensitive(False)

            if self.sw.swop == SWOP.removing:
                  self.btnInstall.set_sensitive(False)
                  self.btnRemove.set_sensitive(False)

            if self.sw.swop == SWOP.fail:
                  self.btnShowlog.set_sensitive(True)
            
            self.headerbar.pack_start(self.lbStatus, False, False, 5)

            self.add(self.headerbar)
            self.add(self.tvInfo)

            separator = Gtk.Separator(orientation=Gtk.Orientation.HORIZONTAL)
            self.add(separator)
            # self.show_all()

      def setStatusMsg(self, msg):
            # self.lbStatus.set_text("<b>" + msg + "</b>")
            self.lbStatus.set_markup("<b>" + msg + "</b>")
            self.sw.straction = msg
            
      # def getsw(self):
      #       rlt = []
      #       for index, sw in enumerate(SoftWareList):
      #             if self.script == sw.script:
      #                   rlt.append(sw)
      #       return rlt

      def onButtonInstallClicked(self, btn):
            global win
            global logger
            global swinstalling

            if swinstalling:
                  win.showmessage("提示", "linux软件只能装完一个再装下一个，不能同时安装！")
                  return

            win.showmessage("提示", "手机的省电机制会杀后台应用，所以安装或卸载软件时\n\n请保持虚拟电脑始终【处于前台运行】！")

            self.needsu = SWPROPS.sysdir in self.sw.props
            self.straction = btn.straction
            if self.straction == "重装":
                  self.sw.swop = SWOP.reinstalling
                  self.btnInstall.set_sensitive(False)
                  self.btnRemove.set_sensitive(False)
            if self.straction == "卸载":
                  self.sw.swop = SWOP.removing
                  self.btnInstall.set_sensitive(False)
                  self.btnRemove.set_sensitive(False)
            if self.straction == "安装":
                  self.sw.swop = SWOP.installing
                  self.btnInstall.set_sensitive(False)

            self.setStatusMsg("正在" + self.straction)
            do_install(self)
            swinstalling = True

      def onInstallComplete(self, rescode, resmsg):
            global logger
            global fn_installed
            global sw_installed
            global swinstalling

            swinstalling = False
            self.sw.swop=SWOP.none

            if self.needsu:
                  logger.info("正在降权")
                  utils.releaseSuperRight()

            if self.straction == "安装":
                  if rescode == 0:
                        # # if "本地deb包" != self.sw.name:
                        utils.file_append(fn_installed, self.sw.name + "\n")
                        sw_installed.append(self.sw.name + "\n")
                        self.setStatusMsg(self.straction + "完成")
                  else:
                        self.setStatusMsg(self.straction + "失败，点击日志按钮查看错误信息")
                        self.btnInstall.set_sensitive(True)
                        self.sw.swop = SWOP.fail
                  self.btnShowlog.set_sensitive(True)
            if self.straction == "重装":
                  if rescode == 0:
                        self.setStatusMsg(self.straction + "完成")
                  else:
                        self.setStatusMsg(self.straction + "失败，点击日志按钮查看错误信息")
                        self.btnInstall.set_sensitive(True)
                        self.btnRemove.set_sensitive(True)
                        self.sw.swop = SWOP.fail
                  self.btnShowlog.set_sensitive(True)
            if self.straction == "卸载":
                  if rescode == 0:
                        sw_installed.remove(self.sw.name + "\n")
                        utils.file_put_content_array(fn_installed, sw_installed)
                        self.setStatusMsg(self.straction + "完成")
                  else:
                        self.setStatusMsg(self.straction + "失败，点击日志按钮查看错误信息")
                        self.btnRemove.set_sensitive(True)
                        self.sw.swop = SWOP.fail
                  self.btnShowlog.set_sensitive(True)

            self.straction = "";
            self.swbox.loadsw()
      # end func

      def get_log_filename(self):
            return "./logs/" + self.sw.name + ".log"

      def showlog(self, button):
            fnlog = self.get_log_filename()
            strcmd = "notepad \""+ fnlog + "\" &"
            worker=WorkerExec(strcmd)
            worker.start()


class SWBox(Gtk.ScrolledWindow):
      def __init__(self):
            global def_visible_groupid
            super(SWBox,self).__init__()

            self.visible_groupid = def_visible_groupid
            self.search_keywords = ""

            self.vexpand = True
            self.set_vexpand(True)
            self.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)

            box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
            self.add(box)

            # self.scrollarea = Gtk.ScrolledWindow()
            # self.pack_start(self.scrollarea, True, True, 5)

            self.flowbox = Gtk.FlowBox(orientation=Gtk.Orientation.HORIZONTAL)
            self.flowbox.set_valign(Gtk.Align.START)
            self.flowbox.set_max_children_per_line(1)
            self.flowbox.set_selection_mode(Gtk.SelectionMode.NONE)
            # self.add(self.flowbox)

            box.pack_start(self.flowbox, True, True, 5)

            self.loadsw()

      def clearsw(self):
            childs = self.flowbox.get_children()
            for child in childs:
                  self.flowbox.remove(child)
      
      def loadsw(self):
            self.clearsw()

            for index, sw in enumerate(SoftWareList):
                  sw.index = index
                  if self.search_keywords != "":
                        if self.search_keywords in sw.name or self.search_keywords in sw.info:
                              item = SWItem(self, sw)
                              self.flowbox.add(item)
                              # continue
                  else:
                        # if self.visible_groupid < 0:
                        #       item = SWItem(self, sw)
                        #       self.flowbox.add(item)
                        #       break
                        # elif self.visible_groupid == 0:
                        #       item = SWItem(self, sw)
                        #       self.flowbox.add(item)
                        #       # continue
                        # else:
                        #       gid = SWGROUP(self.visible_groupid)
                        #       if gid in sw.groups:
                        #             item = SWItem(self, sw)
                        #             self.flowbox.add(item)
                        if self.visible_groupid >= 0:
                              gid = SWGROUP(self.visible_groupid)
                              if gid in sw.groups:
                                    item = SWItem(self, sw)
                                    self.flowbox.add(item)
            self.show_all()

      def set_visible_groupid(self, gid):
            self.search_keywords = ""
            self.visible_groupid = gid
            self.loadsw()


class Mainform(Gtk.Window):
      def __init__(self):
            super(Mainform,self).__init__(title=swtitle)
            self.set_default_size(850, 1000)
            self.set_icon_from_file("./ic_zzswmgr.png")
            self.set_position(Gtk.WindowPosition.CENTER)

            container = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
            container.set_border_width(12)

            self.paned_main = Gtk.Paned()
            container.pack_start(self.paned_main, True, True, 0)


            self.vbox_left = Gtk.ScrolledWindow()
            self.vbox_left.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
            self.paned_main.add1(self.vbox_left)

            self.vbox_right = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
            self.paned_main.add2(self.vbox_right)

            self.createui_left()
            self.createui_right()

            container.show_all()
            self.add(container)

      def createui_left(self):
            flowbox = Gtk.FlowBox()
            flowbox.set_valign(Gtk.Align.START)
            flowbox.set_max_children_per_line(1)
            flowbox.set_selection_mode(Gtk.SelectionMode.NONE)
            flowbox.set_margin_right(12)
            self.vbox_left.add(flowbox)

            label_logo = Gtk.Label()
            label_logo.set_text("　版本号：" + swver + "  \n许可协议：MIT\n")
            flowbox.add(label_logo)

            button = Gtk.Button.new_with_label("更新软件管家")
            button.connect("clicked", self.onBtnUpdateClicked)
            flowbox.add(button)

            label_seprator = Gtk.Label()
            label_seprator.set_text("　")
            flowbox.add(label_seprator)

            # 不要了
            # button = Gtk.Button.new_with_label("安装本地DEB包")
            # button.connect("clicked", self.onBtnDebInstallClicked)
            # flowbox.add(button)

            for index, group in enumerate(SWGROUPNAMES):
                  button = Gtk.Button.new_with_label(group)
                  button.gid = index
                  button.connect("clicked", self.onButtonClicked)
                  button.set_margin_bottom(12)
                  flowbox.add(button)

      def createui_right(self):
            global def_visible_groupid
            
            # paned_body = Gtk.Paned(orientation=Gtk.Orientation.VERTICAL)
            # self.vbox_right.add(paned_body)
            # self.vbox_right.pack_start(paned_body, True, True, 0)

            # 上
            # vbox_top = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
            # vbox_top.set_size_request(-1, 50)
            # # paned_body.add1(vbox_top)

            hbox_top = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
            # hbox_top = Gtk.Grid()
            self.vbox_right.pack_start(hbox_top, False, False, 10)
            self.searchentry = Gtk.SearchEntry()
            self.searchentry.connect("activate", self.onSearchInputChanged)
            label = Gtk.Label(label="")
            button = Gtk.Button(label="清空下载目录"); button.connect("clicked", self.onBtnClearDirDownload)

            hbox_top.pack_start(self.searchentry, False, False, 10)
            hbox_top.pack_start(label, False, False, 10)
            hbox_top.pack_start(button, False, False, 10)

            button = Gtk.Button(label="查看日志"); button.connect("clicked", self.onBtnShowLogClicked)
            hbox_top.pack_start(button, False, False, 10)
            button = Gtk.Button(label="清空日志"); button.connect("clicked", self.onBtnClearLogClicked)
            hbox_top.pack_start(button, False, False, 10)
            button = Gtk.Button(label="提交脚本"); button.connect("clicked", self.onBtnNewSWClicked)
            hbox_top.pack_start(button, False, False, 10)

            # hbox_top.add(self.searchentry)
            # hbox_top.add(label)

            # 下
            self.swbox = SWBox()
            # paned_body.add2(self.swbox)
            self.vbox_right.pack_start(self.swbox, True, True, 0)

            if def_visible_groupid == 1:
                  GLib.idle_add(self.auto_click)

      def auto_click(self):
            global auto_click_switem
            # print(dir(auto_click_switem))
            if auto_click_switem != None:
                  auto_click_switem.btnInstall.clicked.invoke(auto_click_switem.btnInstall)
            # global tmp_deb_path
            # childs = self.swbox.flowbox.get_children()
            # for item in childs:
            #       # print(dir(item))
            #       # break
            #       if tmp_deb_path in item.sw.info:
            #             item.btnInstall.click()

            

      def onBtnDebInstallClicked(self, button):
            # self.showmessage("功能未开放", "功能暂未开放使用")
            SoftWareList.insert(0,
                  SW( [-1], [SWPROPS.sysdir], [SWARCH.arm64, SWARCH.amd64],
                        "本地deb包", 
                        "",
                        "",
                        "点击 安装 按钮选择本地包", 
                        "./scripts/debinstall.sh",
                        SWSOURCE.thirdpary,
            ))
            self.swbox.set_visible_groupid(-1)

      def onBtnUpdateClicked(self, button):
            # utils.exec("/exbin/tools/vm_updateBootScript.sh")
            strcmd = "/exbin/tools/vm_updateBootScript.sh"
            worker=WorkerExec(strcmd)
            worker.start()

      def onButtonClicked(self, button):
            self.swbox.set_visible_groupid(button.gid)

      def onBtnNewSWClicked(self, button):
            global logger
            # scrollinfo = self.swbox.get_vadjustment()
            # logger.info("    lower: " + str(scrollinfo.get_lower()))
            # logger.info(" page_inc: " + str(scrollinfo.get_page_increment()))
            # logger.info("page_size: " + str(scrollinfo.get_page_size()))
            # logger.info(" step_inc: " + str(scrollinfo.get_step_increment()))
            # logger.info("    upper: " + str(scrollinfo.get_upper()))
            # logger.info("    value: " + str(scrollinfo.get_value()))
            # logger.info("")
            # self.showmessage("功能未开放", "新增收录软件功能暂未开放")
            self.showmessage("感谢您的关注！", "请访问开源仓库提交：\nhttps://gitee.com/droidvm/linux-installer-for-droidvm")

      def onBtnShowLogClicked(self, button):
            fnlog = utils.FILENAME_LOG
            strcmd = "notepad "+ fnlog + " &"
            worker=WorkerExec(strcmd)
            worker.start()

      def onBtnClearLogClicked(self, button):
            fnlog = utils.FILENAME_LOG
            strcmd = "rm -rf "+ fnlog
            worker=WorkerExec(strcmd)
            worker.start()

      def onBtnClearDirDownload(self, button):
            button.set_label("正在删除")
            # strcmd = ""
            # worker=WorkerExec(strcmd)
            # worker.start()
            utils.exec("rm -rf ./downloads/*")
            # utils.exec("gxmessage -title \"已清空\" -center")
            self.showmessage("提示", "下载目录已经清空")
            button.set_label("清空下载目录")

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

      def onSearchInputChanged(self, entry):
            entry.select_region(0, -1)
            txt = entry.get_text()
            self.swbox.search_keywords = txt
            # GLib.idle_add(self.swbox.loadsw)
            self.swbox.loadsw()

def main():
      global win

      # 软件管家运行中重启xserver，这个就不可靠了
      # if os.path.exists('/tmp/zzswmgr.running'):
      #       exit()
      # else:
      #       with open('/tmp/zzswmgr.running', 'w') as f:
      #             f.write('flag')

      win = Mainform()
      win.connect("destroy",Gtk.main_quit)
      win.show_all()
      Gtk.main()
      # os.remove('/tmp/zzswmgr.running')




# 打印当前工作目录
print("当前工作目录：", os.getcwd())
utils.exec("chmod 755 ./scripts/*.sh")
utils.exec("[ -d downloads ] || mkdir downloads")
utils.exec("[ -d logs      ] || mkdir logs")
utils.exec("[ -d tmp       ] || mkdir tmp")
utils.exec("cp -f ./zzswmgr.desktop /usr/share/applications/")
utils.exec("cp -f ./zzswmgr.desktop /home/droidvm/Desktop/")
utils.exec("whoami > ./tmp/whoami.txt")

argc=len(sys.argv)
if argc > 1:
      # print ('脚本名:', str(sys.argv[0]))
      # lxterminal -e 

      def_visible_groupid = 1
      tmp_deb_path = sys.argv[1]

      rescode=utils.exec("./scripts/debImport.sh \"" + sys.argv[1] + "\"")
      print ('退出码:', rescode)
      if rescode != 0:
            sys.exit(0)

DIR_USER_INC=os.environ['HOME'] + '/.zzswmgr'
if os.path.exists(DIR_USER_INC + '/localdeb.py'):
      sys.path.append(DIR_USER_INC)
      import localdeb
      # localdeb.load()

main()
