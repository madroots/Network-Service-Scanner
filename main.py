#!/usr/bin/env python3

import gi
import sys
import threading
import subprocess
import json
import os

gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, Gdk, GLib, GObject

from ui.main_window import MainWindow
from core.scanner import NetworkScanner
from core.config import ConfigManager

class NSSApplication(Gtk.Application):
    def __init__(self):
        super().__init__(application_id="com.example.nss-gui")
        self.window = None

    def do_activate(self):
        if not self.window:
            self.window = MainWindow(application=self)
        self.window.show_all()

def main():
    app = NSSApplication()
    app.run(sys.argv)

if __name__ == "__main__":
    main()