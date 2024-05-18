https://blog.csdn.net/u012193416/article/details/128093066#:~:text=opengl%E5%AE%9A%E4%B9%89%E4%BA%86%E4%B8%80%E4%B8%AA%E8%B7%A8%E7%BC%96%E7%A8%8B%E8%AF%AD%E8%A8%80%EF%BC%8C%E8%B7%A8%E5%B9%B3%E5%8F%B0%E7%9A%84%E5%BA%94%E7%94%A8%E7%A8%8B%E5%BA%8F%E6%8E%A5%E5%8F%A3%EF%BC%8Copengl%20es%E6%98%AFopengl%E7%9A%84%E5%B5%8C%E5%85%A5%E5%BC%8F%E7%89%88%E6%9C%AC%EF%BC%8C%E7%94%A8%E4%BA%8Eios%E5%92%8Candroid%EF%BC%8C%E5%90%8E%E6%9D%A5%E4%B8%80%E4%BA%9B%E8%BF%BD%E6%B1%82%E9%AB%98%E6%80%A7%E8%83%BD%E7%9A%84%E8%AE%BE%E5%A4%87%E4%B9%9F%E5%BC%80%E5%A7%8B%E7%94%A8%E8%BF%99%E7%A7%8Dapi%EF%BC%8Copengl%20es%E6%98%AFopengl%E7%9A%84%E5%AD%90%E9%9B%86%EF%BC%8C%E5%8C%BA%E5%88%AB%E5%9C%A8%E4%BA%8Eopengl,es%E5%88%A0%E5%87%8F%E4%BA%86opengl%E4%B8%80%E5%88%87%E4%BD%8E%E6%95%88%E8%83%BD%E7%9A%84%E6%93%8D%E4%BD%9C%E6%96%B9%E5%BC%8F%EF%BC%8C%E6%9C%89%E9%AB%98%E6%80%A7%E8%83%BD%E7%9A%84%E7%BB%9D%E4%B8%8D%E7%95%99%E4%BD%8E%E6%95%88%E8%83%BD%E7%9A%84%EF%BC%8C%E5%8D%B3%E5%8F%AA%E6%B1%82%E6%95%88%E8%83%BD%E4%B8%8D%E8%BF%BD%E6%B1%82%E5%85%BC%E5%AE%B9%E6%80%A7%EF%BC%8Copengl%20es%E8%83%BD%E5%AE%9E%E7%8E%B0%E7%9A%84%EF%BC%8Copengl%E4%B9%9F%E8%83%BD%E5%AE%9E%E7%8E%B0%EF%BC%8Copengl%E9%83%A8%E5%88%86api%EF%BC%8Copengl%20es%E4%B8%8D%E6%94%AF%E6%8C%81%E3%80%82


opengl(全功能版本)/opengles(嵌入式用的裁剪版本)
用于操控GPU

EGL
用于对接本地显示系统的窗口系统
在不同平台上实现不同的窗口，如：
window：	OpenGL ES + EGL + Window系统窗口（实际运行还需要加OpenGL ES的模拟器，OpenGL.ES.3.0.Programming.Guide中有介绍高通芯片等模拟器的使用的章节）；
Linux：	OpenGL ES + EGL + X11窗口；
ARM：	OpenGL ES + EGL + wayland窗口；
android:OpenGL ES + EGL + ANativeWindow/ANativeActivity



Android OpenGL ES 离屏渲染（offscreen render） C++ 实现
https://blog.csdn.net/kongbaidepao/article/details/109191155
http://files.cnblogs.com/files/hrlnw/OffScreenTest.zip
