
# 参考：https://python-gtk-3-tutorial.readthedocs.io/en/latest/
# ln -s python3 python

import gi
import os
import subprocess
import asyncio
import utils
import time
import threading
import logging


gi.require_version("Gtk", "3.0")
from gi.repository import Gtk

strpipe2devnull=">/dev/null 2>/dev/null"
strpipe2devnull=""
FILENAME_LOG='./日志.txt'

logging.basicConfig(filename=FILENAME_LOG,
                    format='%(asctime)s %(filename)-15s#L%(lineno)-5d %(levelname)s: %(message)s',
                    datefmt='%y%m%d %H:%M:%S',
                    level=logging.DEBUG)

def init_logger():
    global _logger
    _logger = logging.getLogger(__name__)

def get_logger():
    global _logger
    return _logger

def file_get_content_as_array(str_file_name):
    try:
        f = open(str_file_name)
        arr = f.readlines()
        f.close()
        return arr
    except IOError:
        return []

def file_put_content_array(str_file_name, arr):
    try:
        str = ''.join(arr)
        file = open(str_file_name, 'w')
        file.write(str)
        file.close()
        return True
    except Exception as ex:
        return False

def file_puts(str_file_name, str):
    try:
        file = open(str_file_name, 'w')
        file.write(str)
        file.close()
        return True
    except Exception as ex:
        return False

def file_append(str_file_name, str):
    try:
        file = open(str_file_name, 'a')
        file.write(str)
        file.close()
        return True
    except Exception as ex:
        return False

def exec(strcmd):
    global _logger
    try:
        _logger.info("正在运行指令：" + strcmd)
        process = subprocess.Popen(strcmd, shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE) #, cwd=os.environ['ZZSWMGR_WORK_DIR'], env={'ZZSWMGR_WORK_DIR':os.environ['ZZSWMGR_WORK_DIR']})
        # process.stdin.close()
        # process.stdout.close()
        process.wait()
        strout = process.stdout.read().decode("utf8")
        _logger.info(strout)
        return process.returncode
    except Exception as e:
        _logger.info("" + e)
        return -1

def sudo(strcmd, strpwd):
    global _logger
    try:
        strpwd = strpwd + "\n"
        strcmd = "sudo -D " + os.environ['ZZSWMGR_WORK_DIR'] + " -S -p \"\" " + strcmd
        _logger.info("正在运行指令：" + strcmd)
        process = subprocess.Popen(strcmd, shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE) #, cwd=os.environ['ZZSWMGR_WORK_DIR'], env={'ZZSWMGR_WORK_DIR':os.environ['ZZSWMGR_WORK_DIR']})
        process.stdin.write(strpwd.encode("utf-8"))
        process.stdin.close() # 不需要 sudo retry, 所以直接关闭stdin
        process.wait()
        rescode = process.returncode
        # strout = process.stdout.read().decode("utf8")
        # _logger.info("sudo strout: " + strout)
        # if "已获取超级权限" in strout:
        #     rescode = 0
        # else:
        #     rescode = -1
        _logger.info("sudo rescode: " + str(rescode))
        return rescode
    except Exception as e:
        _logger.info("" + e)
        return -1

def hasSuperRight():
    global _logger
    rescode = exec("sudo -n -v" + strpipe2devnull)
    _logger.info("hasSuperRight: " + str(rescode))
    return (rescode == 0)

def getSuperRight(strpwd):
    global _logger
    strpwd = strpwd + "\n"
    process = subprocess.Popen("sudo -S -p \"\" -v >/dev/null 2>/dev/null", shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE) #, cwd=os.environ['ZZSWMGR_WORK_DIR'], env={'ZZSWMGR_WORK_DIR':os.environ['ZZSWMGR_WORK_DIR']})
    process.stdin.write(strpwd.encode("utf-8"))
    process.stdin.close() # 不需要 sudo retry, 所以直接关闭stdin
    process.wait()
    rescode = process.returncode
    _logger.info("getSuperRight: " + str(rescode))
    return rescode

def releaseSuperRight():
    global _logger
    rescode = exec("sudo -k >/dev/null 2>/dev/null")
    _logger.info("releaseSuperRight: " + str(rescode))
    return (rescode == 0)


class WorkerVerifyPwd(threading.Thread):

    def __init__(self, dialog, strpwd, strcmd):
        threading.Thread.__init__(self)
        self.dialog = dialog
        self.strpwd = strpwd
        self.strcmd = strcmd

    def run(self):
        utils.exec("sudo -k")
        # utils.exec("chmod 755 ./scripts/zz_test_super_right.sh")
        # rescode = utils.sudo("./scripts/zz_test_super_right.sh", self.strpwd)
        # rescode = utils.sudo("./scripts/zz_test_super_right.sh", self.strpwd)

        # rescode = utils.sudo(self.strcmd, self.strpwd)

        # rescode = utils.sudo("-v", self.strpwd)
        rescode = utils.getSuperRight(self.strpwd)

        _logger.info("WorkerVerifyPwd: " + str(rescode))

        self.dialog.rescode = rescode
        if rescode == 0:
            self.dialog.close()
        else:
            self.dialog.onfail()


class DialogSUDO(Gtk.Dialog):
    def __init__(self, parent, strcmd):
        super().__init__(title="提升运行权限", transient_for=parent, flags=0)
        # self.add_buttons(
        #     Gtk.STOCK_CANCEL, Gtk.ResponseType.CANCEL, Gtk.STOCK_OK, Gtk.ResponseType.OK
        # )

        self.set_default_size(150, 100)
        self.set_border_width(10)

        self.rescode = -1
        self.strpwd  = ""
        self.strcmd  = strcmd

        self.grid = Gtk.Grid()
        box = self.get_content_area()
        box.add(self.grid)

        self.label1 = Gtk.Label(label='权限不足，\n软件需要提升权限才能继续运行，\n请输入当前用户的密码进行授权：')
        self.grid.attach(self.label1, 0, 0, 2, 1)

        self.entry = Gtk.Entry ();
        self.entry.set_input_purpose(Gtk.InputPurpose.PASSWORD);
        self.entry.set_visibility(False);
        #self.entry.set_invisible_char("*");
        self.grid.attach(self.entry, 0, 1, 2, 1);
        self.entry.connect("activate", self.onInputChanged)
    
        self.label2 = Gtk.Label( label= " 回车继续");
        self.label2.set_justify (Gtk.Justification.LEFT);
        self.grid.attach_next_to(self.label2, self.entry, Gtk.PositionType.RIGHT, 1, 1);

        self.label3 = Gtk.Label( label= "");
        self.label3.set_justify (Gtk.Justification.LEFT);
        self.label3.set_markup ('<small>\n注：用户droidvm的默认密码为: <b>droidvm</b></small>\n');
        self.grid.attach(self.label3, 0, 2, 1, 1);

        self.btnFillpwd = Gtk.Button.new_with_label("使用默认密码")
        self.btnFillpwd.connect("clicked", self.fillpasswd)
        self.grid.attach(self.btnFillpwd, 0, 3, 1, 1);
        # self.grid.attach_next_to(self.btnFillpwd, self.label3, Gtk.PositionType.RIGHT, 1, 1);

        #css加载
        self.btnFillpwd.set_name("btnFillpwd")
        strcss="""
            #btnFillpwd {
            color: #F55;
            background-color: #eef;
            background-image: -gtk-scaled(url('resource://css/brick.png'), url('resource://css/brick2.png'));
            background-repeat: no-repeat;
            background-position: center;
            /* 测试 */
        }
        """
        strpath="/tmp/DialogSUDO.css"
        fp = open(strpath, 'w')
        fp.write(strcss)
        fp.close()

        provider = Gtk.CssProvider()
        # provider.connect("parsing-error", self.show_css_parsing_error)
        # fname = Gio.file_new_for_path('play.css')
        # provider.load_from_file(fname)
        # https://docs.gtk.org/gtk4/method.CssProvider.load_from_file.html
        # load_from_path, load_from_file, load_from_string
        provider.load_from_path(strpath)
        # button.set_name("btnFillpwd")
        # self.apply_css(window, provider)
        self.apply_css(box, provider)

    def apply_css(self, widget, provider):
        Gtk.StyleContext.add_provider(widget.get_style_context(), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)
        if isinstance(widget, Gtk.Container):
            widget.forall(self.apply_css, provider)

    def fillpasswd(self, button):
        self.entry.set_text("droidvm")
        self.onInputChanged(self.entry)

    def update_label(self, strmsg):
        self.label2.set_text(strmsg)

    def onfail(self):
        self.update_label(" 密码错误")


    def start(self):
        global _logger
        self.show_all()
        response = self.run()
        if response == Gtk.ResponseType.CANCEL:
            self.rescode = -1
        _logger.info("DialogSUDO.rescode: " + str(self.rescode) )
        return self.rescode
    
    def onInputChanged(self, entry):
        self.entry.select_region(0, -1)
        self.strpwd = entry.get_text().strip(' ')
        self.update_label(" 正在验证密码")
        worker=WorkerVerifyPwd(self, self.strpwd, self.strcmd)
        worker.start()

class WorkerExec(threading.Thread):

    def __init__(self, strcmd):
            threading.Thread.__init__(self)
            self.strcmd = strcmd

    def run(self):
            utils.exec(self.strcmd)

