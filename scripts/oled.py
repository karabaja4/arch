#!/usr/bin/env python3
import sys
import os
import tkinter as tk

class ToggleFullscreenApp:
    def __init__(self, root, start_fullscreen=False):
        self.root = root
        self.fullscreen = False

        # Initial window size (rectangle)
        self.width = 1280
        self.height = 800
        self.root.geometry(f"{self.width}x{self.height}")  # let WM place it
        self.root.configure(background="black")
        
        pid = os.getpid()
        self.root.title(f"OLED saver [{pid}]")

        # Bind click events
        self.root.bind("<Button-3>", self.toggle_fullscreen)
        self.root.bind("<Button-1>", self.exit_app)

        # Force window manager to place window and get actual geometry
        self.root.update_idletasks()
        x = self.root.winfo_x()
        y = self.root.winfo_y()
        w = self.root.winfo_width()
        h = self.root.winfo_height()
        self.saved_geometry = f"{w}x{h}+{x}+{y}"

        # Start in fullscreen if requested
        if start_fullscreen:
            self.toggle_fullscreen()

    def toggle_fullscreen(self, event=None):
        self.fullscreen = not self.fullscreen
        if self.fullscreen:
            # Save current geometry
            self.root.update_idletasks()
            x = self.root.winfo_x()
            y = self.root.winfo_y()
            w = self.root.winfo_width()
            h = self.root.winfo_height()
            self.saved_geometry = f"{w}x{h}+{x}+{y}"

            # Go fullscreen
            self.root.attributes("-fullscreen", True)
            self.root.configure(cursor="none")
        else:
            # Restore original size and position
            self.root.attributes("-fullscreen", False)
            self.root.geometry(self.saved_geometry)
            self.root.configure(cursor="arrow")

    def exit_app(self, event=None):
        self.root.quit()


if __name__ == "__main__":
    script_name = sys.argv[0]
    
    if "-h" in sys.argv or "--help" in sys.argv:
        print(
            f"Usage: python3 {script_name} [options]\n\n"
            "Options:\n"
            "  -h, --help      Show this help message and exit\n"
            "  -m              Start the application in fullscreen mode\n\n"
            "Controls:\n"
            "  Right-click     Toggle fullscreen on/off\n"
            "  Left-click      Exit the application"
        )
        sys.exit(0)
    
    start_fullscreen = "-m" in sys.argv
    root = tk.Tk()
    app = ToggleFullscreenApp(root, start_fullscreen=start_fullscreen)
    root.mainloop()
