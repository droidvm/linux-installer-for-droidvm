#include <X11/Xatom.h>
#include <X11/Xlib.h>
#include <X11/extensions/Xfixes.h>
#include <stdlib.h>
#include <stdio.h>

int main(void) {
    Display *disp;
    Window root;
    XEvent evt;

    disp = XOpenDisplay(NULL);
    if (!disp)
        exit(1);

    root = DefaultRootWindow(disp);

    // XFixesSelectSelectionInput(disp, root, XA_PRIMARY, XFixesSetSelectionOwnerNotifyMask);
    XFixesSelectSelectionInput(disp, root, XA_CLIPBOARD, XFixesSetSelectionOwnerNotifyMask);
    

    while(1) {
		XNextEvent(disp, &evt);
		printf("evt.type: %d\n", evt.type);
    }
    XCloseDisplay(disp);
}

// gcc 1.c -lX11 -lXfixes
