/*
 * blackscreen.c
 *
 * Covers the current monitor (whichever the cursor is on) with a solid
 * black window. Left-click to quit.
 *
 * Build:
 *   gcc -O2 -Wall -o blackscreen blackscreen.c -lX11 -lXrandr
 *
 * Run:
 *   ./blackscreen
 */

#include <stdio.h>
#include <stdlib.h>

#include <X11/Xlib.h>
#include <X11/Xatom.h>
#include <X11/extensions/Xrandr.h>

typedef struct { int x, y, w, h; } Rect;

/* Return the monitor rectangle that currently contains the pointer. */
static Rect current_monitor(Display *dpy, int scr)
{
    Rect fallback = { 0, 0, DisplayWidth(dpy, scr), DisplayHeight(dpy, scr) };

    Window dummy1, dummy2;
    int root_x, root_y, win_x, win_y;
    unsigned int mask;
    if (!XQueryPointer(dpy, RootWindow(dpy, scr),
                       &dummy1, &dummy2,
                       &root_x, &root_y,
                       &win_x, &win_y, &mask))
        return fallback;

    int n = 0;
    XRRMonitorInfo *mons = XRRGetMonitors(dpy, RootWindow(dpy, scr), True, &n);
    if (!mons) return fallback;

    Rect r = fallback;
    for (int i = 0; i < n; i++) {
        if (root_x >= mons[i].x && root_x < mons[i].x + mons[i].width &&
            root_y >= mons[i].y && root_y < mons[i].y + mons[i].height) {
            r.x = mons[i].x;
            r.y = mons[i].y;
            r.w = mons[i].width;
            r.h = mons[i].height;
            break;
        }
    }
    XRRFreeMonitors(mons);
    return r;
}

int main(void)
{
    Display *dpy = XOpenDisplay(NULL);
    if (!dpy) {
        fprintf(stderr, "Cannot open X display\n");
        return 1;
    }

    int scr  = DefaultScreen(dpy);
    Rect mon = current_monitor(dpy, scr);

    Atom _NET_WM_STATE            = XInternAtom(dpy, "_NET_WM_STATE",            False);
    Atom _NET_WM_STATE_FULLSCREEN = XInternAtom(dpy, "_NET_WM_STATE_FULLSCREEN", False);

    XSetWindowAttributes attrs = {0};
    attrs.background_pixel  = BlackPixel(dpy, scr);
    attrs.event_mask        = ButtonPressMask | ExposureMask;

    Window win = XCreateWindow(
        dpy, RootWindow(dpy, scr),
        mon.x, mon.y, (unsigned)mon.w, (unsigned)mon.h, 0,
        DefaultDepth(dpy, scr), InputOutput, DefaultVisual(dpy, scr),
        CWBackPixel | CWEventMask, &attrs);

    Atom states[1] = { _NET_WM_STATE_FULLSCREEN };
    XChangeProperty(dpy, win, _NET_WM_STATE, XA_ATOM, 32,
                    PropModeReplace, (unsigned char *)states, 1);

    GC gc = XCreateGC(dpy, win, 0, NULL);
    XSetForeground(dpy, gc, BlackPixel(dpy, scr));

    XStoreName(dpy, win, "blackscreen");
    XMapRaised(dpy, win);

    XEvent ev;
    ev.type                 = ClientMessage;
    ev.xclient.window       = win;
    ev.xclient.message_type = _NET_WM_STATE;
    ev.xclient.format       = 32;
    ev.xclient.data.l[0]    = 1; /* _NET_WM_STATE_ADD */
    ev.xclient.data.l[1]    = (long)_NET_WM_STATE_FULLSCREEN;
    ev.xclient.data.l[2]    = 0;
    ev.xclient.data.l[3]    = 1;
    XSendEvent(dpy, RootWindow(dpy, scr), False,
               SubstructureNotifyMask | SubstructureRedirectMask, &ev);
    XFlush(dpy);

    for (;;) {

        XNextEvent(dpy, &ev);

        switch (ev.type) {
        case Expose:
            XFillRectangle(dpy, win, gc, 0, 0,
                           (unsigned)mon.w, (unsigned)mon.h);
            XFlush(dpy);
            break;

        case ButtonPress:
            if (ev.xbutton.button == Button1) {
                XFreeGC(dpy, gc);
                XDestroyWindow(dpy, win);
                XCloseDisplay(dpy);
                return 0;
            }
            break;
        }
    }
}
