/*
 * blackscreen.c
 *
 * Covers the current monitor (whichever the cursor is on) with a solid
 * black, override-redirect window. Left-click or Escape to quit.
 *
 * Build:
 *   gcc -O2 -Wall -o blackscreen blackscreen.c -lX11 -lXrandr
 *
 * Run:
 *   ./blackscreen
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include <X11/Xlib.h>
#include <X11/keysym.h>
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

    XSetWindowAttributes attrs = {0};
    attrs.override_redirect = True;
    attrs.background_pixel  = BlackPixel(dpy, scr);
    attrs.event_mask        = ButtonPressMask | ExposureMask | KeyPressMask;

    Window win = XCreateWindow(
        dpy, RootWindow(dpy, scr),
        mon.x, mon.y, (unsigned)mon.w, (unsigned)mon.h, 0,
        DefaultDepth(dpy, scr), InputOutput, DefaultVisual(dpy, scr),
        CWOverrideRedirect | CWBackPixel | CWEventMask, &attrs);

    GC gc = XCreateGC(dpy, win, 0, NULL);
    XSetForeground(dpy, gc, BlackPixel(dpy, scr));

    /* Write PID file so other scripts can find/kill this process. */
    FILE *pf = fopen("/tmp/blackscreen.pid", "w");
    if (pf) {
        fprintf(pf, "%d\n", (int)getpid());
        fclose(pf);
    }

    XMapRaised(dpy, win);
    XFlush(dpy);

    for (;;) {
        XEvent ev;
        XNextEvent(dpy, &ev);

        switch (ev.type) {
        case Expose:
            XFillRectangle(dpy, win, gc, 0, 0,
                           (unsigned)mon.w, (unsigned)mon.h);
            XFlush(dpy);
            break;

        case ButtonPress:
            if (ev.xbutton.button == Button1)   /* left click */
                goto done;
            break;

        case KeyPress: {
            KeySym ks = XLookupKeysym(&ev.xkey, 0);
            if (ks == XK_Escape)
                goto done;
            break;
        }
        }
    }

done:
    XFreeGC(dpy, gc);
    XDestroyWindow(dpy, win);
    XCloseDisplay(dpy);
    remove("/tmp/blackscreen.pid");
    return 0;
}
