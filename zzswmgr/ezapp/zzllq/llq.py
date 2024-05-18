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
    webview.create_window("浏览器", "https://gitee.com/droidvm/app")
    # webview.create_window("浏览器", "https://linux.wps.cn/")

if __name__ == "__main__":
    create_window()

    chinese = {
        'global.quitConfirmation': u'确定关闭?',
    }
    webview.start(localization=chinese, debug=True)

#     # webview.start()


# import webview


# if __name__ == '__main__':
#     # Master window
#     master_window = webview.create_window('Window #1', html='<h1>First window</h1>')
#     second_window = webview.create_window('Window #2', html='<h1>Second window</h1>')
#     third_window = webview.create_window('Window #3', html='<h1>Third Window</h1>')
#     webview.start(third_window)


# import threading

# import webview

# html = """
#   <html>
#     <head></head>
#     <body>
#       <h2>Links</h2>

#       <p><a href='https://pywebview.flowrl.com'>Regular links</a> are opened in the application window.</p>
#       <p><a href='https://pywebview.flowrl.com' target='_blank'>target='_blank' links</a> are opened in an external browser.</p>

#     </body>
#   </html>
# """

# if __name__ == '__main__':
#     window = webview.create_window('Link types', html=html)
#     webview.start()
