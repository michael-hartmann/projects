#!/usr/bin/python

from __future__ import division

import pygtk
pygtk.require('2.0')
import gtk, gobject
import pynotify
import time, re, os, subprocess
from threading import Thread
from user import home


def sec2hum(x):
    s = x  % 60
    m = x // 60
    return (m, s)


class Notify:
    def __init__(self):
        pynotify.init("pyto")

    def say(self, title, msg):
        n = pynotify.Notification(title, msg)
        n.set_timeout(5000)
        n.show()
        return n


class ShutdownGUI:
    def __init__(self):
        self.visible = False
        self.id = None
        self.time = None
        self.countdown_start = None

        self.window = gtk.Window(gtk.WINDOW_TOPLEVEL)
        self.window.set_border_width(5)
        self.window.set_resizable(False)
        self.window.set_title("Ausschalten")
        self.window.set_position(gtk.WIN_POS_CENTER_ALWAYS)
        self.window.stick()
        self.window.set_urgency_hint(True)

        self.vbox = gtk.VBox(False, 5)
        self.window.add(self.vbox)

        self.hbox = gtk.HBox(False, 5)
        self.vbox.pack_start(self.hbox)

        self.image = gtk.image_new_from_stock(gtk.STOCK_QUIT, gtk.ICON_SIZE_LARGE_TOOLBAR)
        self.hbox.pack_start(self.image)

        self.vbox2 = gtk.VBox(False, 5)
        self.hbox.pack_start(self.vbox2)

        self.label = gtk.Label()
        self.vbox2.pack_start(self.label)

        self.hbox2 = gtk.HBox(False, 5);
        self.vbox2.pack_start(self.hbox2)

        self.button_cancel = gtk.Button(stock=gtk.STOCK_CANCEL)
        self.button_cancel.connect("clicked", self.stop, None)
        self.hbox2.pack_start(self.button_cancel)
        self.button_ok = gtk.Button(label="sofort Ausschalten")
        self.button_ok.connect("clicked", self.shutdown, None)
        self.hbox2.pack_start(self.button_ok)


    def update(self, *params):
        if(self.countdown_start != None and self.time != None):
            time_left = self.countdown_start + self.time - time.time()
            if(time_left >= 0):
              (min, sec) = sec2hum(time_left)
              text = "Wenn Du nicht auf abbrechen klickst,\nwird der Rechner in %02d:%02d heruntergefahren." % (min, sec)
              self.label.set_text(text)
            else:
              self.shutdown()

        return True


    def shutdown(self, *params):
        self.stop()
        notify.say("Ausschalten", "Der Rechner wird jetzt heruntergefahren.")
        preferences.run_cmd("shutdown")


    def start(self, *params):
        self.visible = True
        self.time = preferences.get_countdown()
        print self.time
        self.countdown_start = time.time()
        self.update()
        self.window.show_all()
        gobject.timeout_add(10, self.update)


    def stop(self, *params):
        self.window.hide_all()
        if(self.id):
            gobject.source_remove(self.id)
        self.visible = False
        self.time = None
        self.countdown_start = None


class PreferencesGUI:
    def __init__(self):
        self.filename = home + "/.topy"
        self.visible = False
        self.preferences = {}

        self.window = gtk.Window(gtk.WINDOW_TOPLEVEL)
        self.window.set_border_width(5)
        self.window.set_title("Einstellungen")

        self.vbox = gtk.VBox(False, 5)
        self.window.add(self.vbox)

        self.frame_cmd = gtk.Frame("Kommandos")
        self.vbox.pack_start(self.frame_cmd)

        self.table_cmd = gtk.Table(2, 4, False)
        self.table_cmd.set_border_width(5)
        self.frame_cmd.add(self.table_cmd)

        self.label_cmd_shutdown = gtk.Label("Herunterfahren")
        self.entry_cmd_shutdown = gtk.Entry(30)
        self.table_cmd.attach(self.label_cmd_shutdown, 0, 1, 0, 1)
        self.table_cmd.attach(self.entry_cmd_shutdown, 1, 2, 0, 1)
        
        self.label_cmd_offline = gtk.Label("Akku-Betrieb")
        self.entry_cmd_offline = gtk.Entry(30)
        self.table_cmd.attach(self.label_cmd_offline, 0, 1, 1, 2)
        self.table_cmd.attach(self.entry_cmd_offline, 1, 2, 1, 2)
        
        self.label_cmd_online = gtk.Label("Netz-Betrieb")
        self.entry_cmd_online = gtk.Entry(30)
        self.table_cmd.attach(self.label_cmd_online, 0, 1, 2, 3)
        self.table_cmd.attach(self.entry_cmd_online, 1, 2, 2, 3)
        
        self.label_countdown = gtk.Label("Countdown")
        hbox = gtk.HBox(False, 5)
        self.adjustment = gtk.Adjustment(value=15, lower=0.5, upper=90, step_incr=0.5, page_incr=0, page_size=0)
        self.spin_countdown = gtk.SpinButton(adjustment=self.adjustment, climb_rate=0.5, digits=2)
        hbox.pack_start(self.spin_countdown)
        hbox.pack_start(gtk.Label("Minuten"))
        self.table_cmd.attach(self.label_countdown, 0, 1, 3, 4)
        self.table_cmd.attach(hbox, 1, 2, 3, 4)

        self.hbox = gtk.HBox(False, 5)
        self.button_save  = gtk.Button(stock=gtk.STOCK_SAVE)
        self.button_cancel = gtk.Button(stock=gtk.STOCK_CANCEL)

        self.button_cancel.connect("clicked", self.cancel, None)
        self.button_save.connect("clicked", self.save, None)

        self.hbox.pack_start(self.button_save)
        self.hbox.pack_start(self.button_cancel)
        self.vbox.pack_start(self.hbox)

        self.load()

  
    def load(self):
        if(os.path.isfile(self.filename)):
            f = open(self.filename, "r")
            p = re.compile("(\w+):\s*(.*)\s*")
            for line in f:
                line.strip()
                m = p.match(line)

                (key, value) = (m.group(1), m.group(2))
                self.preferences[key] = value
            f.close() 
        else:
            self.preferences["shutdown"]  = ""
            self.preferences["online"]    = ""
            self.preferences["offline"]   = ""
            self.preferences["countdown"] = "15"

        self.entry_cmd_shutdown.set_text(self.preferences["shutdown"])
        self.entry_cmd_online  .set_text(self.preferences["online"])
        self.entry_cmd_offline .set_text(self.preferences["offline"])
        self.spin_countdown.set_value(float(self.preferences["countdown"]))


    def save(self, *params):
        f = open(self.filename, "w")
        f.write("online: ")
        f.write(self.entry_cmd_online.get_text() + "\n")
        f.write("offline: ")
        f.write(self.entry_cmd_offline.get_text() + "\n")
        f.write("shutdown: ")
        f.write(self.entry_cmd_shutdown.get_text() + "\n")
        f.write("countdown: ")
        f.write(str(self.spin_countdown.get_value()) + "\n")
        f.close()

        self.preferences["online"]    = self.entry_cmd_online.get_text()
        self.preferences["offline"]   = self.entry_cmd_offline.get_text()
        self.preferences["shutdown"]  = self.entry_cmd_shutdown.get_text()
        self.preferences["countdown"] = str(self.spin_countdown.get_value())

        self.hide()

    def show(self, *params):
        self.visible = True
        self.window.show_all()

    def cancel(self, *params):
        self.load()
        self.hide()

    def hide(self, *params):
        self.visible = False
        self.window.hide_all()

    def toggle(self, *params):
        if(self.visible):
            self.hide()
        else:
            self.show()

    def run_cmd(self, action):
        cmd  = ""

        if(action == "shutdown"):
            cmd = self.preferences["shutdown"]
        elif(action == "online"):
            cmd = self.preferences["online"]
        elif(action == "offline"):
            cmd = self.preferences["offline"]
        else:
            print "unknown action %s" % action

        if(cmd):
            os.system(cmd)
 
    def get_countdown(self):
        return float(self.spin_countdown.get_value()) * 60


class State(Thread):
    def __init__(self):
        Thread.__init__(self)
        self.state = "init"
        self.setDaemon(True)
        self.check()


    def check(self):
        f = open("/proc/acpi/ac_adapter/AC0/state", "r")
        content = f.read()
        f.close()

        if(re.search("on-line", content)):
            state = "online"
        else:
            state = "offline"

        if  (self.state == "online"  and state == "offline"):
            gtk.gdk.threads_enter()
            notify.say("Stromversorgung", "Der Netzstecker wurde gezogen.")
            shutdown.start()
            preferences.run_cmd("offline")
            gtk.gdk.threads_leave()
        elif(self.state == "offline" and state == "online"):
            gtk.gdk.threads_enter()
            notify.say("Stromversorgung", "Der Netzstecker wurde angesteckt.")
            shutdown.stop()
            preferences.run_cmd("online")
            gtk.gdk.threads_leave()

        self.state = state


    def run(self):
            pipe = subprocess.Popen("acpi_listen", shell=False, bufsize=512, stdout=subprocess.PIPE).stdout
            while True:
                line = pipe.readline()
                if(re.match("ac_adapter", line)):
                  self.check()
            pipe.close()



class MainGUI:
    def __init__(self):
        gtk.gdk.threads_init()
        self.statusicon = gtk.status_icon_new_from_stock(gtk.STOCK_QUIT)
        self.statusicon.connect("popup-menu", self.menu, None)
        #notify.say("Hallo", "welt")
        self.state = State()
        self.state.start()


    def main(self):
        gtk.main()


    def menu(self, status_icon, button, activate_time, *param):
        menu = gtk.Menu()
  
        pref = gtk.ImageMenuItem(gtk.STOCK_PREFERENCES)
        pref.connect("activate", preferences.toggle, None)
        menu.append(pref)

        menu.append(gtk.SeparatorMenuItem())
  
        quit = gtk.ImageMenuItem(gtk.STOCK_QUIT)
        quit.connect("activate", self.quit, None)
        menu.append(quit)
  
        menu.show_all()
  
        menu.popup(None, None, None, button, activate_time)
        return True
    

    def quit(self, *params):
        gtk.main_quit()



preferences = PreferencesGUI()
notify      = Notify()
shutdown    = ShutdownGUI()
gui         = MainGUI();

try:
    gui.main()
except KeyboardInterrupt:
    pass
