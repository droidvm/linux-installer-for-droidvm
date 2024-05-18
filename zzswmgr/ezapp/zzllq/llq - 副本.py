#!/usr/bin/python3

# sudo apt install -y python3-webview gir1.2-webkit2-4.0
# sudo apt install -y dillo   # 3M的浏览器


import webview
import gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk
from gi.repository import GLib
from gi.repository import Gdk

def create_window():
    # webview.create_window("浏览器", "https://gitee.com/droidvm/app")
    webview.create_window("浏览器", "https://linux.wps.cn/")

if __name__ == "__main__":
    create_window()
    webview.start()
