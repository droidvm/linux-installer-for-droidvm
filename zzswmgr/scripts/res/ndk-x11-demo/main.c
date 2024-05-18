/*
 * https://www.x.org/wiki/ProgrammingDocumentation/
 * https://www.x.org/releases/current/doc/libX11/libX11/libX11.html
 * https://x.org/releases/X11R7.7/doc/xorg-docs/fonts/fonts.html			=> X11 includes two font systems
 * 
 * 在WSL中编译：
 * fc-list :lang=zh
 * xlsfonts
 * fc-list
 * cat /usr/include/X11/Xft/Xft.h |grep XftDrawString
 * 1. sudo ln -s /usr/include/freetype2/freetype/ /usr/include/freetype
 * 2. sudo ln -s /usr/include/freetype2/ft2build.h /usr/include/ft2build.h
 * gcc -g3 main.c -lX11 -lXft -lfontconfig
 * export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):0
 * ./a.out
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <X11/Xlib.h>
#include <X11/Xlocale.h>
#include <X11/Xft/Xft.h>


int main(void)
{
	Display *display;
	Window window;
	XEvent event;
	GC gc;
	char *msg = "Hello, 世界，, world";
	int s;
	Font f;
	XftDraw *xftDraw;
	XftPattern *pattern;
	XFontSet fontset;
	char **missing_charsets;
	int num_missing_charsets;
	char *default_string;

	// if ( setlocale (LC_ALL,"zh_CN.UTF-8") == NULL ) {
	// 	fprintf (stderr, "cannot set locale.\n");
	// 	exit (1);
	// }

	/* 与Xserver建立连接 */
	display = XOpenDisplay(NULL);
	if (display == NULL)
	{
		fprintf(stderr, "Cannot open display\n");
		exit(1);
	}

	s = DefaultScreen(display);

	/* 创建一个窗口 */
	window = XCreateSimpleWindow(display, RootWindow(display, s), 10, 10, 800, 600, 1,
								 BlackPixel(display, s), WhitePixel(display, s));
	XStoreName(display, window, "这个程序是在安卓端运行的！");

	gc = XCreateGC(display, window, 0, NULL);
	// f = XLoadFont(display, "Ubuntu Regular");
	// XSetFont(display, gc, f );
	pattern = XftPatternCreate(); // XftFontMatch (display, s, pattern,NULL); // 
	XftResult result;
	XftFont *xftFont;
	// xftFont = XftFontOpenPattern(display, XftFontMatch(display, s, pattern, &result));
	xftFont = XftFontOpenName(display, s, "Noto Serif CJK SC"); // ""); // "Droid Sans Fallback");

	XftColor FTcolor;
	FTcolor.color.red   = 99 << 8;
	FTcolor.color.green = 00 << 8;
	FTcolor.color.blue  = 99 << 8;
	FTcolor.color.alpha = 0xffff;
	xftDraw = XftDrawCreate(display, window, DefaultVisual (display, s), DefaultColormap (display, s));

	XSetForeground(display, gc, 0xFFD966); 

	/* 选择一种感兴趣的事件进行监听 */
	XSelectInput(display, window, ExposureMask | KeyPressMask);

	/* 显示窗口 */
	XMapWindow(display, window);

	// 有这两行才能正常关闭窗口而不会有错误信息
	Atom WM_DELETE_WINDOW = XInternAtom(display, "WM_DELETE_WINDOW", False);
	XSetWMProtocols(display, window, &WM_DELETE_WINDOW, 1);


	/* 事件遍历 */
	for (;;)
	{
		XNextEvent(display, &event);

		if (event.type == ClientMessage) {
			break;
		}

		switch (event.type)
		{
		case Expose:
			/* 绘制窗口或者重新绘制 */
			XFillRectangle(display, window, gc, 20, 20, 80, 80);

			XftDrawStringUtf8(xftDraw, &FTcolor, xftFont, 150, 200, msg, strlen(msg));

			break;
		case KeyPress:
			break;
		default:
			break;
		}
	}

	XftDrawDestroy(xftDraw);
	XFreeGC(display, gc);
	XUnmapWindow(display, window);
	XDestroyWindow(display, window);

	/* 关闭与Xserver服务器的连接 */
	XCloseDisplay(display);

	return 0;
}
